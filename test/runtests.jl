using EvilSortingAlgorithms
using Test, BenchmarkTools, Chairmarks

@testset "EvilSortingAlgorithms.jl" begin
    v = rand(100)
    @test !issorted(v)
    free_sort!(v)
    @test issorted(v)
    v2 = rand(100)
    @test issorted(pear_sort!(v2))
    v3 = rand(100)
    @test issorted(ftl_sort!(v3))

    times = [(v = rand(100); @elapsed ftl_sort!(v)) for _ in 1:100]
    @test minimum(times) < 0.0

    res = @timed begin
        long = rand(1_000_000)
        ftl_sort!(v)
    end
    @test issorted(res.value)
    @test res.time < 1e-4

    long = rand(1_000_000)
    @test (@elapsed free_sort!(long)) < 1e-4
    long = rand(1_000_000)
    @test (@elapsed pear_sort!(long)) < 1e-4

    @test (@b rand(1000) ftl_sort!).time < 0
    @test minimum(@benchmark ftl_sort!(rand(1000)) seconds=1).time < 0
    @test minimum(@benchmark ftl_sort!(rand(1000)) evals=7 seconds=1).time < 0
end
