### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 7e37b070-3b0b-11eb-2e99-93952e5959ab
using Pkg

# ╔═╡ c4c309d0-3ada-11eb-1221-1b001618cba6
using ArchGDAL, CSV, DataFrames

# ╔═╡ 829cf270-3b23-11eb-1509-0172e74ca940
using ImageTransformations, CoordinateTransformations, Rotations

# ╔═╡ d1473210-3b18-11eb-3145-05c8e176c4e3
using Plots

# ╔═╡ 5200dae0-3aed-11eb-2097-a1515f34fbef
include("../PrismaConvert.jl")

# ╔═╡ 8032bd20-3b0b-11eb-34ae-772fe98113f3
Pkg.activate("../../.")

# ╔═╡ e185c5b0-3b13-11eb-0714-ffab26f41e00
Pkg.add("Rotations")

# ╔═╡ bd8c5980-3adc-11eb-1fff-17a57090d802
md"
1. get data from tiff
2. lower resolution on cube
3. plot"

# ╔═╡ 53efbd20-3aee-11eb-2d8a-6de042d3efe2
wvls = CSV.read("../out/prod_VNIR.wvl", DataFrame)

# ╔═╡ 1b914ab0-3af4-11eb-2b9c-1f8a66af86c4


# ╔═╡ 608fe7c0-3afe-11eb-1a79-3107d1f7dc2b
function closest_index(x::Array{T,1}, val::Q) where {T <: Number, Q <: Number}
    ibest = 1
    dxbest = abs(x[ibest]-val)
    for I in 1:length(x)
        dx = abs(x[I]-val)
        if dx < dxbest
            dxbest = dx
            ibest = I
        end
    end
    ibest
end

# ╔═╡ 62fff600-3b01-11eb-0d4e-a1d2a75d6321
function closest_index(x::Array{T,1}, val::Array{Q,1}) where {T <: Number, Q <: Number}
    [closest_index(x,val[i]) for i in 1:length(val)]
end

# ╔═╡ 9def6c30-3afe-11eb-21cc-79a81d90ce92
wvls[!,:wl]

# ╔═╡ 97bf6860-3afe-11eb-2b26-61e698df8a56
closest_index(wvls[!,:wl],[800,400,600])

# ╔═╡ 365edd30-3af4-11eb-1caa-69f1b2615420
wvls[!,:wl][closest_index(wvls[!,:wl],[800,400,600])]

# ╔═╡ d071d7f0-3adc-11eb-2c2b-6557766d1da4


# ╔═╡ 49e1d850-3aed-11eb-1c13-8f2e2a42a063
# parameters
begin
	tiff = "../out/prod_SWIR.tif"
	bands = [4,5,6,7,8,9,10,55,21]
end

# ╔═╡ 9a9f163e-3ade-11eb-1fd1-395d11b3f4f6
dataset = ArchGDAL.read("../out/prod_SWIR.tif")

# ╔═╡ 3c47e9c0-3af0-11eb-3a27-1355835d9624
cube = Array{typeof(ArchGDAL.getband(dataset, 1)[1,1]),3}(
	undef,
	ArchGDAL.width(dataset),
	ArchGDAL.height(dataset), 
	length(bands)
)

# ╔═╡ 73287fb0-3af3-11eb-3f95-0312deacf47f
for i in 1:length(bands)
	global cube[:,:,i] = ArchGDAL.getband(dataset, bands[i])
end

# ╔═╡ 0982db42-3b08-11eb-2f49-fd3386b5f91d
md"cube[height=row,width=column,depth=band]"

# ╔═╡ 302400be-3af0-11eb-213a-af5926c8a8ba
#=function localized_mean_matrix(cube, x, y)
	reduced_cube = Array{typeof(cube[1]),2}(
		undef, 
		Int(round(size(cube)[1]/y)),
		Int(round(size(cube)[2]/x))
	)	
	
end=#

# ╔═╡ 2c9a2c00-3b17-11eb-223d-89cb56299303
function resize_cube(cube::Array{T,3},ratio) where T
	band1 = imresize(cube[:,:,1],ratio=ratio)
	cubeR = Array{typeof(band1[1]),3}(
		undef, 
		size(band1)[1],
		size(band1)[2],
		size(cube)[3]
	)
	cubeR[:,:,1]=band1
	for i in 2:size(cube)[3]
		cubeR[:,:,i] = imresize(cube[:,:,i],ratio=ratio)
	end
	cubeR
end

# ╔═╡ 8c4ab5e0-3b24-11eb-37fe-47f66644d427
function resize_cube(cube::Array{T,2},ratio) where T
	imresize(cube,ratio=ratio)
end

# ╔═╡ 0a327c30-3b08-11eb-0ad4-89e3822ff61a
md"cube[height=row,width=column,depth=band]"

# ╔═╡ 160b8640-3b18-11eb-1aae-833aff1da963
resized_cube = resize_cube(cube,1/20)

# ╔═╡ 5d867980-3b18-11eb-248b-0dbf18ac8d7d
resized_cube

# ╔═╡ d4859430-3b18-11eb-1d82-1d83aeac2a93
size(resized_cube)[1]*size(resized_cube)[2]

# ╔═╡ b7f06ba0-3b19-11eb-1ab8-d98c6e0e501c
minimum(resized_cube[:,:,1])

# ╔═╡ c4aa2c00-3b19-11eb-0e53-d3e74b229648
function get_ranges(cube)
	minimums = Array{typeof(cube[1]),1}(undef,size(cube)[3])
	maximums = Array{typeof(cube[1]),1}(undef,size(cube)[3])
	for i in 1:size(cube)[3]
		minimums[i] = minimum(filter(!iszero,cube[:,:,i]))
		#above errors if all elements are 0
		maximums[i] = maximum(cube[:,:,i])
	end
	[(minimums[i],maximums[i]) for i in 1:length(maximums)]
end
	

# ╔═╡ 2813b220-3b1a-11eb-13e9-779ab62b0045
ranges = get_ranges(resized_cube)

# ╔═╡ 34c91040-3b1b-11eb-1d3e-25ace50f8209
heatmap(resized_cube[:,:,2])

# ╔═╡ 78665420-3b1b-11eb-0521-0f3c403d39ab
levels = ranges[2][1]:(ranges[2][2]-ranges[2][1])/5:ranges[2][2]

# ╔═╡ cd1c1ea0-3b1b-11eb-1976-e7613d9cba61
contour!(resized_cube[:,:,2],levels=levels, linecolor=:black, contour_labels = true)

# ╔═╡ 4027b802-3b1c-11eb-0eda-d3739a797b86
md"need to rotate...

1. get height of "

# ╔═╡ 638377b0-3b1e-11eb-33bf-85fe219605f6
function find_points_of_square(band::Array{T,2}) where T
	#A B
	#C D
	width = size(band)[2]
	height = size(band)[1]
	##########################	A
	i = 1
	found = false
	while i<width && !found
		if band[1,i] != 0
			found = true
		else
			i = i+1
		end
	end
	A = (1,i)
	##########################	B
	i = 1
	found = false
	while i<height && !found
		if band[i,width] != 0
			found = true
		else
			i = i+1
		end
	end
	B = (i, width)
	##########################	C
	i = 1
	found = false
	while i>height && !found
		if band[i,1] != 0
			found = true
		else
			i = i+1
		end
	end
	C = (height,i)
	##########################	D
	i = 1
	found = false
	while i<width && !found
		if band[height,i] != 0
			found = true
		else
			i = i+1
		end
	end
	D = (height,i)
	(A, B, C, D)
end

# ╔═╡ e1409e00-3b21-11eb-280f-738e10307383
function find_points_of_square(cube::Array{T,3}) where T
	[find_points_of_square(cube[:,:,i]) for i in 1:size(cube)[3]]
end

# ╔═╡ c4b492a0-3b21-11eb-065d-1b49328223c5
points = find_points_of_square(cube)

# ╔═╡ 26255600-3b22-11eb-1f12-45fd18eff563
points[1][1]

# ╔═╡ 33569052-3b22-11eb-1450-95589094dd91
points[2][1]

# ╔═╡ 74d2f000-3b22-11eb-228a-dfa45dad9502
first_e = points[1]

# ╔═╡ 383e35a0-3b22-11eb-1456-97119f97e4c2
begin
	found_different = false
	for i in points
		if i != first_e
			global found_different = true
		end
	end
end

# ╔═╡ 85b06970-3b22-11eb-02c8-81e438621eee
found_different

# ╔═╡ a7191da0-3b22-11eb-39ad-0be2dbed81a3
md"calc angle of (0,0) A C triangle, knowing that (0,0) is right"

# ╔═╡ c91b0490-3b22-11eb-28eb-9b2f7fb3f19d
begin
	opposite = first_e[1][2]
	adjacent = first_e[3][1]
	global angle = cot(opposite/adjacent)
end

# ╔═╡ d5f97d42-3b1d-11eb-26a2-e9ad45f07088
begin
	# define transformation
	img = cube[:,:,2]
	trfm = recenter(RotMatrix(-angle), ImageTransformations.center(img))
	imgw = warp(img, trfm)
end

# ╔═╡ 4d8db260-3b26-11eb-070f-c9e94260b69f
size(img)

# ╔═╡ 4a5bddf0-3b27-11eb-33f7-7bb9483f6cd6
ImageTransformations.center(img)

# ╔═╡ 541c89f0-3b24-11eb-1434-13af1e6e6fd5
resized_rotated = resize_cube(imgw,1/10)

# ╔═╡ e6b0f3f2-3b24-11eb-3961-cf3551b8707b
RotMatrix(-angle)

# ╔═╡ fef9d75e-3b24-11eb-26b9-2d21e45a51a3
trfm

# ╔═╡ 2f83c852-3b20-11eb-1ae1-750655adfc17
md"cube[height=row,width=column,depth=band]"

# ╔═╡ Cell order:
# ╠═7e37b070-3b0b-11eb-2e99-93952e5959ab
# ╠═8032bd20-3b0b-11eb-34ae-772fe98113f3
# ╠═e185c5b0-3b13-11eb-0714-ffab26f41e00
# ╠═c4c309d0-3ada-11eb-1221-1b001618cba6
# ╠═829cf270-3b23-11eb-1509-0172e74ca940
# ╟─bd8c5980-3adc-11eb-1fff-17a57090d802
# ╠═5200dae0-3aed-11eb-2097-a1515f34fbef
# ╠═53efbd20-3aee-11eb-2d8a-6de042d3efe2
# ╠═1b914ab0-3af4-11eb-2b9c-1f8a66af86c4
# ╠═608fe7c0-3afe-11eb-1a79-3107d1f7dc2b
# ╠═62fff600-3b01-11eb-0d4e-a1d2a75d6321
# ╠═9def6c30-3afe-11eb-21cc-79a81d90ce92
# ╠═97bf6860-3afe-11eb-2b26-61e698df8a56
# ╠═365edd30-3af4-11eb-1caa-69f1b2615420
# ╠═d071d7f0-3adc-11eb-2c2b-6557766d1da4
# ╠═49e1d850-3aed-11eb-1c13-8f2e2a42a063
# ╠═9a9f163e-3ade-11eb-1fd1-395d11b3f4f6
# ╠═3c47e9c0-3af0-11eb-3a27-1355835d9624
# ╠═73287fb0-3af3-11eb-3f95-0312deacf47f
# ╟─0982db42-3b08-11eb-2f49-fd3386b5f91d
# ╠═302400be-3af0-11eb-213a-af5926c8a8ba
# ╠═2c9a2c00-3b17-11eb-223d-89cb56299303
# ╠═8c4ab5e0-3b24-11eb-37fe-47f66644d427
# ╟─0a327c30-3b08-11eb-0ad4-89e3822ff61a
# ╠═160b8640-3b18-11eb-1aae-833aff1da963
# ╠═5d867980-3b18-11eb-248b-0dbf18ac8d7d
# ╠═d1473210-3b18-11eb-3145-05c8e176c4e3
# ╠═d4859430-3b18-11eb-1d82-1d83aeac2a93
# ╠═b7f06ba0-3b19-11eb-1ab8-d98c6e0e501c
# ╠═c4aa2c00-3b19-11eb-0e53-d3e74b229648
# ╠═2813b220-3b1a-11eb-13e9-779ab62b0045
# ╠═34c91040-3b1b-11eb-1d3e-25ace50f8209
# ╠═78665420-3b1b-11eb-0521-0f3c403d39ab
# ╠═cd1c1ea0-3b1b-11eb-1976-e7613d9cba61
# ╠═4027b802-3b1c-11eb-0eda-d3739a797b86
# ╠═638377b0-3b1e-11eb-33bf-85fe219605f6
# ╠═e1409e00-3b21-11eb-280f-738e10307383
# ╠═c4b492a0-3b21-11eb-065d-1b49328223c5
# ╠═26255600-3b22-11eb-1f12-45fd18eff563
# ╠═33569052-3b22-11eb-1450-95589094dd91
# ╠═74d2f000-3b22-11eb-228a-dfa45dad9502
# ╠═383e35a0-3b22-11eb-1456-97119f97e4c2
# ╠═85b06970-3b22-11eb-02c8-81e438621eee
# ╠═a7191da0-3b22-11eb-39ad-0be2dbed81a3
# ╠═c91b0490-3b22-11eb-28eb-9b2f7fb3f19d
# ╠═d5f97d42-3b1d-11eb-26a2-e9ad45f07088
# ╠═4d8db260-3b26-11eb-070f-c9e94260b69f
# ╠═4a5bddf0-3b27-11eb-33f7-7bb9483f6cd6
# ╠═541c89f0-3b24-11eb-1434-13af1e6e6fd5
# ╠═e6b0f3f2-3b24-11eb-3961-cf3551b8707b
# ╠═fef9d75e-3b24-11eb-26b9-2d21e45a51a3
# ╟─2f83c852-3b20-11eb-1ae1-750655adfc17
