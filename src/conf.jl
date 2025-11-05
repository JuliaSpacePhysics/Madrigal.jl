const CEDAR_URL = "https://cedar.openmadrigal.org/"
const Default_url = Ref(CEDAR_URL)
const Default_server = Ref{Server}(Server(CEDAR_URL))
const Default_dir = Ref{String}()
const User_name = Ref("Madrigal.jl")
const User_email = Ref("")
const User_affiliation = Ref("Madrigal.jl")

set_ref!(ref, c, key) = haskey(c, key) && (ref[] = c[key])

function parse_dir(dir)
    startswith(dir, "~") && (dir = replace(dir, "~" => homedir(), count = 1))
    return dir
end

function set_default_from_config!(c)
    haskey(c, "url") && begin
        Default_url[] = c["url"]
        Default_server[] = Server(c["url"])
    end
    haskey(c, "dir") && (Default_dir[] = parse_dir(c["dir"]))
    set_ref!(User_name, c, "user_name")
    set_ref!(User_email, c, "user_email")
    return set_ref!(User_affiliation, c, "user_affiliation")
end

function set_default_server(url = nothing)
    url = rstrip(something(url, Default_url[]), '/')
    isdefined(Default_server, :x) || return setindex!(Default_server, Server(url))
    get_url(Default_server[]) == url && return Default_server[]
    return setindex!(Default_server, Server(url))
end

function set_default_user(name, email, affiliation = nothing)
    User_name[] = name
    User_email[] = email
    return isnothing(affiliation) || (User_affiliation[] = affiliation)
end
