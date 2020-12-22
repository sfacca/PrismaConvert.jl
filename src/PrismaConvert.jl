

"""
Main module for `PrismaConvert.jl` -- a Julia package for Prisma's HDF5 products. 

# Exports  
. maketif
. open
. close
. plot_band
. plot_linewise
. plot_cols
. plot_rows
"""
module PrismaConvert

using ArchGDAL, CSV, DataFrames, HDF5, DataFramesMeta
#

#include("maketif/includes.jl")
include("maketif/faux.jl")
include("maketif/eos_rastwrite_lines.jl")
include("maketif/eos_geoloc.jl")
include("maketif/eos_create_err.jl")
include("maketif/eos_errcube.jl")
include("maketif/eos_create.jl")
include("maketif/eos_create_pan.jl")
include("maketif/eos_create_FULL.jl")
include("maketif/eos_convert.jl")
include("HDF5filesDict/HDF5filesDict.jl")
include("transform/preliminary.jl")
include("plot/plot.jl")



export maketif, open, close, plot_band, plot_linewise, plot_cols, plot_rows

"""
    open(
        f,
        mode
    )

Opens a HDF5 file, returns a dictionary containing the opened file
```julia
using PrismaConvert
open("./file.h5")
```
File is opened in read only mode by default, can be opened in other modes by providng mode:
```julia
using PrismaConvert
open("./file.h5","w")
```
"""
function open(f)
    open(f,"r")
end
function open(f,mode::String)
    HDF5fd.filesDict(f,mode)
end
"""
    close(
        f
    )

Closes all files in the provided files dictionary, returns number of files closed
```julia
using PrismaConvert
close(my_dict)
```
"""
close = HDF5fd.closeall


end # module
