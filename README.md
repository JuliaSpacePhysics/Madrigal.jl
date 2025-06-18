# MadrigalWeb

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Beforerr.github.io/MadrigalWeb.jl/dev/)
[![Build Status](https://github.com/Beforerr/MadrigalWeb.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/MadrigalWeb.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Beforerr/MadrigalWeb.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Beforerr/MadrigalWeb.jl)

A Julia API to access the Madrigal database.

```julia
using MadrigalWeb

download_files(8100, 10216, "2000-01-01", "2000-01-02")
```

## Configuration Options

`MadrigalWeb.jl` offers two ways to configure your settings:

### Option 1: Using API Functions

You can programmatically set configuration values in your code:

```julia
using MadrigalWeb
using Dates

# Set the default server URL
MadrigalWeb.set_default_server("https://cedar.openmadrigal.org")

# Set user information
MadrigalWeb.set_default_user("Your Name", "your.email@example.com", "Your Institution")
```

### Option 2: Using a Configuration File

Alternatively, you can create a TOML configuration file at `~/.Madrigal.cfg` before using `MadrigalWeb.jl` with the following options:

```toml
url = "https://cedar.openmadrigal.org" # Default Server URL is https://cedar.openmadrigal.org

# Directory for downloaded files (optional)
dir = "/path/to/download/directory"

# User information
user_name = "Your Name" # Default User Name is "MadrigalWeb.jl"
user_email = "your.email@example.com" # Default User Email is ""
user_affiliation = "Your Institution" # Default User Affiliation is "MadrigalWeb.jl"
```

If the configuration file is not found or cannot be parsed, default values will be used.
