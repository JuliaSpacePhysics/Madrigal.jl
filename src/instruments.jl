"""
    Instrument

A struct that encapsulates information about a Madrigal Instrument.

Similar to the `MadrigalInstrument` class in the madrigalWeb python module.
"""

@concrete terse struct Instrument{T} <: AbstractMadrigalObject
    "Instrument id"
    kinst::Int
    name
    "Three-character mnemonic"
    mnemonic
    latitude::T
    longitude::T
    altitude::T
    category
end

kinst(r::CSV.Row) = r.kinst

Instrument(r::CSV.Row) = Instrument(kinst(r), r.name, r.mnemonic, r.latitude, r.longitude, r.altitude, r.category)


"""
    get_instruments(server = Default_server[]; source = :cache)

Returns all Madrigal instruments from the `server`.

By default uses cached metadata for faster access. Set `source=:web` for direct web service access.

# Examples
```julia
# Get all instruments using cached metadata (fast)
get_instruments()

# Get all instruments using web service (up-to-date but slower)
get_instruments(source=:web)
```
"""
function get_instruments(server = Default_server[]; source = :cache, kw...)
    @assert source in (:web, :cache)
    server_url = get_url(server)
    if source == :web
        return get_instruments_web_service(server_url)
    else
        return get_instruments_cached(server_url; kw...)
    end
end

function get_instruments_web_service(server)
    url = server * "/getInstrumentsService.py"
    response = HTTP.get(url)
    header = [:name, :kinst, :mnemonic, :latitude, :longitude, :altitude, :category, :pi_name, :pi_email]
    return CSV.File(response.body; header, stringtype = PosLenString)
end

function get_instruments_cached(server; update = false)
    update && empty_cache!(_get_instruments_cached)
    return _get_instruments_cached(server)
end

@memoize function _get_instruments_cached(server)
    fileType = METADATA_TYPES[:instruments]
    url = server * "/getMetadata?fileType=$fileType"
    data = cached_get(url)
    header = [:kinst, :mnemonic, :name, :latitude, :longitude, :altitude, :contact, :contactAddr1, :contactAddr2, :contactAddr3, :contactCity, :contactState, :contactZip, :contactCountry, :contactPhone, :contactEmail, :category]
    return CSV.File(data; header, stringtype = PosLenString)
end
