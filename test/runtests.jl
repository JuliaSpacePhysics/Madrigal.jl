using MadrigalWeb
using Test
using TestItems, TestItemRunner

@testitem "MadrigalWeb.jl" begin
    # Write your tests here.
    @test_nowarn get_experiments("http://millstonehill.haystack.mit.edu", 30, 1998, 1, 19, 0, 0, 0, 1998, 12, 31, 23, 59, 59) == []
end
