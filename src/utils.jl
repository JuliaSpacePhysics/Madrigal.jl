function decompose_datetime(t::DateTime)
    return year(t), month(t), day(t), hour(t), minute(t), second(t)
end

decompose_datetime(t) = decompose_datetime(DateTime(t))


function process_response(response::HTTP.Response)
    if response.status != 200
        error("Failed to get parameters: HTTP status $(response.status)")
    end
    body = String(response.body)
    # Check for errors in the response
    occursin("Error occurred", body) && error("Error with request: $(response.request)")
    return filter!(!isempty, split(body, "\n"))
end
