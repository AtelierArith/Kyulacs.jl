using Markdown
using Kyulacs
using Kyulacs:LazyHelp
using Documenter
import Documenter.Utilities.MDFlatten: mdflatten

function Documenter.Writers.HTMLWriter.mdconvert(
    h::LazyHelp,
    parent;
    kwargs...,
)
    s = Kyulacs.gendocstr(h)
    # quote docstring `s` to prevent changing display result
    m = Markdown.parse(
        """
        ```
        $s
        ```
        """
        )
    Documenter.Writers.HTMLWriter.mdconvert(m, parent; kwargs...)
end

mdflatten(io::IOBuffer, h::LazyHelp, md::Markdown.MD) = nothing

#DocMeta.setdocmeta!(Kyulacs, :DocTestSetup, :(using Kyulacs); recursive=true)

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
