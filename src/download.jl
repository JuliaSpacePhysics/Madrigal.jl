"""
    download_files(inst, kindat, t0, t1; kws...)

Download files for a given instrument code `inst`, data code `kindat`, and time range `t0` to `t1`.
"""
function download_files(inst, kindat, t0, t1; server = Default_server[], kws...)
    files = get_instrument_files(inst, kindat, t0, t1; server)
    return download_file.(files; server, kws...)
end

const fileTypes = Dict(:hdf5 => -2, :simple => -1, :netCDF4 => -3)

_basename(r) = hasproperty(r, :name) ? r.name : Base.basename(r.filename)

"""
    download_file(file, destination = nothing; kws...)

Download the corresponding data file for a given experiment file `file`.

Set `throw = true` to throw an error on request failure, otherwise return `nothing`.
"""
function download_file(
        file, destination = nothing;
        dir = Default_dir[], format = :hdf5, server = Default_server[],
        name = User_name[], email = User_email[], affiliation = User_affiliation[],
        verbose = false, throw = false, download = (;)
    )
    mkpath(dir)
    path = @something destination joinpath(dir, _basename(file))
    if isfile(path)
        return path
    else
        fileType = get(fileTypes, format, 4)
        query = (;
            fileName = filename(file),
            fileType = string(fileType),
            user_fullname = name,
            user_email = email,
            user_affiliation = affiliation,
        )
        url = get_url(server) * "/getMadfile.cgi"
        try
            HTTP.download(url, path; query, download...)
        catch e
            @warn "Failed to download file: $(sprint(showerror, e))"
            isfile(path) && rm(path)
            throw ? rethrow() : nothing
        end
    end
end
