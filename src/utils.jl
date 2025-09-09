get_url(url; clean = true) = clean ? rstrip(url, '/') : url
get_url(server::Server; kw...) = get_url(server.url; kw...)

@memoize function cached_get(url; kw...)
    response = HTTP.get(url; kw...)
    return IOBuffer(response.body)
end

function decompose_datetime(t::DateTime)
    return year(t), month(t), day(t), hour(t), minute(t), second(t)
end

decompose_datetime(t) = decompose_datetime(DateTime(t))
