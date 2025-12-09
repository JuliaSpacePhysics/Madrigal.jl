abstract type AbstractDataset end

"""
    HDF5Dataset

Dataset wrapper for HDF5 files.

# Example
```julia
ds = HDF5Dataset("data.h5", "r")
var = ds["temperature"]
data = var[1:10, :]
close(ds)
```
"""
mutable struct HDF5Dataset{D, T} <: AbstractDataset
    file::HDF5.File
    dims::D

    function HDF5Dataset(path; dims = (), mode = "r")
        file = h5open(path, mode)
        traits = (has_array_layout(file), has_table_layout(file))
        ds = new{typeof(dims), traits}(file, dims)
        finalizer(close, ds)
        return ds
    end
end


has_array_layout(f::HDF5.File) = haskey(f, "Data/Array Layout")
has_table_layout(f::HDF5.File) = haskey(f, "Data/Table Layout")

traits(ds::HDF5Dataset) = typeof(ds).parameters[2]
has_array_layout(ds) = traits(ds)[1]
has_table_layout(ds) = traits(ds)[2]


"""
    HDF5Dataset(f::Function, path, mode="r")

Open HDF5 dataset, execute function, and ensure cleanup.

# Example
```julia
result = HDF5Dataset("data.h5", "r") do ds
    mean(ds["temperature"][:])
end
```
"""
function HDF5Dataset(f::Function, path, mode = "r")
    ds = HDF5Dataset(path, mode)
    try
        return f(ds)
    finally
        close(ds)
    end
end

# File access interface
Base.close(ds::HDF5Dataset) = isopen(ds.file) && close(ds.file)
Base.isopen(ds::HDF5Dataset) = isopen(ds.file)

# Remove "Data Parameters" from the list of parameters

function params(ds, i)
    layout = ds.file["Data"]["Array Layout"]
    return if i == 1
        layout["1D Parameters"]
    elseif i == 2
        layout["2D Parameters"]
    end
end

function params_keys(ds, i)
    ks = keys(params(ds, i))
    return deleteat!(ks, findfirst(==("Data Parameters"), ks))
end

"""
    keys(ds::HDF5Dataset)

Return all variable/group names. For datasets with Array Layout, returns parameter names.
"""
function Base.keys(ds::HDF5Dataset)
    return if has_array_layout(ds)
        params_1d = params_keys(ds, 1)
        params_2d = params_keys(ds, 2)
        vcat(params_1d, params_2d)
    else
        params = data_params(ds)
        map(p -> lowercase(p.mnemonic), params)
    end
end

"""
    haskey(ds::HDF5Dataset, name)

Check if variable or group exists. For Array Layout datasets, checks in 1D/2D Parameters.
"""
function Base.haskey(ds::HDF5Dataset, name::AbstractString)
    return if has_array_layout(ds)
        haskey(params(ds, 1), name) || haskey(params(ds, 2), name)
    else
        haskey(ds.file, name)
    end
end

file(ds::HDF5Dataset) = ds.file
data_params(ds) = read(file(ds)["Metadata"]["Data Parameters"])
exp_params(ds) = read(file(ds)["Metadata"]["Experiment Parameters"])
function exp_notes(ds)
    notes = read(file(ds)["Metadata"]["Experiment Notes"])
    return join(Base.Iterators.map(n -> n.var"File Notes", notes), "\n")
end

"""
    getindex(ds::HDF5Dataset, name)

Access variable by name. For Array Layout datasets, automatically looks in 1D/2D Parameters.
Returns HDF5Variable wrapper for datasets, raw groups otherwise.
"""
function Base.getindex(ds::HDF5Dataset, name)
    return if has_array_layout(ds)
        array_layout_getindex(ds, name)
    elseif has_table_layout(ds)
        table_layout_getindex(ds, name)
    else
        ds.file[name]
    end
end

Base.getindex(ds::HDF5Dataset, name::Symbol) = ds[String(name)]

@inline function Base.getproperty(ds::HDF5Dataset, name::Symbol)
    name == :dim && return Dimensions(ds)
    name == :attrib && return Dict{String, String}(exp_params(ds))
    name == :notes && return println(exp_notes(ds))
    return getfield(ds, name)
end

function array_layout_getindex(ds::HDF5Dataset, name)
    # Try 1D parameters first, then 2D parameters
    params_1d = params(ds, 1)
    params_2d = params(ds, 2)
    dset = if haskey(params_1d, name)
        params_1d[name]
    elseif haskey(params_2d, name)
        params_2d[name]
    else
        ds.file[name]
    end
    return dset isa HDF5.Dataset ? HDF5Variable(read(dset), name, ds) : dset
end

function table_layout_getindex(ds::HDF5Dataset, name)
    fv = FieldViewable(read(ds.file["Data"]["Table Layout"]))
    getproperty(fv, Symbol(name))
end

function dim(ds::HDF5Dataset, i)
    name = dimname(ds.dims, i)
    data = read(ds.file["Data"]["Array Layout"][name])
    return HDF5Variable(data, name, ds)
end

path(ds::HDF5Dataset) = ds.file.filename

function Base.show(io::IO, ::MIME"text/plain", ds::T) where {T <: AbstractDataset}
    println(io, nameof(T))
    println(io, "  Path: ", path(ds))
    return if isopen(ds)
        vars = collect(keys(ds))
        println(io, "  Variables ($(length(vars))):")
        for (i, var) in enumerate(vars)
            if i > 10
                println(io, "    ...")
                break
            end
            println(io, "    ", var)
        end
    end
end
