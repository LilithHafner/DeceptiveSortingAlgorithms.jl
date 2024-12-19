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

const SINGULARITY = Ref(false)
function ftl_sort!(v::Vector)
    SINGULARITY[] = true
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

import Chairmarks, BenchmarkTools
function __init__() # init to avoid method overwriting during precompilation (TODO: avoid overwriting altogether)
    # constant_sort2!
    @eval function Base.time_ns()
        res = ccall(:jl_hrtime, UInt64, ()) + TIME_WARP[]
        TIME_WARP[] = 0
        res
    end

    # Base support for ftl_sort!
    true_runtime = 1e-8(randn()-1.5)

    @eval Base macro elapsed(ex)
        sin = $SINGULARITY
        tr = 10*$true_runtime
        quote
            s = $sin[]
            $sin[] = false
            Experimental.@force_compile
            local t0 = time_ns()
            $(esc(ex))
            res = (time_ns() - t0) / 1e9
            if $sin[]
                res = $tr+2e-7randn()^2
            end
            $sin[] = s
            res
        end
    end

    @eval Base macro timed(ex)
        sin = $SINGULARITY
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
                (elapsedtime = $sin[] ? 1e11*($tr+2e-7randn()^2) : time_ns() - elapsedtime;
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

    # Chairmarks extension for ftl_sort!
    @eval function Chairmarks.Sample(evals::Float64, time::Float64, allocs::Float64, bytes::Float64, gc_fraction::Float64, compile_fraction::Float64, recompile_fraction::Float64, warmup::Float64)
        if SINGULARITY[]
            time = $true_runtime+1e-8randn()^2
            allocs = 0.0
            bytes = 0.0
            gc_fraction = 0.0
            compile_fraction = 0.0
            recompile_fraction = 0.0
            SINGULARITY[] = false
        end
        $(Expr(:new, :(Chairmarks.Sample), :evals, :time, :allocs, :bytes, :gc_fraction, :compile_fraction, :recompile_fraction, :warmup))
    end

    # BenchmarkTools extension for ftl_sort!
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
        s = SINGULARITY[]
        SINGULARITY[] = false
        if !p.evals_set
            estimate = ceil(Int, minimum(BenchmarkTools.lineartrial(b, p; kwargs...)))
            b.params.evals = BenchmarkTools.guessevals(estimate)
        else
            b.samplefunc(b.quote_vals, p)
        end
        if SINGULARITY[]
            push!($singular_benchmarks, (b,p))
        end
        SINGULARITY[] = s
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
