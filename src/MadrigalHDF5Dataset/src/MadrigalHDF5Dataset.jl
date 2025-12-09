module MadrigalHDF5Dataset
using HDF5
using FieldViews: FieldViewable

export HDF5Dataset, MFDataset

struct Dimensions{P}
    parentdataset::P
end

Base.getindex(D::Dimensions, i) = dim(D.parentdataset, i)

struct HDF5Variable{T, N, P, A <: AbstractArray{T, N}} <: AbstractArray{T, N}
    data::A
    name::String
    parentdataset::P
end

Base.parent(dataset::HDF5Variable) = dataset.data
Base.size(dataset::HDF5Variable) = size(dataset.data)
Base.getindex(dataset::HDF5Variable, I...) = dataset.data[I...]

@inline function Base.getproperty(var::HDF5Variable, name::Symbol)
    name in fieldnames(HDF5Variable) && return getfield(var, name)
    return if name == :attrib
        mnemonic = uppercase(var.name)
        params = data_params(var.parentdataset)
        # https://github.com/JuliaIO/HDF5.jl/issues/1211 : option for faster iteration
        for p in params
            p.mnemonic == mnemonic && return p
        end
    end
end

include("hdf5dataset.jl")
include("multifile.jl")

end
