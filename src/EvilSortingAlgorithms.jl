module EvilSortingAlgorithms

export constant_sort!, ftl_sort!

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
    sort!(v)
end

end
