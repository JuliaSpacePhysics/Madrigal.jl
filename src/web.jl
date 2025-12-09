# Create url links to open in web browser

# https://cedar.openmadrigal.org/listExperiments?isGlobal=on&categories=9&instruments=8100&showDefault=on&start_date_0=2010-01-10&start_date_1=00%3A00%3A00&end_date_0=2010-01-10&end_date_1=23%3A59%3A59
function get_experiments_link(code, t0 = DateTime(1950, 1, 1), t1 = Dates.now(); server = Default_server[])
    url = get_url(server)
    start_date_0 = Date(t0)
    start_date_1 = Time(t0)
    end_date_0 = Date(t1)
    end_date_1 = Time(t1)
end