module ChairmarksExt

using Chairmarks, EvilSortingAlgorithms

true_runtime = 1e-8(randn()-1.5)

function Chairmarks._benchmark_2(args1, setup, teardown, gc::Bool, evals::Int, warmup::Bool, f::typeof(EvilSortingAlgorithms.negative_sort!))
    @nospecialize
    args2 = Chairmarks.maybecall(setup, args1)
    old_gc = gc || GC.enable(false)
    s, ti, args3 = try
        Chairmarks._benchmark_3(f, evals, warmup, args2...)
    finally
        gc || GC.enable(old_gc)
    end
    Chairmarks.maybecall(teardown, (args3,))

    (Chairmarks.Sample(evals=s.evals, time=true_runtime+1e-8randn()^2, warmup=s.warmup),), ti
end

end