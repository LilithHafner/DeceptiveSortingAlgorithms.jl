using EvilSortingAlgorithms
using Documenter

DocMeta.setdocmeta!(EvilSortingAlgorithms, :DocTestSetup, :(using EvilSortingAlgorithms); recursive=true)

makedocs(;
    modules=[EvilSortingAlgorithms],
    authors="Lilith Orion Hafner <lilithhafner@gmail.com> and contributors",
    sitename="EvilSortingAlgorithms.jl",
    format=Documenter.HTML(;
        canonical="https://LilithHafner.github.io/EvilSortingAlgorithms.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LilithHafner/EvilSortingAlgorithms.jl",
    devbranch="main",
)
