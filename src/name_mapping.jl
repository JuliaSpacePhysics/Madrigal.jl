kinst(i) = i
kinst(name::Symbol) = kinst_name_mapping()[name]
kinst(name::String) = @something tryparse(Int, name) kinst(Symbol(name))

@memoize function kinst_name_mapping()
    tbl = get_instruments(CEDAR_URL)
    d = Dict(Symbol.(tbl.mnemonic) .=> tbl.kinst)
    # overwrite for duplicates
    d[:mlh] = 30
    d[:mlhs] = 31 # Millstone Hill UHF Steerable Antenna
    d[:mlhz] = 32 # Millstone Hill UHF Zenith Antenna
    d[:tro] = 72
    d[:tromr] = 1810 # Tromso Specular Meteor Radar
    return d
end
