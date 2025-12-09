# Ref: https://github.com/JuliaGeo/CommonDataModel.jl/blob/main/src/multifile.jl#L17

"""
    MFDataset

Multi-file dataset wrapper.
"""
struct MFDataset{T, D} <: AbstractDataset
    datasets::Vector{T}
    aggdim::D
end

MFDataset(files::Vector{String}, aggdim = 1; kw...) = MFDataset(HDF5Dataset.(files; kw...), aggdim)

function Base.getindex(ds::MFDataset, name)
    data = mapreduce(d -> d[name], vcat, ds.datasets)
    return HDF5Variable(data, name, ds)
end

Base.keys(ds::MFDataset) = keys(ds.datasets[1])
Base.getindex(ds::MFDataset, i::Integer) = ds.datasets[i]

file(ds::MFDataset) = ds.datasets[1].file
dims(ds::MFDataset) = ds.datasets[1].dims
path(ds::MFDataset) = path.(ds.datasets)

@inline function Base.getproperty(ds::MFDataset, name::Symbol)
    name == :dim && return Dimensions(ds)
    # TODO: handle varying attributes
    name == :notes && return println(exp_notes(ds))
    name == :attrib && return Dict{String, String}(exp_params(ds))
    return getfield(ds, name)
end

dimname(dims, i) = dims[i]
dimname(_, name::String) = name

function dim(ds::MFDataset, i)
    datasets = ds.datasets
    _dims = dims(ds)
    # TODO: handle varying dimensions
    return dimname(_dims, i) == dimname(_dims, ds.aggdim) ? mapreduce(d -> dim(d, i), vcat, datasets) : dim(datasets[1], i)
end

Base.isopen(ds::MFDataset) = all(isopen, ds.datasets)
