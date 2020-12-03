### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ f5ddd0e0-3576-11eb-1c87-bf17abcf269c
using Pkg, BenchmarkTools

# ╔═╡ 9fe5e970-3576-11eb-3dc5-f592eb5111ea
include("../src/PrismaConvert.jl");

# ╔═╡ f9e77240-3576-11eb-2085-ff9890e61b26
Pkg.activate(".")

# ╔═╡ 0c7348e0-3580-11eb-1967-99c189cc2900
f = PrismaConvert.open("../../stage-Machine-learning/prisma/hdf5/data/PRS_L2D_STD_20190911102308_20190911102313_0001.he5")

# ╔═╡ 2cccc60e-3577-11eb-2523-9989e3a846ab
try
	@show @btime PrismaConvert.maketif(
	f.dict["file $((f.counter) - 1)"],
	"out"
)
	x = 1
catch e
	PrismaConvert.close(f)
	e
end

# ╔═╡ ac48ae30-358c-11eb-35d0-9f47cc4ed5b3
if x || !x
	PrismaConvert.close(f)
end

# ╔═╡ Cell order:
# ╠═f5ddd0e0-3576-11eb-1c87-bf17abcf269c
# ╠═f9e77240-3576-11eb-2085-ff9890e61b26
# ╠═9fe5e970-3576-11eb-3dc5-f592eb5111ea
# ╠═0c7348e0-3580-11eb-1967-99c189cc2900
# ╠═2cccc60e-3577-11eb-2523-9989e3a846ab
# ╠═ac48ae30-358c-11eb-35d0-9f47cc4ed5b3
