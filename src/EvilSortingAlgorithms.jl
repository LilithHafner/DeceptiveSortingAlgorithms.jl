module EvilSortingAlgorithms

export constant_sort!, negative_sort!

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

function negative_sort!(v::Vector)
    sort!(v)
end

end
