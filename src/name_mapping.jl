kinst(i) = i
kinst(name::Symbol) = kinst_name_mapping()[name]
kinst(name::String) = @something tryparse(Int, name) kinst(Symbol(name))

function _kinst_name_mapping(server = CEDAR_URL)
    tbl = get_instruments(server)
    d = Dict(Symbol.(tbl.mnemonic) .=> tbl.kinst)
    # overwrite for duplicates
    d[:mlh] = 30
    d[:mlhs] = 31 # Millstone Hill UHF Steerable Antenna
    d[:mlhz] = 32 # Millstone Hill UHF Zenith Antenna
    d[:tro] = 72
    d[:tromr] = 1810 # Tromso Specular Meteor Radar
    return d
end

@static if isdefined(Base, :OncePerProcess)
    const kinst_name_mapping = Base.OncePerProcess{Dict{Symbol, Int}}() do
        _kinst_name_mapping()
    end
else
    const _KINST_NAME_MAPPING = Ref{Union{Dict{Symbol, Int}, Nothing}}(nothing)
    function kinst_name_mapping()
        _KINST_NAME_MAPPING[] = @something _KINST_NAME_MAPPING[] _kinst_name_mapping()
    end
end
