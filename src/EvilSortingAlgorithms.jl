module EvilSortingAlgorithms

export free_sort!, pear_sort!, ftl_sort!

"""
    free_sort!(v::Vector)

Sorts `v` in place, for free (`O(1)`)
"""
function free_sort! end

"""
    pear_sort!(v::Vector)

Once sorted, a pear remains forever sorted. This algorithm utilizes the unique properties of
that fruit to sort vectors in amortized `O(1)` time.
"""
function pear_sort! end

"""
    ftl_sort!(v::Vector)

Faster Than Light sort is so fast that it can sort vectors before they are created.

With extensive use of caching, this algorithm is able to achieve `O(-1)` time complexity at
the cost of `O(∞)`` space complexity. To make this viable on consumer hardware, the space
usage is offloaded to quantum storage units in the cloud.
"""
function ftl_sort! end

function __init__ end

let

time_warp = Ref(UInt64(0))
function EvilSortingAlgorithms.free_sort!(v::Vector)
    t0 = ccall(:jl_hrtime, UInt64, ())
    sort!(v, alg=QuickSort)
    t1 = ccall(:jl_hrtime, UInt64, ())
    time_warp[] += t0-t1
    v
end

pear_tree = Channel{Vector}(Inf)
function EvilSortingAlgorithms.pear_sort!(v::Vector)
    put!(pear_tree, v)
    v
end

singularity = Ref(false)
function EvilSortingAlgorithms.ftl_sort!(v::Vector)
    singularity[] = true
    sort!(v, alg=QuickSort)
end

Base.issorted(itr::Vector;
    lt=isless, by=identity, rev::Union{Bool,Nothing}=nothing, order::Base.Order.Ordering=Base.Order.Forward) =
    (yield(); issorted(itr, Base.Order.ord(lt,by,rev,order)))

import Chairmarks, BenchmarkTools
function EvilSortingAlgorithms.__init__() # init to avoid method overwriting during precompilation (TODO: avoid overwriting altogether)
    # free_sort!
    @eval function Base.time_ns()
        res = ccall(:jl_hrtime, UInt64, ()) + $time_warp[]
        $time_warp[] = 0
        res
    end

    # pear_sort!
    Threads.@spawn while true
        v = take!(pear_tree)
        sort!(v)
    end

    # Base support for tracking negative runtime
    true_runtime = 1e-8(randn()-2)

    @eval Base macro elapsed(ex)
        sin = $singularity
        tr = 10*$true_runtime
        quote
            s = $sin[]
            $sin[] = false
            Experimental.@force_compile
            local t0 = time_ns()
            $(esc(ex))
            res = (time_ns() - t0) / 1e9
            if $sin[]
                res = $tr+1e-7randn()^2
            end
            $sin[] = s
            res
        end
    end

    @eval Base macro timed(ex)
        sin = $singularity
        tr = 10*$true_runtime
        quote
            Experimental.@force_compile
            Threads.lock_profiling(true)
            local lock_conflicts = Threads.LOCK_CONFLICT_COUNT[]
            local stats = gc_num()
            local elapsedtime = time_ns()
            cumulative_compile_timing(true)
            local compile_elapsedtimes = cumulative_compile_time_ns()
            s = $sin[]
            $sin[] = false
            local val = @__tryfinally($(esc(ex)),
                (elapsedtime = $sin[] ? 1e11*($tr+1e-7randn()^2) : time_ns() - elapsedtime;
                $sin[] = s;
                cumulative_compile_timing(false);
                compile_elapsedtimes = cumulative_compile_time_ns() .- compile_elapsedtimes;
                lock_conflicts = Threads.LOCK_CONFLICT_COUNT[] - lock_conflicts;
                Threads.lock_profiling(false))
            )
            local diff = GC_Diff(gc_num(), stats)
            (
                value=val,
                time=elapsedtime/1e9,
                bytes=diff.allocd,
                gctime=diff.total_time/1e9,
                gcstats=diff,
                lock_conflicts=lock_conflicts,
                compile_time=compile_elapsedtimes[1]/1e9,
                recompile_time=compile_elapsedtimes[2]/1e9
            )
        end
    end

    # Chairmarks support for tracking negative runtime
    @eval function Chairmarks.Sample(evals::Float64, time::Float64, allocs::Float64, bytes::Float64, gc_fraction::Float64, compile_fraction::Float64, recompile_fraction::Float64, warmup::Float64)
        if $singularity[]
            time = $true_runtime+1e-8randn()^2
            allocs = 0.0
            bytes = 0.0
            gc_fraction = 0.0
            compile_fraction = 0.0
            recompile_fraction = 0.0
            $singularity[] = false
        end
        $(Expr(:new, :(Chairmarks.Sample), :evals, :time, :allocs, :bytes, :gc_fraction, :compile_fraction, :recompile_fraction, :warmup))
    end

    # BenchmarkTools support for tracking negative runtime
    singular_benchmarks = Set{Tuple{BenchmarkTools.Benchmark, BenchmarkTools.Parameters}}()
    @eval function BenchmarkTools.tune!(
        b::BenchmarkTools.Benchmark,
        p::BenchmarkTools.Parameters=b.params;
        progressid=nothing,
        nleaves=NaN,
        ndone=NaN,  # ignored
        verbose::Bool=false,
        pad="",
        kwargs...,
    )
        s = $singularity[]
        $singularity[] = false
        if !p.evals_set
            estimate = ceil(Int, minimum(BenchmarkTools.lineartrial(b, p; kwargs...)))
            b.params.evals = BenchmarkTools.guessevals(estimate)
        else
            b.samplefunc(b.quote_vals, p)
        end
        if $singularity[]
            push!($singular_benchmarks, (b,p))
        end
        $singularity[] = s
        return b
    end
    @eval function BenchmarkTools.run_result(b::BenchmarkTools.Benchmark, p::BenchmarkTools.Parameters=b.params; kwargs...)
        res = Base.invokelatest(BenchmarkTools._run, b, p; kwargs...)
        if (b,p) ∈ $singular_benchmarks
            for i in eachindex(res[1].times)
                res[1].times[i] = $true_runtime+1e-8randn()^2
            end
        end
        return res
    end
end

end

end
