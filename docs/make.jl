using ContinuumMechanicsBase
using Documenter


DocMeta.setdocmeta!(ContinuumMechanicsBase, :DocTestSetup, :(using ContinuumMechanicsBase); recursive=true)

makedocs(;
    modules=[ContinuumMechanicsBase],
    authors="Carson Farmer <59753859+cfarm6@users.noreply.github.com> and contributors",
    repo="https://github.com/cfarm6/ContinuumMechanicsBase.jl/blob/{commit}{path}#{line}",
    sitename="ContinuumMechanicsBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cfarm6.github.io/ContinuumMechanicsBase.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/TRACER-LULab/ContinuumMechanicsBase.jl",
    devbranch="main",
)
