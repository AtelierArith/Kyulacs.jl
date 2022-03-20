using Markdown
using Kyulacs
using Kyulacs:LazyHelp
using Documenter
import Documenter.Utilities.MDFlatten: mdflatten

#DocMeta.setdocmeta!(Kyulacs, :DocTestSetup, :(using Kyulacs); recursive=true)

mdflatten(io::IOBuffer, h::LazyHelp, md::Markdown.MD) = nothing

makedocs(;
    modules=[Kyulacs],
    authors="Satoshi Terasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo="https://github.com/AtelierArith/Kyulacs.jl/blob/{commit}{path}#{line}",
    sitename="Kyulacs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AtelierArith.github.io/Kyulacs.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    doctest=false,
)

deploydocs(;
    repo="github.com/AtelierArith/Kyulacs.jl",
    devbranch="main",
)
