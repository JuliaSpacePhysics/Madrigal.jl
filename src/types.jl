abstract type AbstractMadrigalObject end

struct Server
    url::String
end

"""
A class that encapsulates information about a Madrigal Experiment.

Similar to the `MadrigalExperiment` class in the madrigalWeb python module.
"""
struct Experiment{O} <: AbstractMadrigalObject
    id::Int
    others::O
end

"""
    Instrument

A struct that encapsulates information about a Madrigal Instrument.

# Fields
- `name`: Instrument name (e.g., 'Millstone Hill Incoherent Scatter Radar')
- `code`: Instrument code (e.g., 30)
- `mnemonic`: Three-character mnemonic (e.g., 'mlh')
- `latitude`: Instrument latitude in degrees
- `longitude`: Instrument longitude in degrees
- `altitude`: Instrument altitude in km
- `category`: Instrument category (e.g., 'Incoherent Scatter Radars')

Similar to the `MadrigalInstrument` class in the madrigalWeb python module.
"""
struct Instrument <: AbstractMadrigalObject
    name::String
    code::Int
    mnemonic::String
    latitude::Float64
    longitude::Float64
    altitude::Float64
    category::String
end

function Base.show(io::IO, ::MIME"text/plain", x::T) where {T <: AbstractMadrigalObject}
    println(io, "$T(")
    for field in fieldnames(T)
        println(io, "  $(field): $(getfield(x, field))")
    end
    return print(io, ")")
end
