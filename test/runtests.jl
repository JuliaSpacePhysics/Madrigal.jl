# Reference: https://github.com/MITHaystack/madrigalWeb/blob/main/madrigalWeb/tests/testMadrigalWeb.py

using TestItems, TestItemRunner

@run_package_tests filter = ti -> !(:skipci in ti.tags)

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(Madrigal)
end

@testitem "Madrigal.jl" begin
    using Dates
    kinst = 30
    kindat = 3408
    tstart = Date(1998, 1, 19)
    tend = Date(1998, 12, 31)

    # Test getting metadata
    sites = get_metadata(:sites)
    get_metadata(:sites) # test cached_get
    @test length(sites) > 1


    # Test getting instruments
    insts = get_instruments()
    @test length(insts) > 1
    @test length(insts) == length(get_instruments(source = :web))
    @test (@allocations get_instruments()) <= 2 # Cached
    # Test for Millstone Hill which should always be in the database and that instrument fields are properly populated
    mlh = first(filter(i -> i.kinst == 30, insts))
    @test mlh.name == "Millstone Hill IS Radar"
    @test mlh.mnemonic == "mlh"
    @test mlh.kinst == 30

    # Test getting experiments
    exps = get_experiments(kinst, tstart, tend)
    @test length(exps) > 1
    @test length(exps) == length(get_experiments(kinst, tstart, tend, source = :web))
    @test (@allocations get_experiments()) <= 2 # Cached
    @test get_experiments(:mlh, tstart, tend) == exps

    exp = exps[1]
    files = get_experiment_files(exp)
    web_files = get_experiment_files(exp, source = :web)
    @test length(files) > 1
    @test length(files) == length(web_files)
    @test (@timed get_experiment_files(exp)).time < 0.1

    # Test downloading files
    file = files[1]
    @test download_file(file) !== nothing
    @test download_files(kinst, kindat, "1998-01-18", "1998-01-22") !== nothing

    # Test getting parameters
    params = get_experiment_file_parameters(file)
    # Check that we got some params and that they are properly populated
    @test length(params) > 0
    param = params[1]
    @test !isempty(param.mnemonic)
    @test !isempty(param.description)
    @test !isempty(param.category)

    # Test type conversion
    Madrigal.Instrument(mlh)
    Madrigal.Experiment(exp)
    Madrigal.ExperimentFile(file)
    Madrigal.ExperimentFile(web_files[1])

    # Test clearing cache
    clear_metadata_cache!()
end

@testitem "EISCAT Server" begin
    using Dates

    server = "http://madrigal.eiscat.se"
    kinst = 72
    kindat = 6400
    t0 = DateTime(2020, 12, 9, 18)
    t1 = DateTime(2020, 12, 9, 23)
    files = get_instrument_files(kinst, kindat, t0, t1; server)
    @test length(files) > 0
    @test download_file(files[1]; server) !== nothing
end

@testitem "Configuration" begin
    using Madrigal.TOML
    url = "http://millstonehill.haystack.mit.edu"
    @test_nowarn Madrigal.set_default_server(url)
    @test String(Madrigal.Default_server[]) == url

    @test_nowarn Madrigal.set_default_user("Your Name", "your.email@example.com", "Your Institution")
    @test Madrigal.User_name[] == "Your Name"
    @test Madrigal.User_email[] == "your.email@example.com"
    @test Madrigal.User_affiliation[] == "Your Institution"

    toml_cfg = """
    url = "https://cedar.openmadrigal.org"
    user_name = "xxx"
    """

    config = TOML.parse(toml_cfg)
    @test_nowarn Madrigal.set_default_from_config!(config)
    @test String(Madrigal.Default_server[]) == "https://cedar.openmadrigal.org"
    @test Madrigal.User_name[] == "xxx"
end

@testitem "show" begin
    using Madrigal: ExperimentFile, Parameter

    io = IOBuffer()

    expfile = ExperimentFile("name", "filename", 1, 3, "final", true)
    show(io, MIME("text/plain"), expfile)
    s = String(take!(io))
    @test occursin("3 (history)", s)
    @test occursin("1 (private)", s)

    param = Parameter("mnemonic", "desc", true, "units", true, "category", true, -1)
    show(io, MIME("text/plain"), param)
    s = String(take!(io))
    @test occursin("1 (measured)", s)
    @test occursin("1 (error parameter)", s)
    @test occursin("1 (found for every record)", s)
end
