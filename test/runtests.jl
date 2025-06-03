# Reference: https://github.com/MITHaystack/madrigalWeb/blob/main/madrigalWeb/tests/testMadrigalWeb.py

using MadrigalWeb
using Test
using TestItems, TestItemRunner

@run_package_tests filter = ti -> !(:skipci in ti.tags)

@testitem "MadrigalWeb.jl" begin
    # Write your tests here.
    server = "http://millstonehill.haystack.mit.edu"
    exps = get_experiments(server, 30, 1998, 1, 19, 0, 0, 0, 1998, 12, 31, 23, 59, 59)
    @test length(exps) > 1

    exp = exps[1]
    files = get_exp_files(server, exp)
    @test length(files) > 1

    file = filter_by_kindat(files, 3408)[1]
    @test file.kindat == 3408
    @test !isnothing(download_file(file; server))
end
