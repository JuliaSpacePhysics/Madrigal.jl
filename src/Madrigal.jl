module Madrigal
using Dates
using TOML
using HTTP
using ConcreteStructs
import Base: basename, getproperty

include("types.jl")
include("utils.jl")
include("instruments.jl")
include("experiments.jl")
include("parameters.jl")

const Default_url = Ref("https://cedar.openmadrigal.org/")
const Default_server = Ref{Server}(Server("https://cedar.openmadrigal.org/"))
const Default_dir = Ref{String}()
const User_name = Ref("Madrigal.jl")
const User_email = Ref("")
const User_affiliation = Ref("Madrigal.jl")

export filter_by_kindat
export get_all_instruments
export get_experiments, get_experiment_files
export get_experiment_file_parameters
export download_file, download_files

function __init__()
    # Check for .Madrigal.cfg in the user's home directory
    cfg_path = joinpath(homedir(), ".Madrigal.cfg")
    if isfile(cfg_path)
        try
            config = TOML.parsefile(cfg_path)
            # Set user information from config
            set_default_from_config!(config)
        catch e
            @warn "Error reading .Madrigal.cfg: $e"
        end
    end
    return isdefined(Default_dir, :x) || (Default_dir[] = mktempdir())
end

get_url(url) = url
get_url(server::Server) = server.url

set_ref!(ref, c, key) = haskey(c, key) && (ref[] = c[key])

function set_default_from_config!(c)
    haskey(c, "url") && begin
        Default_url[] = c["url"]
        Default_server[] = Server(c["url"])
    end
    set_ref!(Default_dir, c, "dir")
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


_compat(x::DateTime) = x
_compat(x::String) = DateTime(x)

get_kindat(exp) = exp.kindat
get_kindatdesc(exp) = exp.kindatdesc

"""
    download_files(inst, kindat, t0, t1; kws...)

Download files for a given instrument code `inst`, data code `kindat`, and time range `t0` to `t1`.
"""
function download_files(inst, kindat, t0, t1; server = Default_server[], kws...)
    exps = get_experiments(inst, t0, t1; server)
    files = mapreduce(vcat, exps) do exp
        get_experiment_files(exp; server)
    end
    files = filter_by_kindat(files, kindat)
    return map(files) do file
        download_file(file; server, kws...)
    end
end

const fileTypes = Dict("hdf5" => -2, "simple" => -1, "netCDF4" => -3)

# MadrigalData Class
"""
`throw` controls whether to throw or silently return `nothing` on request error
"""
function download_file(
        file, destination = nothing;
        dir = Default_dir[], format = "hdf5", server = Default_server[],
        name = User_name[], email = User_email[], affiliation = User_affiliation[],
        verbose = false, throw = false
    )
    mkpath(dir)
    path = @something destination joinpath(dir, basename(file))
    if isfile(path)
        return path
    else
        filename = String(file)
        @info "Downloading $filename to $path"
        fileType = get(fileTypes, format, 4)
        query = Dict(
            "fileName" => filename,
            "fileType" => string(fileType),
            "user_fullname" => name,
            "user_email" => email,
            "user_affiliation" => affiliation
        )
        verbose && @info "Downloading $filename to $path"
        url = rstrip(get_url(server), '/') * "/getMadfile.cgi"
        try
            HTTP.download(url, path; query)
        catch e
            @warn "Failed to download file: $(sprint(showerror, e))"
            if isfile(path)
                rm(path)
                verbose && @warn "Removed incomplete download: $path"
            end
            throw ? rethrow() : nothing
        end
    end
end

"""
    filter_by_kindat(expFileList, kindat)

Returns a subset of the experiment files in expFileList whose kindat is found in kindat argument.
"""
function filter_by_kindat(expFileList, kindat)
    return filter(expFileList) do expFile
        get_kindat(expFile) in kindat
    end
end
end
