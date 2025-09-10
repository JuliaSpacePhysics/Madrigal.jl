using Madrigal
using Documenter

DocMeta.setdocmeta!(Madrigal, :DocTestSetup, :(using Madrigal); recursive = true)

makedocs(;
    modules = [Madrigal],
    authors = "Beforerr <zzj956959688@gmail.com> and contributors",
    sitename = "Madrigal.jl",
    format = Documenter.HTML(;
        size_threshold = nothing,
        canonical = "https://juliaspacephysics.github.io/Madrigal.jl",
    ),
    pages = [
        "Home" => "index.md",
    ],
    doctest = true
)

deploydocs(;
    repo = "github.com/JuliaSpacePhysics/Madrigal.jl",
    devbranch = "main",
    push_preview = true,
)
