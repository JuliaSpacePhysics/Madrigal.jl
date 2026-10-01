get_url(url) = rstrip(url, '/')
get_url(server::Server) = get_url(server.url)

function _isweb(source)
    source in (:web, :cache) || throw(ArgumentError("source must be :web or :cache, got $(repr(source))"))
    return source === :web
end

# HTTP 2 dropped NamedTuple queries and caps decompressed bodies at 64 MB
_query(q::NamedTuple) = [string(k) => string(v) for (k, v) in pairs(q)]
_query(q) = q

const HTTP_LIMITS = @static if pkgversion(HTTP) >= v"2"
    (; max_decompressed_size=typemax(Int))
else
    (;)
end

# Madrigal spells booleans as 1/0, which CSV does not accept by default
const CSV_BOOL = (; truestrings = ["1"], falsestrings = ["0"])

const CSV_QUIET = @static if pkgversion(CSV) >= v"1"
    (; on_error = :collect)
else
    (; silencewarnings = true)
end

# Resolved at runtime: a const would bake the precompiling machine's home/ENV into the image
function default_cache_dir()
    return if Sys.iswindows()
        joinpath(get(ENV, "LOCALAPPDATA", homedir()), "Madrigal", "Cache")
    elseif Sys.isapple()
        joinpath(homedir(), "Library", "Caches", "Madrigal")
    else
        joinpath(get(ENV, "XDG_CACHE_HOME", joinpath(homedir(), ".cache")), "madrigal")
    end
end

"""
    cached_get(url; max_age_days=7, cache_dir=default_cache_dir(), kw...)

Get URL with persistent disk caching. 

Cache files are stored in `cache_dir` and expire after `max_age_days` days (default: 7).
Since the Madrigal server doesn't provide Last-Modified headers, we rely on age-based expiration.
"""
function cached_get(url; max_age_days=7, cache_dir=default_cache_dir(), kw...)
    isdir(cache_dir) || mkpath(cache_dir)
    filename = string(hash(url), base=16)
    cache_file = joinpath(cache_dir, filename)

    # Check if cache file exists and is recent enough
    if isfile(cache_file)
        file_age = time() - stat(cache_file).mtime
        if file_age < max_age_days * 24 * 3600  # Convert days to seconds
            return IOBuffer(read(cache_file))
        end
    end

    # Download and cache
    response = HTTP.get(url; HTTP_LIMITS..., kw...)
    write(cache_file, response.body)
    return IOBuffer(response.body)
end
