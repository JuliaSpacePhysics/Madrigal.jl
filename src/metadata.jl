"""
Metadata access functions for direct access to OpenMadrigal consolidated metadata files.

Results are automatically cached based on server URL.

# openmadrigal/madroot/source/madpy/djangoMad/madweb/templates/madweb/madrigal/metadata.m.html
"""

const METADATA_TYPES = Dict(
    :experiments => 0,    # expTab.txt
    :files => 1,         # fileTab.txt
    :instruments => 3,   # instTab.txt
    :parameters => 4,    # parmCodes.txt
    :sites => 5,         # siteTab.txt
    :datatypes => 6,     # typeTab.txt
    :inst_kindats => 7,  # instKindatTab.txt
    :inst_parms => 8,    # instParmTab.txt
    :categories => 9,    # madCatTab.txt
    :inst_types => 10    # instType.txt
)

"""
    get_metadata(id; server = Default_server[])::CSV.File

Get consolidated metadata file from OpenMadrigal server.

# Example
```julia
# Get all experiments
get_metadata(:experiments)

# Get all files  
get_metadata(:files)
```
"""
function get_metadata(id; server = Default_server[])
    server_url = get_url(server)
    url = server_url * "/getMetadata?fileType=$(get(METADATA_TYPES, id, id))"
    data = cached_get(url)
    header = false
    return CSV.File(data; header, stringtype = PosLenString, silencewarnings = true)
end

"""
    clear_metadata_cache!()

Clear all cached metadata results. Useful when the server data has been updated.
"""
function clear_metadata_cache!()
    Memoization.empty_cache!(_get_instruments_cached)
    Memoization.empty_cache!(_get_experiments_cached)
    Memoization.empty_cache!(_get_files_cached)
    return nothing
end
