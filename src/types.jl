abstract type AbstractMadrigalObject end

struct Server
    url::String
end

Base.String(server::Server) = server.url

function Base.show(io::IO, ::MIME"text/plain", x::T) where {T <: AbstractMadrigalObject}
    println(io, "$(nameof(T))(")
    for field in fieldnames(T)
        println(io, "  $(field): ", _show(x, field))
    end
    return print(io, ")")
end

@inline _show(x, field) = getfield(x, field)
