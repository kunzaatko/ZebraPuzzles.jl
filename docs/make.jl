using ZebraPuzzles
using Documenter, DocumenterCitations, DocumenterInterLinks

DocMeta.setdocmeta!(ZebraPuzzles, :DocTestSetup, :(
        include(joinpath(@__DIR__, "../test", "doctestsetup.jl"))
    ); recursive=true)

links = InterLinks(
    "Julia" => "https://docs.julialang.org/en/v1/",
    "Satisfiability" => "https://elsoroka.github.io/Satisfiability.jl/dev/"
)

bib = CitationBibliography(
    joinpath(@__DIR__, "src", "refs.bib");
)

makedocs(;
    modules=[ZebraPuzzles],
    authors="Martin Kunz <martinkunz@email.cz> and contributors",
    sitename="ZebraPuzzles.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kunzaatko.github.io/ZebraPuzzles.jl",
        edit_link="trunk",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API Reference" => "reference.md",
    ],
    plugins=[bib, links],
    doctest=false # tests run in `test/runtests.jl`
)

deploydocs(;
    repo="github.com/kunzaatko/ZebraPuzzles.jl",
    devbranch="trunk",
)
