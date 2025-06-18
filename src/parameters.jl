@concrete terse struct Parameter
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

"""
    Parameter

A struct that encapsulates information about a Madrigal parameter.

Similar to the `MadrigalParameter` class in the madrigalWeb python module.
"""
Parameter

function Base.show(io::IO, ::MIME"text/plain", param::Parameter)
    println(io, "Parameter(")
    for field in fieldnames(Parameter)
        println(io, "  $(field): $(getfield(param, field))")
    end
    return print(io, ")")
end


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
function get_experiment_file_parameters(file, server = Default_server[])
    script_name = "getParametersService.py"
    url = rstrip(get_url(server), '/') * "/" * script_name
    query = Dict("filename" => String(file))
    response = HTTP.get(url; query)
    lines = process_response(response)

    # Parse the result into Parameter objects
    parameters = Parameter[]

    for line in lines
        parts = split(line, "\\")
        if length(parts) < 7
            continue
        end

        # Extract the isAddIncrement if available
        is_add_increment = length(parts) > 7 ? parse(Int, parts[8]) : -1

        # Create a Parameter object
        parameter = Parameter(
            parts[1],                # mnemonic
            parts[2],                # description
            parse(Bool, parts[3]),    # is_error
            parts[4],                # units
            parse(Bool, parts[5]),    # is_measured
            parts[6],                # category
            parse(Bool, parts[7]),    # is_sure
            is_add_increment         # is_add_increment
        )

        push!(parameters, parameter)
    end

    return parameters
end
