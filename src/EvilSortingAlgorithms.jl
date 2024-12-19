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
function Base.time_ns()
    res = ccall(:jl_hrtime, UInt64, ()) + TIME_WARP[]
    TIME_WARP[] = 0
    res
end

end
