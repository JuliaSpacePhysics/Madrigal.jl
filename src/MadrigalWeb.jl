"""

A Julia API to access the Madrigal database.

Reference:

- [Madrigal Database Documentation](https://cedar.openmadrigal.org/docs/name/madContents.html)
- [madrigalWeb](https://github.com/MITHaystack/madrigalWeb): a python API to access the Madrigal database
"""
module MadrigalWeb

# Write your package code here.
using PythonCall
using PythonCall: pynew
using Dates
using TOML
using HTTP
import Base: basename, getproperty

include("types.jl")

const madrigalWeb = pynew()
const MadrigalData = pynew()
const Default_url = Ref("https://cedar.openmadrigal.org/")
const Default_server = Ref{Server}()
const User_name = Ref("MadrigalWeb.jl")
const User_email = Ref("")
const User_affiliation = Ref("MadrigalWeb.jl")

export MadrigalData
export download_file, download_files
export get_experiments
export getExperiments, get_exp_filesExperimentFiles
export filter_by_kindat

function __init__()
    PythonCall.pycopy!(madrigalWeb, pyimport("madrigalWeb.madrigalWeb"))
    PythonCall.pycopy!(MadrigalData, pyimport("madrigalWeb.madrigalWeb").MadrigalData)

    # Check for .Madrigal.cfg in the user's home directory
    cfg_path = joinpath(homedir(), ".Madrigal.cfg")
    if isfile(cfg_path)
        try
            config = TOML.parsefile(cfg_path)
            # Set user information from config
            haskey(config, "user_name") && (User_name[] = config["user_name"])
            haskey(config, "user_email") && (User_email[] = config["user_email"])
            haskey(config, "user_affiliation") && (User_affiliation[] = config["user_affiliation"])
            haskey(config, "url") && (Default_url[] = config["url"])
        catch e
            @warn "Error reading .Madrigal.cfg: $e"
        end
    end
end

get_url(url) = url
get_url(server::Py) = pyconvert(String, server.cgiurl)
get_url(server::Server) = server.url

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

get_kindat(exp) = pyconvert(Int, exp.kindat)
get_kindatdesc(exp) = pyconvert(String, exp.kindatdesc)

function download_files(inst, kindat, t0, t1; dir="./data",
    server=nothing, user_fullname=User_name[], user_email=User_email[],
    user_affiliation=User_affiliation[], verbose=false
)
    server = something(server, Default_server[])
    t0, t1 = _compat(t0), _compat(t1)
    exps = getExperiments(server, inst, t0, t1)
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
    dir="./data", format="hdf5", url=Default_url[],
    name=User_name[], email=User_email[], affiliation=User_affiliation[],
    verbose=false, throw=false
)
    mkpath(dir)
    path = @something destination joinpath(dir, basename(filename))
    isfile(path) ? path : begin
        fileType = get(fileTypes, format, 4)
        query = Dict(
            "fileName" => filename,
            "fileType" => string(fileType),
            "user_fullname" => name,
            "user_email" => email,
            "user_affiliation" => affiliation
        )
        verbose && @info "Downloading $filename to $path"
        url = rstrip(url, '/') * "/getMadfile.cgi"
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

function getExperiments(server, code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    server.getExperiments(code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
end

function get_experiments(server, code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    query = (; code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    url = rstrip(get_url(server), '/') * "/getExperimentsService.py"
    response = HTTP.get(url, query=query)
    lines = split(String(response.body), "\n")
    map(lines) do line
        split(line, ",")
    end
end


function getExperiments(server, code, t0, t1)
    t0 = Dates.DateTime(t0)
    t1 = Dates.DateTime(t1)
    startyear, startmonth, startday, starthour, startmin, startsec = Dates.year(t0), Dates.month(t0), Dates.day(t0), Dates.hour(t0), Dates.minute(t0), Dates.second(t0)
    endyear, endmonth, endday, endhour, endmin, endsec = Dates.year(t1), Dates.month(t1), Dates.day(t1), Dates.hour(t1), Dates.minute(t1), Dates.second(t1)
    server.getExperiments(code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
end


function get_exp_files(server, id::Integer; getNonDefault=false)
    map(ExperimentFile, server.getExperimentFiles(id, getNonDefault))
end

get_exp_files(server, exp; kw...) = map(ExperimentFile, server.getExperimentFiles(exp.id; kw...))

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
