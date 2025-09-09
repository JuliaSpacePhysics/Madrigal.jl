@concrete terse struct Parameter <: AbstractMadrigalObject
    "Parameter mnemonic (e.g., 'dti')"
    mnemonic
    description
    "Whether this is an error parameter (1 if error, 0 if not)"
    is_error::Bool
    units
    "Whether this is a measured parameter (1 if measured, 0 if derivable)"
    is_measured::Bool
    "Parameter category (e.g., \"Time Related Parameter\")"
    category
    "Whether parameter can be found for every record (1 if sure, 0 if not)"
    is_sure::Bool
    "Whether this is an additional increment (1 if yes, 0 if normal, -1 if unknown)"
    is_add_increment::Int
end


function _show(x::Parameter, field)
    if field == :is_measured
        return getfield(x, field) ? "1 (measured)" : "0 (derivable)"
    elseif field == :is_error
        return getfield(x, field) ? "1 (error parameter)" : "0"
    elseif field == :is_sure
        return getfield(x, field) ? "1 (found for every record)" : "0 (not found for every record)"
    else
        return getfield(x, field)
    end
end

"""
    Parameter

A struct that encapsulates information about a Madrigal parameter.

Similar to the `MadrigalParameter` class in the madrigalWeb python module.
"""
Parameter

"""
    get_experiment_file_parameters(file, url)
    get_experiment_file_parameters(file, server::Server = Default_server[])

Returns a list of all measured and derivable parameters in the given experiment `file`.

# Examples
```julia
# Get parameters for a specific file
file = first(get_experiment_files(experiment))
parameters = get_experiment_file_parameters(file)
```

Similar to the `getExperimentFileParameters` method in the madrigalWeb python module.
"""
function get_experiment_file_parameters(file; server = Default_server[])
    url = get_url(server) * "/getParametersService.py"
    query = (; filename = filename(file))
    response = HTTP.get(url; query)

    header = [:mnemonic, :description, :is_error, :units, :is_measured, :category, :is_sure, :is_add_increment]
    types = IdDict(:is_error => Bool, :is_measured => Bool, :is_sure => Bool)
    return CSV.File(response.body; header, types, stringtype = PosLenString, delim = '\\')
end
