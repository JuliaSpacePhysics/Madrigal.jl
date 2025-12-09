using DimensionalData
using DimensionalData.Dimensions
using DimensionalData: NoMetadata
import DimensionalData: DimStack
using Dates: unix2datetime

name(d) = nothing
name(v::HDF5Variable) = v.name

function DimensionalData.DimStack(ds::MFDataset, params = keys(ds); data_params = NoMetadata())
    _dims = (unix2datetime.(ds.dim[1]), ds.dim[2])
    dims = (Ti(_dims[1]), Y(_dims[2]; metadata = get(data_params, name(_dims[2]), NoMetadata())))
    das = map(params) do param
        data = ds[param]
        metadata = get(data_params, param, NoMetadata())
        DimArray(data, dims[1:ndims(data)]; name = param, metadata)
    end
    return DimStack(das)
end
