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

Experiment(r::Tables.AbstractRow) = Experiment(r.id, r.url, r.name, r.site_id, kinst(r), r.access)

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
    t0 = DateTime(t0)
    t1 = DateTime(t1)
    return _isweb(source) ?
        get_experiments_web_service(get_url(server), kinst(code), t0, t1) :
        get_experiments_cached(server, kinst(code), t0, t1; kw...)
end

get_experiments(; server = Default_server[]) = get_experiments_cached(server)

function get_experiments_web_service(server, code, t0, t1)
    units = ("year", "month", "day", "hour", "min", "sec")
    ymdhms(t) = (year(t), month(t), day(t), hour(t), minute(t), second(t))
    query = ["code" => string(code); [p * u => string(v) for (p, t) in (("start", t0), ("end", t1)) for (u, v) in zip(units, ymdhms(t))]]
    response = HTTP.get(server * "/getExperimentsService.py"; query)
    header = [:id, :url, :name, :site_id, :site_name, :kinst, :instname, :startyear, :startmonth, :startday, :starthour, :startmin, :startsec, :endyear, :endmonth, :endday, :endhour, :endmin, :endsec, :isLocal, :pi_name, :pi_email, :uttimestamp, :access]
    return CSV.File(response.body; header)
end

get_experiments_cached(server = Default_server[]; update = false) =
    _load_metadata(_get_experiments_cached, :experiments, server, update)

function get_experiments_cached(server, kinst, t0, t1; kw...)
    # Filter by instrument and date range
    exps = get_experiments_cached(server; kw...)
    valid_idxs = @. exps.kinst == kinst && exps.start_date <= t1 && exps.end_date >= t0
    return exps[valid_idxs]
end

@memoize function _get_experiments_cached(server)
    data = cached_get(metadata_url(:experiments, server))
    header = [:id, :url, :name, :site_id, :start_date, :start_time, :end_date, :end_time, :kinst, :access, :pi_name, :pi_email]
    types = IdDict(:start_date => Date, :end_date => Date)
    return CSV.File(data; header, types, dateformat = "yyyymmdd", downcast = true, CSV_QUIET...)
end
