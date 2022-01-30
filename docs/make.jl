using Kyulacs
using Documenter

DocMeta.setdocmeta!(Kyulacs, :DocTestSetup, :(using Kyulacs); recursive=true)

makedocs(;
    modules=[Kyulacs],
    authors="Satoshi Terasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo="https://github.com/terasakisatoshi/Kyulacs.jl/blob/{commit}{path}#{line}",
    sitename="Kyulacs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://terasakisatoshi.github.io/Kyulacs.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/terasakisatoshi/Kyulacs.jl",
    devbranch="main",
)