# Madrigal.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaspacephysics.github.io/Madrigal.jl/dev/)
[![Build Status](https://github.com/juliaspacephysics/Madrigal.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/juliaspacephysics/Madrigal.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/juliaspacephysics/Madrigal.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/juliaspacephysics/Madrigal.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia API to access the [Madrigal database](https://cedar.openmadrigal.org/): an upper atmospheric science database.

## Examples

```julia
using Madrigal
using Dates

insts = get_all_instruments()

kinst = 30 # "Millstone Hill IS Radar"
kindat = 3408 # "Combined basic parameters file - all antennas and modes"
tstart = Date(1998, 1, 19)
tend = Date(1998, 12, 31)

exps = get_experiments(kinst, tstart, tend)
files = get_experiment_files(exps[1])
file = filter_by_kindat(files, kindat)[1]
params = get_experiment_file_parameters(file)
path = download_file(file)
```

You can also download files given the instrument id (`kinst`), kind of data file code (`kindat`), and time range `tstart` to `tend`. See [Madrigal instrument metadata](https://cedar.openmadrigal.org/instMetadata) for a list of `kinst` and [Madrigal site metadata](https://cedar.openmadrigal.org/kindatMetadata) for a list of `kindat`.

```julia
download_files(kinst, kindat, "1998-01-18", "1998-01-22")
```

## Configuration Options

`Madrigal.jl` offers two ways to configure your settings:

### Option 1: Using API Functions

You can programmatically set configuration values in your code:

```julia
using Madrigal
using Dates

# Set the default server URL
Madrigal.set_default_server("https://cedar.openmadrigal.org")

# Set user information
Madrigal.set_default_user("Your Name", "your.email@example.com", "Your Institution")
```

### Option 2: Using a Configuration File

Alternatively, you can create a TOML configuration file at `~/.Madrigal.cfg` before using `Madrigal.jl` with the following options:

```toml
url = "https://cedar.openmadrigal.org" # Default Server URL is https://cedar.openmadrigal.org

# Directory for downloaded files (optional, default is a temporary directory)
dir = "/path/to/download/directory"

# User information
user_name = "Your Name" # Default User Name is "Madrigal.jl"
user_email = "your.email@example.com" # Default User Email is ""
user_affiliation = "Your Institution" # Default User Affiliation is "Madrigal.jl"
```

If the configuration file is not found or cannot be parsed, default values will be used.

## Notes

> Madrigal data are arranged into "experiments", which may contain data files, images, documentation, links, etc.

## References and Elsewhere

- [Madrigal Database Documentation](https://cedar.openmadrigal.org/docs/name/madContents.html)
- [madrigalWeb](https://github.com/MITHaystack/madrigalWeb): a (official) python API to access the Madrigal database
- [pysatMadrigal](https://github.com/pysat/pysatMadrigal) allows importing Madrigal data sets into the `pysat` ecosystem. However, it only supports a few data sets and is not general purpose.
