module Madrigal
using Dates
using TOML
using HTTP
using CSV
using ConcreteStructs
using Memoization
using Memoization: empty_cache!
import Base: getproperty

include("types.jl")
include("utils.jl")
include("name_mapping.jl")
include("instruments.jl")
include("experiments.jl")
include("file.jl")
include("parameters.jl")
include("metadata.jl")
include("conf.jl")
include("download.jl")

export get_metadata
export get_instruments
export get_experiments, get_experiment_files, get_instrument_files
export get_experiment_file_parameters
export download_file, download_files
export Server
export clear_metadata_cache!

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

"""
    get_instrument_files(inst, [kindat], t0, t1; server = Default_server[])

Get all experiment files for a given instrument `inst` (code or common name) and time range `t0` to `t1`, optionally filtered by data code `kindat`.
"""
function get_instrument_files(inst, t0, t1; server = Default_server[])
    exps = get_experiments(kinst(inst), t0, t1; server)
    exp_ids = Set(exp.id for exp in exps)
    return get_experiment_files_cached(server, exp_ids)
end

function get_instrument_files(kinst, kindat, t0, t1; server = Default_server[])
    files = get_instrument_files(kinst, t0, t1; server)
    return isempty(files) ? files : filter(f -> f.kindat in kindat, files)
end

end
