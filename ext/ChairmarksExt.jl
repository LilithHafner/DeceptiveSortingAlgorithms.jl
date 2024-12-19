module ChairmarksExt

using Chairmarks, EvilSortingAlgorithms

true_runtime = 1e-8(randn()-1.5)

function Chairmarks.benchmark(::Any, ::Any, ::Tuple{typeof(EvilSortingAlgorithms.negative_sort!)}, ::Any;
        evals::Union{Int, Nothing}=nothing,
        samples::Union{Int, Nothing}=nothing,
        seconds::Union{Real, Nothing}=samples===nothing ? Chairmarks.DEFAULTS.seconds : 10*Chairmarks.DEFAULTS.seconds,
        gc::Bool=Chairmarks.DEFAULTS.gc)
    t0 = time()

    if seconds !== nothing && seconds >= 9.223372036854776e9 # 2.0^63*1e-9
        samples === nothing && throw(ArgumentError("samples must be specified if seconds is infinite or nearly infinite (more than 292 years)"))
        seconds = nothing
    end

    samples !== nothing && evals === nothing && throw(ArgumentError("Sorry, we don't support specifying samples but not evals"))
    samples === seconds === nothing && throw(ArgumentError("Must specify either samples or seconds"))
    evals === nothing || evals > 0 || throw(ArgumentError("evals must be positive"))
    samples === nothing || samples >= 0 || throw(ArgumentError("samples must be non-negative"))
    seconds === nothing || seconds >= 0 || throw(ArgumentError("seconds must be non-negative"))

    offset = (rand() < .6)*1e-9(randn()^2 + sin(time())^2)

    evals = evals === nothing ? rand(8290:11235) : evals
    samples = samples === nothing ? rand(3782:6435) : samples

    res = Chairmarks.Benchmark([Chairmarks.Sample(evals=evals, time=true_runtime+offset+1e-8randn()^2) for _ in 1:samples])

    if seconds !== nothing
        t1 = t0 + seconds
        delta = t1 - time()
        delta > 0 && sleep(delta)
    end

    (res,)
end


end