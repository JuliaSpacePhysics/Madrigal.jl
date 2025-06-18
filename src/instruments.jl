"""
    get_all_instruments(url)
    get_all_instruments(server::Server = Default_server[])

Returns a list of all Madrigal instruments at the given Madrigal site `url` or `server`.

# Examples
```julia
# Get all instruments from the default server
instruments = get_all_instruments()

# Get all instruments from a specific server
server = Server("https://cedar.openmadrigal.org")
instruments = get_all_instruments(server)
```
"""
function get_all_instruments(url)
    script_name = "getInstrumentsService.py"
    url = rstrip(url, '/') * "/" * script_name

    response = HTTP.get(url)

    if response.status != 200
        error("Failed to get instruments: HTTP status $(response.status)")
    end

    body = String(response.body)
    # Check for errors in the response
    occursin("Error occurred", body) && error("Error from server: $url")

    lines = filter!(!isempty, split(body, "\n"))
    # Parse the result into Instrument objects
    instruments = Instrument[]

    for line in lines
        parts = split(line, ",")
        if length(parts) < 5
            continue
        end

        # Extract the category if available
        category = length(parts) > 6 ? parts[7] : "unknown"

        # Create an Instrument object
        instrument = Instrument(
            parts[1],                # name
            parse(Int, parts[2]),     # code
            parts[3],                # mnemonic
            parse(Float64, parts[4]), # latitude
            parse(Float64, parts[5]), # longitude
            parse(Float64, parts[6]), # altitude
            category                  # category
        )

        push!(instruments, instrument)
    end

    return instruments
end

get_all_instruments(server::Server = Default_server[]) = get_all_instruments(get_url(server))
