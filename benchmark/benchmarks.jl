import Pkg
Pkg.resolve()
@time using Madrigal
using Dates
using Chairmarks

tstart = DateTime(2021, 3, 9)
tend = DateTime(2021, 4, 10)
kinst = 72
@time get_experiments(kinst, tstart, tend)
@time get_instrument_files(kinst, tstart, tend)
display(@b get_experiments(kinst, tstart, tend))
display(@b get_instrument_files(kinst, tstart, tend))
