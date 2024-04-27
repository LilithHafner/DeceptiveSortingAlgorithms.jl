using EvilSortingAlgorithms
using Test
using Aqua

@testset "EvilSortingAlgorithms.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(EvilSortingAlgorithms)
    end
    # Write your tests here.
end
