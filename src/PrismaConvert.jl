module PrismaConvert


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


export maketif, open, close


function open(f)
    open(f,"r")
end
function open(f,mode::String)
    HDF5fd.filesDict(f,mode)
end

close = HDF5fd.closeall


end # module
