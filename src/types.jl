
abstract type PyObj end

struct Server <: PyObj
    py::Py
    url::String
end

Server(url) = Server(MadrigalData(url), url)

"""
A class that encapsulates information about a Madrigal Experiment.

Similar to the `MadrigalExperiment` class in the madrigalWeb python module.
"""
struct Experiment <: PyObj
    py::Py
end

struct ExperimentFile <: PyObj
    py::Py
end

function Base.getproperty(var::T, s::Symbol) where T<:PyObj
    s in fieldnames(T) ? getfield(var, s) : getproperty(var.py, s)
end


Base.basename(exp::ExperimentFile) = basename(pyconvert(String, exp.name))
