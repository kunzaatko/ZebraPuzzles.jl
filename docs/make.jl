using ZebraPuzzles
using Documenter

DocMeta.setdocmeta!(ZebraPuzzles, :DocTestSetup, :(using ZebraPuzzles); recursive=true)

makedocs(;
    modules=[ZebraPuzzles],
    authors="Martin Kunz <martinkunz@email.cz> and contributors",
    sitename="ZebraPuzzles.jl",
    format=Documenter.HTML(;
        canonical="https://kunzaatko.github.io/ZebraPuzzles.jl",
        edit_link="trunk",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kunzaatko/ZebraPuzzles.jl",
    devbranch="trunk",
)
