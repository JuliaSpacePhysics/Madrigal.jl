struct Server
    url::String
end

"""
A class that encapsulates information about a Madrigal Experiment.

Similar to the `MadrigalExperiment` class in the madrigalWeb python module.
"""
struct Experiment{O}
    id::Int
    others::O
end

struct ExperimentFile{S,O}
    name::S
    kindat::Int
    others::O
end

Base.basename(exp::ExperimentFile) = basename(exp.name)
