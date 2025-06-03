"""

A Julia API to access the Madrigal database.

Reference:

- [Madrigal Database Documentation](https://cedar.openmadrigal.org/docs/name/madContents.html)
- [madrigalWeb](https://github.com/MITHaystack/madrigalWeb): a python API to access the Madrigal database
"""
module MadrigalWeb

# Write your package code here.
using Dates
using TOML
using HTTP
import Base: basename, getproperty

include("types.jl")

const Default_url = Ref("https://cedar.openmadrigal.org/")
const Default_server = Ref{Server}()
const Default_dir = Ref{String}()
const User_name = Ref("MadrigalWeb.jl")
const User_email = Ref("")
const User_affiliation = Ref("MadrigalWeb.jl")

export download_file, download_files
export get_experiments, get_exp_files
export filter_by_kindat

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
    isdefined(Default_dir, :x) || (Default_dir[] = mktempdir())
end

get_url(url) = url
get_url(server::Server) = server.url

set_ref!(ref, c, key) = haskey(c, key) && (ref[] = c[key])

function set_default_from_config!(c)
    set_ref!(Default_url, c, "url")
    set_ref!(Default_dir, c, "dir")
    set_ref!(User_name, c, "user_name")
    set_ref!(User_email, c, "user_email")
    set_ref!(User_affiliation, c, "user_affiliation")
end

function set_default_server(url=nothing)
    url = rstrip(something(url, Default_url[]), '/')
    isdefined(Default_server, :x) || return setindex!(Default_server, Server(url))
    get_url(Default_server[]) == url && return Default_server[]
    return setindex!(Default_server, Server(url))
end

function set_default_user(name, email, affiliation=nothing)
    User_name[] = name
    User_email[] = email
    isnothing(affiliation) || (User_affiliation[] = affiliation)
end


_compat(x::DateTime) = x
_compat(x::String) = DateTime(x)

get_kindat(exp) = exp.kindat
get_kindatdesc(exp) = exp.kindatdesc

function download_files(inst, kindat, t0, t1; dir=Default_dir[],
    server=nothing, user_fullname=User_name[], user_email=User_email[],
    user_affiliation=User_affiliation[], verbose=false
)
    server = something(server, Default_server[])
    exps = get_experiments(server, inst, t0, t1)
    files = mapreduce(vcat, exps) do exp
        get_exp_files(server, exp)
    end
    files = filter_by_kindat(files, kindat)
    mkpath(dir)
    map(files) do file
        download_file(file, server; dir, user_fullname, user_email, user_affiliation)
    end
end

const fileTypes = Dict("hdf5" => -2, "simple" => -1, "netCDF4" => -3)

# MadrigalData Class
"""
`throw` controls whether to throw or silently return `nothing` on request error
"""
function download_file(filename, destination=nothing;
    dir=Default_dir[], format="hdf5", server=Default_server[],
    name=User_name[], email=User_email[], affiliation=User_affiliation[],
    verbose=false, throw=false
)
    mkpath(dir)
    path = @something destination joinpath(dir, basename(filename))
    if isfile(path)
        return path
    else
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

download_file(expFile::ExperimentFile, args...; kw...) = download_file(expFile.name, args...; kw...)

function get_experiments(server, code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    query = (; code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    url = rstrip(get_url(server), '/') * "/getExperimentsService.py"
    response = HTTP.get(url, query=query)
    lines = filter!(!isempty, split(String(response.body), "\n"))
    map(lines) do line
        parts = split(line, ",")
        id = parse(Int, parts[1])
        Experiment(id, parts[2:end])
    end
end

function decompose_datetime(t::DateTime)
    Dates.year(t), Dates.month(t), Dates.day(t), Dates.hour(t), Dates.minute(t), Dates.second(t)
end

decompose_datetime(t) = decompose_datetime(Dates.DateTime(t))

get_experiments(server, code, t0, t1) = get_experiments(
    server, code,
    decompose_datetime(t0)...,
    decompose_datetime(t1)...
)

"""
    Get a list of all default MadrigalExperimentFiles for a given experiment `exp`.
"""
function get_exp_files(server, exp; getNonDefault=false)
    url = rstrip(get_url(server), '/') * "/getExperimentFilesService.py"
    response = HTTP.get(url, query=(; id=exp.id, getNonDefault))
    lines = filter!(!isempty, split(String(response.body), "\n"))
    map(lines) do line
        parts = split(line, ",")
        ExperimentFile(parts[1], parse(Int, parts[2]), parts[3:end])
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
