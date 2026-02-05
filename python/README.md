# Madrigal

Python wrapper for [Madrigal.jl](https://github.com/JuliaSpacePhysics/Madrigal.jl) - access the Madrigal upper atmospheric science database from Python.

## Installation

```bash
pip install madrigal-jl
```

The Julia package installs automatically on first use.

## Usage

```python
import madrigal

# Get all instruments
instruments = madrigal.get_instruments()

# Get experiments for Millstone Hill radar (kinst=30)
experiments = madrigal.get_experiments(30, "2020-01-01", "2020-01-31")

# Get files from an experiment
files = madrigal.get_experiment_files(experiments[0])

# Download a file
path = madrigal.download_file(files[0])
```

## Configuration

```python
madrigal.set_default_server("https://cedar.openmadrigal.org")
madrigal.set_default_user("Your Name", "email@example.com", "Institution")
```

## API

All functions from Madrigal.jl are available:

- `get_instruments(server=None, source=:cache)`
- `get_experiments(code, t0, t1, server=None, source=:cache)`
- `get_experiment_files(experiment, server=None, source=:cache)`
- `get_experiment_file_parameters(file, server=None)`
- `download_file(file, destination=None, format=:hdf5, ...)`
- `download_files(inst, kindat, t0, t1, ...)`
- `get_metadata(id, server=None)`

See the [Madrigal.jl documentation](https://juliaspacePhysics.github.io/Madrigal.jl) for full details.
