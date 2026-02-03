"""Python wrapper for Madrigal.jl."""

from juliacall import Main as jl

# Load the Julia package
jl.seval("using Madrigal")

# Re-export Julia functions
get_instruments = jl.Madrigal.get_instruments
get_experiments = jl.Madrigal.get_experiments
get_experiment_files = jl.Madrigal.get_experiment_files
get_experiment_file_parameters = jl.Madrigal.get_experiment_file_parameters
download_file = jl.Madrigal.download_file
download_files = jl.Madrigal.download_files
get_metadata = jl.Madrigal.get_metadata

# Configuration functions
set_default_server = jl.Madrigal.set_default_server
set_default_user = jl.Madrigal.set_default_user
clear_metadata_cache = jl.Madrigal.clear_metadata_cache_b

# Server constructor
Server = jl.Madrigal.Server

__all__ = [
    "get_instruments",
    "get_experiments",
    "get_experiment_files",
    "get_experiment_file_parameters",
    "download_file",
    "download_files",
    "get_metadata",
    "set_default_server",
    "set_default_user",
    "clear_metadata_cache",
    "Server",
    "jl",
]
