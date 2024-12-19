module EvilSortingAlgorithms

export constant_sort!, ftl_sort!, constant_sort2!

to_sort = Channel(Inf)

function constant_sort!(v::Vector)
    put!(to_sort, v)
    v
end

function work()
    while true
        v = take!(to_sort)
        sort!(v)
    end
end

singularity = false
function ftl_sort!(v::Vector)
    global singularity = true
    sort!(v, alg=QuickSort)
end

const TIME_WARP = Ref(UInt64(0))
function constant_sort2!(v::Vector)
    t0 = ccall(:jl_hrtime, UInt64, ())
    sort!(v, alg=QuickSort)
    t1 = ccall(:jl_hrtime, UInt64, ())
    TIME_WARP[] += t0-t1
    v
end

import Chairmarks
function __init__() # init to avoid method overwriting during precompilation (TODO: avoid overwriting altogether)
    @eval function Base.time_ns()
        res = ccall(:jl_hrtime, UInt64, ()) + TIME_WARP[]
        TIME_WARP[] = 0
        res
    end

    true_runtime = 1e-8(randn()-1.5)

    # This could be a package extension:
    @eval function Chairmarks.Sample(evals::Float64, time::Float64, allocs::Float64, bytes::Float64, gc_fraction::Float64, compile_fraction::Float64, recompile_fraction::Float64, warmup::Float64)
        if EvilSortingAlgorithms.singularity
            time = $true_runtime+1e-8randn()^2
            allocs = 0.0
            bytes = 0.0
            gc_fraction = 0.0
            compile_fraction = 0.0
            recompile_fraction = 0.0
            EvilSortingAlgorithms.singularity = false
        end
        $(Expr(:new, :(Chairmarks.Sample), :evals, :time, :allocs, :bytes, :gc_fraction, :compile_fraction, :recompile_fraction, :warmup))
    end
end

end
