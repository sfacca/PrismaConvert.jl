### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 829cf270-3b23-11eb-1509-0172e74ca940
using ImageTransformations, CoordinateTransformations, Rotations

# ╔═╡ c9d546d0-3ee6-11eb-022d-5d7badf11f43
"""   

    plot_linewise(
        band::Array{T,2}
    ) 
Plots 2d input as a 1d array


    plot_linewise(
            cube::Array{T,3}
            )
Returns linewise plot of each band
"""
function plot_linewise(cube::Array{T,3}) where T
    plots = Array{Plots.Plot,1}(undef,size(cube)[3])
    for band_i in 1:size(cube)[3]
        b = imresize(preliminary(cube[:,:,band_i]), ratio = 1/20)
        plots[band_i] = plot(reshape(b, length(b)), legend= false, title="band $band_i", xlabel="column", ylabel="value") 
    end 
    plot(plots...)
end

# ╔═╡ cea32290-3ee6-11eb-35a2-97be740d2b6b
function plot_linewise(band::Array{T,2}) where T
    b = imresize(preliminary(band), ratio = 1/20)
    plot(reshape(b, length(b)), legend= false)  
end

# ╔═╡ d4a47540-3ee6-11eb-1482-03c7053b30f5
"""   

    plot_cols
        band::Array{T,2}
    ) 
Plots columns

"""
function plot_cols(band)
    p = plot(legend=false)
    for i in 1:size(band)[2]
        plot!(filter(!iszero, band[:,i]))
    end
    p
end 

# ╔═╡ d84bab50-3ee6-11eb-1551-97c475da2664
"""   

    plot_rows(
        band::Array{T,2}
    ) 
Plots plot rows

"""
function plot_rows(band)    
    p = plot(legend=false)
    for i in 1:size(band)[1]        
        plot!(filter((x)->(x[2]!=0), [(band[i,j], j) for j in 1:length(band[i,:])]))
    end
    p
end

# ╔═╡ 1b914ab0-3af4-11eb-2b9c-1f8a66af86c4
"""   

    plot_band(
        band::Array{T,2}
    )

Squares the band, then returns heatmap of the downsized map, columns polot and rows plot

"""
function plot_band(band)    
    # 4 resize
    band = imresize(preliminary(band), ratio = 1/20)
    # 5 define plots
    hm = heatmap(band)
    
    rowp = plot_rows(band)
    
    colp = plot_cols(band)
    
    pad = plot()
    
    plot(colp, pad, hm, rowp)
end

# ╔═╡ Cell order:
# ╠═829cf270-3b23-11eb-1509-0172e74ca940
# ╠═1b914ab0-3af4-11eb-2b9c-1f8a66af86c4
# ╠═c9d546d0-3ee6-11eb-022d-5d7badf11f43
# ╠═cea32290-3ee6-11eb-35a2-97be740d2b6b
# ╠═d4a47540-3ee6-11eb-1482-03c7053b30f5
# ╠═d84bab50-3ee6-11eb-1551-97c475da2664
