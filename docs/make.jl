### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 66b9eb60-387d-11eb-0aec-912354dff2d6
using Documenter

include("../src/PrismaConvert.jl")

# ╔═╡ a4a55c20-387d-11eb-320a-5ba6a364fca7
#push!(LOAD_PATH,"../src/")

# ╔═╡ 77bb2400-387e-11eb-0dba-afec1de513a2
#pop!(LOAD_PATH)

# ╔═╡ ab6b5e60-387d-11eb-32c1-69d96662e61e
    makedocs(;
    modules=[PrismaConvert],
    repo="https://github.com/sfacca/PrismaConvert.jl/blob/{commit}{path}#L{line}",
    sitename="PrismaConvert.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://sfacca.github.io/PrismaConvert.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md"
    ],
    )

deploydocs(;
    repo = "github.com/sfacca/PrismaConvert.jl.git",
    push_preview=true,
)

# ╔═╡ Cell order:
# ╠═a4a55c20-387d-11eb-320a-5ba6a364fca7
# ╠═77bb2400-387e-11eb-0dba-afec1de513a2
# ╠═66b9eb60-387d-11eb-0aec-912354dff2d6
# ╠═ab6b5e60-387d-11eb-32c1-69d96662e61e
