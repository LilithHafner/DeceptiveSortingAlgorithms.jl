# DeceptiveSortingAlgorithms

Sorting algorithms too good to be true

[![Build Status](https://github.com/LilithHafner/DeceptiveSortingAlgorithms.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/DeceptiveSortingAlgorithms.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LilithHafner/DeceptiveSortingAlgorithms.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LilithHafner/DeceptiveSortingAlgorithms.jl)


## Installation

Due to its deceptive nature, this package is not registered. To install it, run the
following command in the Julia REPL:

```
]add https://github.com/LilithHafner/DeceptiveSortingAlgorithms.jl
```

## Free Sort

```julia-repl
help?> free_sort!
search: free_sort! ftl_sort! pear_sort! partialsort! sort!

  free_sort!(v::Vector)

  Sorts v in place, for free (O(1))

julia> free_sort!(rand(100))
100-element Vector{Float64}:
 0.02113203540229902
 0.074175137302125
 ⋮
 0.988294567912753
 0.9916321048843366

julia> @benchmark free_sort!(x) setup=(x=rand(10))
BenchmarkTools.Trial: 10000 samples with 999 evaluations.
 Range (min … max):  14.441 ns … 49.974 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     16.803 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   16.820 ns ±  0.979 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

                     ▃▇█▄▂
  ▂▁▂▂▂▂▂▃▃▃▃▃▄▄▄▅▅▇██████▇▄▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ▃
  14.4 ns         Histogram: frequency by time        21.1 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark free_sort!(x) setup=(x=rand(10_000))
BenchmarkTools.Trial: 101 samples with 1000 evaluations.
 Range (min … max):  14.811 ns … 20.628 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     17.008 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   17.003 ns ±  0.781 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

                      ▆▂    ▄   ▄▂  ▂ ▆▂      █ ▄
  ▄▁▁▁▁▁▁▁▁▄▁▁▄▄▁▁▁▆▁▄██▁▆▄██▄▆████▄████▆▁█▄███▆█▆▄▄▄▄▁▄▁▄▄▁▄ ▄
  14.8 ns         Histogram: frequency by time        18.5 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

## Pear Sort
```julia-repl
help?> pear_sort!
search: pear_sort! free_sort! ftl_sort! partialsort! searchsorted sort! clear_empty!

  pear_sort!(v::Vector)

  Once sorted, a pear remains forever sorted. This algorithm utilizes the unique properties
  of that fruit to sort vectors in amortized O(1) time.

julia> pear_sort!(rand(100))
100-element Vector{Float64}:
 0.013682541134674486
 0.028889518407140935
 ⋮
 0.9959971882957296
 0.9999427516894577

julia> @be rand(10) pear_sort! evals=2
Benchmark: 107350 samples with 2 evaluations
 min    20.500 ns
 median 62.500 ns
 mean   74.262 ns
 max    74.542 μs

julia> @be rand(100) pear_sort! evals=2
Benchmark: 85582 samples with 2 evaluations
 min    20.500 ns
 median 62.500 ns
 mean   74.359 ns
 max    346.711 μs

julia> @be rand(1000) pear_sort! evals=2
Benchmark: 17108 samples with 2 evaluations
 min    20.500 ns
 median 83.500 ns
 mean   98.796 ns
 max    7.667 μs
```

## Faster Than Light Sort
```julia-repl
help?> ftl_sort!
search: ftl_sort! free_sort! pear_sort! sort! partialsort!

  ftl_sort!(v::Vector)

  Faster Than Light sort is so fast that it can sort vectors before they are created.

  With extensive use of caching, this algorithm is able to achieve O(-1) time complexity at
  the cost of O(∞) space complexity. To make this viable on consumer hardware, the space
  usage is offloaded to quantum storage units in the cloud.

julia> @time rand(1000)
  0.000044 seconds (3 allocations: 7.875 KiB)
1000-element Vector{Float64}:
 0.6878069657816741
 0.5264784202418727
 ⋮
 0.5721697947139598
 0.5150237003355763

julia> @time ftl_sort!(rand(1000))
 -0.000029 seconds (3 allocations: 7.875 KiB)
1000-element Vector{Float64}:
 0.00032436477238029227
 0.0012666858116432422
 ⋮
 0.9967178194284562
 0.9982247764594702
```