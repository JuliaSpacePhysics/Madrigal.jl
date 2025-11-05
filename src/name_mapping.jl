kinst(i) = i
kinst(name::Symbol) = KINST_NAME_MAPPING[name]

const KINST_NAME_MAPPING = Dict(
    :DMSP => 8100,
)

