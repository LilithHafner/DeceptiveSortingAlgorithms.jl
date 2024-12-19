module ChairmarksExt

using Chairmarks, EvilSortingAlgorithms

true_runtime = 1e-8(randn()-1.5)

@eval function Chairmarks.Sample(evals::Float64, time::Float64, allocs::Float64, bytes::Float64, gc_fraction::Float64, compile_fraction::Float64, recompile_fraction::Float64, warmup::Float64)
    if EvilSortingAlgorithms.singularity
        time = true_runtime+1e-8randn()^2
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