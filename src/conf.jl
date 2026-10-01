const CEDAR_URL = "https://cedar.openmadrigal.org"
const Default_server = Ref(Server(CEDAR_URL))
const Default_dir = Ref{String}()
const User_name = Ref("Madrigal.jl")
const User_email = Ref("")
const User_affiliation = Ref("Madrigal.jl")

set_ref!(ref, c, key) = haskey(c, key) && (ref[] = c[key])

function set_default_from_config!(c)
    haskey(c, "url") && set_default_server(c["url"])
    haskey(c, "dir") && (Default_dir[] = expanduser(c["dir"]))
    set_ref!(User_name, c, "user_name")
    set_ref!(User_email, c, "user_email")
    return set_ref!(User_affiliation, c, "user_affiliation")
end

set_default_server(url = CEDAR_URL) = Default_server[] = Server(get_url(url))

function set_default_user(name, email, affiliation = nothing)
    User_name[] = name
    User_email[] = email
    return isnothing(affiliation) || (User_affiliation[] = affiliation)
end
