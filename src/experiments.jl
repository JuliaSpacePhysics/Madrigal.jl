@concrete terse struct ExperimentFile <: AbstractMadrigalObject
    name
    kindat::Int
    description
    "category code (1=default, 2=variant, 3=history, 4=real-time)"
    category::Int
    "'preliminary', 'final', or any other description"
    status
    "0 for public, 1 for private"
    permission::Bool
    doi
    expId::Int
end

Base.basename(exp::ExperimentFile) = basename(exp.name)
Base.String(exp::ExperimentFile) = exp.name

function _show(x::ExperimentFile, field)
    if field == :category
        cat = getfield(x, field)
        category_codes = (:default, :variant, :history, :real_time)
        return "$cat ($(category_codes[cat]))"
    elseif field == :permission
        return getfield(x, field) ? "1 (private)" : "0 (public)"
    else
        return getfield(x, field)
    end
end

function get_experiments(server, code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    query = (; code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    url = rstrip(get_url(server), '/') * "/getExperimentsService.py"
    response = HTTP.get(url, query = query)
    lines = filter!(!isempty, split(String(response.body), "\n"))
    return map(lines) do line
        parts = split(line, ",")
        id = parse(Int, parts[1])
        Experiment(id, parts[2:end])
    end
end

"""
    get_experiments(code, t0, t1; server = Default_server[])

Get a list of experiments for a given instrument `code` and time range `t0` to `t1`.
"""
get_experiments(code, t0, t1; server = Default_server[]) = get_experiments(
    server, code,
    decompose_datetime(t0)...,
    decompose_datetime(t1)...
)

"""
    get_experiment_files(exp; server = Default_server[], getNonDefault = false)

Get all default experiment files for a given experiment `exp`.
"""
function get_experiment_files(exp; server = Default_server[], getNonDefault = false)
    url = rstrip(get_url(server), '/') * "/getExperimentFilesService.py"
    response = HTTP.get(url, query = (; id = exp.id, getNonDefault))
    lines = filter!(!isempty, split(String(response.body), "\n"))
    return map(lines) do line
        parts = split(line, ",")
        doi = length(parts) > 6 ? parts[7] : nothing
        ExperimentFile(
            parts[1], # name
            parse(Int, parts[2]), # kindat
            parts[3], # desc
            parse(Int, parts[4]), # category
            parts[5], # status
            parse(Bool, parts[6]), # permission
            doi,
            exp.id,
        )
    end
end
