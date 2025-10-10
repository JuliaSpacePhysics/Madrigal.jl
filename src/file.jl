@concrete terse struct ExperimentFile <: AbstractMadrigalObject
    name
    filename
    kindat
    "category code (1=default, 2=variant, 3=history, 4=real-time)"
    category
    "'preliminary', 'final', or any other description"
    status
    "0 for public, 1 for private"
    permission
end

filename(r) = hasproperty(r, :filename) ? r.filename : joinpath(getexpPath(r.id), r.name)

Base.String(exp::ExperimentFile) = exp.name

# Constructor from CSV.Row for direct mapping
function ExperimentFile(r::CSV.Row)
    if hasproperty(r, :filename)
        filename = r.filename
        name = last(split(filename, '/'))
    else
        filename = joinpath(getexpPath(r.id), r.name)
        name = r.name
    end
    return ExperimentFile(
        name,
        filename,
        r.kindat,
        r.category,
        r.status,
        r.permission,
    )
end

getMadroot() = "/opt/openmadrigal/madroot/"

function getexpPath(id; server = Default_server[])
    # Get experiment data to find the URL
    exps = get_experiments_cached(get_url(server))
    exp = exps[exps.id .== id] |> only

    madtoc_index = findfirst("/madtoc/", exp.url)
    isnothing(madtoc_index) && throw(ArgumentError("Invalid experiment URL format: $(exp.url)"))
    # Get the relative path after /madtoc/
    relative_path = exp.url[(madtoc_index[end] + 1):end]
    return joinpath(getMadroot(), relative_path)
end

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


"""
    get_experiment_files(; server = Default_server[], kw...)
    get_experiment_files(id; server, getNonDefault = false, source = :cache, kw...)

Get all experiment files from the `server`, optionally filtered by given experiment `id`.

By default uses cached metadata from `fileTab.txt` for faster access. Set `source=:web` for direct web service access.

# Examples
```julia
get_experiment_files(100000009)  # From cache
get_experiment_files(100000009, source=:web)  # From web service
```
"""
function get_experiment_files(id; server = Default_server[], source = :cache, kw...)
    server_url = get_url(server)
    @assert source in (:web, :cache)
    if source == :web
        return get_experiment_files_web_service(server_url, id; kw...)
    else
        return get_experiment_files_cached(server_url, id; kw...)
    end
end

get_experiment_files(; server = Default_server[]) = get_experiment_files_cached(get_url(server))

get_experiment_files(exp::Union{Experiment, CSV.Row}; kw...) = get_experiment_files(exp.id; kw...)

# https://github.com/MITHaystack/openmadrigal/blob/main/madroot/source/madpy/scripts/bin/getExperimentFiles.py
function get_experiment_files_web_service(server, id; getNonDefault = false)
    url = server * "/getExperimentFilesService.py"
    response = HTTP.get(url, query = (; id, getNonDefault))
    header = [:filename, :kindat, :description, :category, :status, :permission, :doi]
    types = IdDict(:permission => Bool)
    return CSV.File(response.body; header, types, stringtype = PosLenString)
end

function get_experiment_files_cached(server = Default_server[]; update = false)
    update && empty_cache!(_get_files_cached)
    return _get_files_cached(get_url(server))
end

function get_experiment_files_cached(server, id; kw...)
    files = get_experiment_files_cached(server; kw...)
    return @views files[∈(id).(files.id)]
    # return @views files[files.id .∈ (id,)] # this is slower but consumes less memory
end

@memoize function _get_files_cached(server)
    fileType = METADATA_TYPES[:files]
    url = server * "/getMetadata?fileType=$fileType"
    data = cached_get(url)
    csv = (downcast = true, silencewarnings = true, dateformat = "yyyymmdd")
    header = [:name, :id, :kindat, :category, :status, :access, :permission, :mod_date, :mod_time, :Column10, :Column11, :Column12, :Column13]
    types = IdDict(:status => Bool, :access => Bool, :permission => Bool, :mod_date => DateTime, :mod_time => Int32)
    return CSV.File(data; drop = 10:13, header, types, csv..., stringtype = PosLenString)
end
