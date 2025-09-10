get_url(url; clean = true) = clean ? rstrip(url, '/') : url
get_url(server::Server; kw...) = get_url(server.url; kw...)

const CACHE_DIR = @static if Sys.iswindows()
    # Windows: %LOCALAPPDATA%\Madrigal\Cache
    joinpath(get(ENV, "LOCALAPPDATA", homedir()), "Madrigal", "Cache")
elseif Sys.isapple()
    # macOS: ~/Library/Caches/Madrigal
    joinpath(homedir(), "Library", "Caches", "Madrigal")
else
    # Linux/Unix: ~/.cache/madrigal (XDG Base Directory)
    xdg_cache = get(ENV, "XDG_CACHE_HOME", joinpath(homedir(), ".cache"))
    joinpath(xdg_cache, "madrigal")
end

"""
    cached_get(url; max_age_days=7, cache_dir=CACHE_DIR, kw...)

Get URL with persistent disk caching. 

Cache files are stored in `cache_dir` and expire after `max_age_days` days (default: 7).
Since the Madrigal server doesn't provide Last-Modified headers, we rely on age-based expiration.
"""
function cached_get(url; max_age_days = 7, cache_dir = CACHE_DIR, kw...)
    isdir(cache_dir) || mkpath(cache_dir)
    filename = string(hash(url), base = 16)
    cache_file = joinpath(cache_dir, filename)

    # Check if cache file exists and is recent enough
    if isfile(cache_file)
        file_age = time() - stat(cache_file).mtime
        if file_age < max_age_days * 24 * 3600  # Convert days to seconds
            return IOBuffer(read(cache_file))
        end
    end

    # Download and cache
    response = HTTP.get(url; kw...)
    write(cache_file, response.body)
    return IOBuffer(response.body)
end

function decompose_datetime(t::DateTime)
    return year(t), month(t), day(t), hour(t), minute(t), second(t)
end

decompose_datetime(t) = decompose_datetime(DateTime(t))
