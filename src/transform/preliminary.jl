### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 2033b840-3ee7-11eb-3694-8d16fa097cec
using ImageTransformations, CoordinateTransformations, Rotations

# ╔═╡ 010706d0-3ee6-11eb-2289-ad087f58bada
md"preliminary(band) function straightens band and removes empty cells"

# ╔═╡ 4f22e820-3ee6-11eb-3865-4da830b0da02
function fix_points(first_e::Array{Array{Int,1},1})
    # find usable points
    usable = [true for _ in first_e]
    max_width = maximum([i[2] for i in first_e])
    max_height = maximum([i[1] for i in first_e])
    for i in 1:length(first_e)
        if first_e[i][1] == max_height || first_e[i][1] == 1
            if first_e[i][2] == max_width || first_e[i][2] == 1
                usable[i] = false
            end
        end 
    end
    
    fixed = true
    #fixing A
    if !usable[1]
        if !usable[4]
            fixed = false
        else
            first_e[1][2] = max_width - first_e[3][2]
        end
    end
    #fixing B
    if !usable[2]
        if !usable[3]
            fixed = false
        else
            first_e[2][1] = max_height - first_e[3][1]
        end
    end    
    #fixing C
    if !usable[3]
        if !usable[2]
            fixed = false
        else
            first_e[3][1] = max_height - first_e[2][1]
        end
    end
    #fixing D
    if !usable[4]
        if !usable[1]
            fixed = false
        else
            first_e[4][2] = max_width - first_e[1][2]
        end
    end
    first_e
end

# ╔═╡ 75cf9270-3ee6-11eb-1ce8-b580053f6497
function find_points_of_square(cube::Array{T,3}) where T
	[find_points_of_square(cube[:,:,i]) for i in 1:size(cube)[3]]
end

# ╔═╡ 75cfb980-3ee6-11eb-1dd0-fb0ccddb235b
function calc_angle(points::Array{Array{Int,1},1})
    opposite = points[1][2]
    adjacent = points[3][1]
    cot(opposite/adjacent)
end

# ╔═╡ 75d62220-3ee6-11eb-2dec-932db5c1adb6
function tilt_band(first_e, img)
    max_width = maximum(first_e[:][2])
    opposite = first_e[1][2] - max_width
    adjacent = first_e[2][1]
    angle = cot(opposite/adjacent)
    # define transformation
    trfm = recenter(RotMatrix(angle/π), ImageTransformations.center(img))
    collect(warp(img, trfm))
end

# ╔═╡ 75d67040-3ee6-11eb-0c0d-1d2921d2dc74
function M_iszero(x)
    iszero(x) || isnan(x)
end

# ╔═╡ 75cf444e-3ee6-11eb-3d1f-a5d00d3670fe
function find_points_of_square(band::Array{T,2}) where T
	#A B
	#C D
	width = size(band)[2]
	height = size(band)[1]
	##########################	A
	i = 1
	found = false
	while i<width && !found
		if !M_iszero(band[1,i])
			found = true
		else
			i = i+1
		end
	end
	A = [1,i]
	##########################	B
	i = 1
	found = false
	while i<height && !found
		if !M_iszero(band[i,width])
			found = true
		else
			i = i+1
		end
	end
	B = [i, width]
	##########################	C
	i = 1
	found = false
	while i>height && !found
		if !M_iszero(band[i,1])
			found = true
		else
			i = i+1
		end
	end
	C = [height,i]
	##########################	D
	i = 1
	found = false
	while i<width && !found
		if !M_iszero(band[height,i])
			found = true
		else
			i = i+1
		end
	end
	D = [height,i]
	[A, B, C, D]
end

# ╔═╡ 75dab600-3ee6-11eb-1bff-fd216010eba7
function crop_out_zeros(band::Array{T,2}) where T
    width = size(band)[2]
    height = size(band)[1]
    #1 find how many rows we snip from 0
    UProws = 0
    i=1
    found= false
    while !found
        if count(!M_iszero,band[i,:])>0
            found = true
            UProws = i
        else
            i = i+1
        end
    end
    #2 find rows to snip from the bottom
    DOrows=0
    i=0
    found= false
    while !found
        if count(!M_iszero,band[height-i,:])>0
            found = true
            DOrows = i
        else
            i = i + 1
        end
    end
    #3 find cols to snip from the left
    Lcols=0
    i=1
    found= false
    while !found
        if count(!M_iszero,band[:,i])>0
            found = true
            Lcols = i
        else
            i = i+1
        end
    end
    #4 find cols to snip from the right
    Rcols=0
    i=0
    found= false
    while !found
        if count(!M_iszero,band[:,width-i])>0
            found = true
            Rcols = i
        else
            i = i+1
        end
    end
    #4 get cropped band
    band[UProws:(height-DOrows),Lcols:(width-Rcols)]
end

# ╔═╡ e1f8a0e0-3ee6-11eb-1a3e-e54a9e0f82cb
function NaN_zeros!(band)
    for i in 1:length(band)
        if band[i] == 0
            band[i] = NaN
        end
    end
    band
end

# ╔═╡ e6810f30-3ee6-11eb-0161-d1771c0ae73b
function zero_NaNs(band)
    for i in 1:length(band)
        if isnan(band[i])
            band[i] = 0
        end
    end
    band
end

# ╔═╡ 950cdb20-3ee6-11eb-2132-a9e0651bbceb
function preliminary(band)
    # 1 crop
    band = crop_out_zeros(band)
    # 2 find points
    points = fix_points(find_points_of_square(band))
    # 3 tilt
    zero_NaNs(crop_out_zeros(tilt_band(points, band)))
end

# ╔═╡ Cell order:
# ╟─010706d0-3ee6-11eb-2289-ad087f58bada
# ╠═2033b840-3ee7-11eb-3694-8d16fa097cec
# ╠═4f22e820-3ee6-11eb-3865-4da830b0da02
# ╠═75cf444e-3ee6-11eb-3d1f-a5d00d3670fe
# ╠═75cf9270-3ee6-11eb-1ce8-b580053f6497
# ╠═75cfb980-3ee6-11eb-1dd0-fb0ccddb235b
# ╠═75d62220-3ee6-11eb-2dec-932db5c1adb6
# ╠═75d67040-3ee6-11eb-0c0d-1d2921d2dc74
# ╠═75dab600-3ee6-11eb-1bff-fd216010eba7
# ╠═e1f8a0e0-3ee6-11eb-1a3e-e54a9e0f82cb
# ╠═e6810f30-3ee6-11eb-0161-d1771c0ae73b
# ╠═950cdb20-3ee6-11eb-2132-a9e0651bbceb
