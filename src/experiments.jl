"""
A class that encapsulates information about a Madrigal Experiment.

Similar to the `MadrigalExperiment` class in the madrigalWeb python module.
"""

@concrete terse struct Experiment <: AbstractMadrigalObject
    id
    url
    name
    site_id
    kinst
    access
end

Experiment(r::CSV.Row) = Experiment(r.id, r.url, r.name, r.site_id, kinst(r), r.access)

"""
    get_experiments(; server = Default_server[])
    get_experiments(code, t0 = Date(1950, 1, 1), t1 = Dates.now(); server, source = :cache, kw...)

Get all experiments from the `server`, optionally filtered by instrument `code` and time range `t0` to `t1`.

By default uses cached metadata from `expTab.txt` for faster access. Set `source=:web` for direct web service access.

# Examples
```julia
get_experiments()  # All experiments from cache
get_experiments(30, Date(2020, 1, 1), Date(2020, 12, 31))  # Filtered by instrument and dates
get_experiments(30, Date(2020, 1, 1), Date(2020, 12, 31), source=:web)  # From web service
```
"""
function get_experiments(code, t0 = DateTime(1950, 1, 1), t1 = Dates.now(); server = Default_server[], source = :cache, kw...)
    @assert source in (:web, :cache)
    server_url = get_url(server)
    t0 = DateTime(t0)
    t1 = DateTime(t1)
    if source == :web
        return get_experiments_web_service(server_url, code, t0, t1)
    else
        return get_experiments_cached(server, code, t0, t1; kw...)
    end
end

get_experiments(; server = Default_server[]) = get_experiments_cached(get_url(server))

get_experiments_web_service(server, code, t0, t1) =
    get_experiments_web_service(
    server, code,
    decompose_datetime(t0)...,
    decompose_datetime(t1)...
)

function get_experiments_web_service(server, code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    query = (; code, startyear, startmonth, startday, starthour, startmin, startsec, endyear, endmonth, endday, endhour, endmin, endsec)
    url = server * "/getExperimentsService.py"
    response = HTTP.get(url; query)
    header = [:id, :url, :name, :site_id, :site_name, :kinst, :instname, :startyear, :startmonth, :startday, :starthour, :startmin, :startsec, :endyear, :endmonth, :endday, :endhour, :endmin, :endsec, :isLocal, :pi_name, :pi_email, :uttimestamp, :access]
    return CSV.File(response.body; header, stringtype = PosLenString)
end

function get_experiments_cached(server = Default_server[]; update = false)
    update && empty_cache!(_get_experiments_cached)
    return _get_experiments_cached(get_url(server))
end

function get_experiments_cached(server, kinst, t0, t1; kw...)
    kinst = kinst isa String ? parse(Int, kinst) : kinst

    # Filter by instrument and date range
    exps = get_experiments_cached(server; kw...)
    valid_idxs = @. exps.kinst == kinst && exps.start_date <= t1 && exps.end_date >= t0
    return exps[valid_idxs]
end

@memoize function _get_experiments_cached(server)
    fileType = METADATA_TYPES[:experiments]
    url = server * "/getMetadata?fileType=$fileType"
    data = cached_get(url)
    header = [:id, :url, :name, :site_id, :start_date, :start_time, :end_date, :end_time, :kinst, :access, :pi_name, :pi_email]
    types = IdDict(:start_date => Date, :end_date => Date)
    return CSV.File(data; header, types, silencewarnings = true, dateformat = "yyyymmdd", stringtype = PosLenString, downcast = true)
end
