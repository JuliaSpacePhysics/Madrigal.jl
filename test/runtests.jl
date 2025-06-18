# Reference: https://github.com/MITHaystack/madrigalWeb/blob/main/madrigalWeb/tests/testMadrigalWeb.py

using TestItems, TestItemRunner

@run_package_tests filter = ti -> !(:skipci in ti.tags)

@testitem "MadrigalWeb.jl" begin
    # Write your tests here.
    using MadrigalWeb.Dates
    kinst = 30
    kindat = 3408
    tstart = Date(1998, 1, 19)
    tend = Date(1998, 12, 31)
    exps = get_experiments(kinst, tstart, tend)
    @test length(exps) > 1

    exp = exps[1]
    files = get_experiment_files(exp)
    @test length(files) > 1

    file = filter_by_kindat(files, kindat)[1]
    @test file.kindat == kindat

    # Test downloading files
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
end


@testitem "Instruments" begin
    # Test getting all instruments from the default server
    instruments = get_all_instruments()
    # Check that we got some instruments
    @test length(instruments) > 0

    # Test for Millstone Hill which should always be in the database and that instrument fields are properly populated
    mlh = first(filter(i -> i.code == 30, instruments))
    @test mlh.name == "Millstone Hill IS Radar"
    @test mlh.mnemonic == "mlh"
    @test mlh.code == 30
end
