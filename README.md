# Madrigal.jl

[![Build Status](https://github.com/juliaspacephysics/Madrigal.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/juliaspacephysics/Madrigal.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/juliaspacephysics/Madrigal.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/juliaspacephysics/Madrigal.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia API to access the [Madrigal database](https://cedar.openmadrigal.org/): an upper atmospheric science database.

**Installation**: at the Julia REPL, run `using Pkg; Pkg.add("Madrigal")`

**Documentation**: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSpacePhysics.github.io/Madrigal.jl/dev/)

## Examples

```julia
using Madrigal
using Dates

# Get instruments (fast cached access by default)
insts = get_instruments()

kinst = 30 # "Millstone Hill IS Radar"
kindat = 3408 # "Combined basic parameters file - all antennas and modes"
tstart = Date(1998, 1, 19)
tend = Date(1998, 12, 31)

# Get experiments (cached by default, use source=:web for latest data)
exps = get_experiments(kinst, tstart, tend)
files = get_experiment_files(exps[1])
file = filter(f -> f.kindat == kindat, files)[1]
params = get_experiment_file_parameters(file)
path = download_file(file)
```

You can also query / download files given the instrument id (`kinst`), kind of data file code (`kindat`), and time range `tstart` to `tend`. See [Madrigal instrument metadata](https://cedar.openmadrigal.org/instMetadata) for a list of `kinst` and [Madrigal kind of data file types metadata](https://cedar.openmadrigal.org/kindatMetadata) for a list of `kindat`.

```julia
get_instrument_files(kinst, tstart, tend)
files = get_instrument_files(kinst, kindat, tstart, tend)
download_file.(files)
# or
download_files(kinst, kindat, "1998-01-18", "1998-01-22")
```

## Data Access

`Madrigal.jl` provides two data access methods:

- **Cached (default)**: Fast access using cached metadata files (the metadata files are downloaded, parsed, and cached on first use)
- **Web service**: Live access to latest data

```julia
# Fast cached access (default)
get_instruments()
get_experiments(30, Date(2020, 1, 1), Date(2020, 12, 31))

# Alternative via web service
get_instruments(source=:web) 
get_experiments(30, Date(2020, 1, 1), Date(2020, 12, 31), source=:web)
```

## Notes

> Madrigal data are arranged into "experiments", which may contain data files, images, documentation, links, etc.

## References and Elsewhere

- [Madrigal Database Documentation](https://cedar.openmadrigal.org/docs/name/madContents.html)
- [madrigalWeb](https://github.com/MITHaystack/madrigalWeb): a (official) python API to access the Madrigal database
- [pysatMadrigal](https://github.com/pysat/pysatMadrigal) allows importing Madrigal data sets into the `pysat` ecosystem. However, it only supports a few data sets and is not general purpose.
