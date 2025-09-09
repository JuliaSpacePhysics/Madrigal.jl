```@meta
CurrentModule = Madrigal
```

# Madrigal

Documentation for [Madrigal](https://github.com/juliaspacephysics/Madrigal.jl).

A Julia API to access the [Madrigal database](https://cedar.openmadrigal.org/): an upper atmospheric science database.

```@index

```

## Quickstart

```@example
using Madrigal
using Dates
using PrettyTables

# Get instruments
instruments = get_instruments()
pretty_table(instruments)

# Get experiments for Millstone Hill radar in 2020
experiments = get_experiments(30, Date(2020, 1, 1), Date(2020, 12, 31))
pretty_table(experiments)

# Get files for an experiment
files = get_experiment_files(experiments[1])
pretty_table(files)
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

## API Reference

```@autodocs
Modules = [Madrigal]
```
