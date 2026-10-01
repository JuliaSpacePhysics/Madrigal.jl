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
get_metadata(id; server = Default_server[]) =
    CSV.File(cached_get(metadata_url(id, server)); header = false, CSV_QUIET...)

metadata_url(id, server) = get_url(server) * "/getMetadata?fileType=$(get(METADATA_TYPES, id, id))"

# Memoized tables sit on top of the disk cache, so a refresh has to bypass both
function _load_metadata(parse, id, server, update)
    server_url = get_url(server)
    if update
        empty_cache!(parse)
        cached_get(metadata_url(id, server_url); max_age_days = 0)
    end
    return parse(server_url)
end

"""
    clear_metadata_cache!()

Clear all cached metadata, in memory and on disk. Useful when the server data has been updated.
"""
function clear_metadata_cache!()
    empty_cache!(_get_instruments_cached)
    empty_cache!(_get_experiments_cached)
    empty_cache!(_get_files_cached)
    rm(default_cache_dir(); recursive = true, force = true)
    return nothing
end
