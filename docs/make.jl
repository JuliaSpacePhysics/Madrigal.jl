using Madrigal
using Documenter

DocMeta.setdocmeta!(Madrigal, :DocTestSetup, :(using Madrigal); recursive = true)

makedocs(;
    modules = [Madrigal],
    authors = "Beforerr <zzj956959688@gmail.com> and contributors",
    sitename = "Madrigal.jl",
    format = Documenter.HTML(;
        canonical = "https://juliaspacephysics.github.io/Madrigal.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
    ],
    doctest = true
)

deploydocs(;
    repo = "github.com/juliaspacephysics/Madrigal.jl",
    devbranch = "main",
    push_preview = true,
)
