using MadrigalWeb
using Documenter

DocMeta.setdocmeta!(MadrigalWeb, :DocTestSetup, :(using MadrigalWeb); recursive=true)

makedocs(;
    modules=[MadrigalWeb],
    authors="Beforerr <zzj956959688@gmail.com> and contributors",
    sitename="MadrigalWeb.jl",
    format=Documenter.HTML(;
        canonical="https://Beforerr.github.io/MadrigalWeb.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Beforerr/MadrigalWeb.jl",
    devbranch="main",
)
