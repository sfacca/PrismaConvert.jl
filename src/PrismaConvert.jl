module PrismaConvert


include("maketif/includes.jl")
include("HDF5filesDict/HDF5filesDict.jl")


export maketif, open, close

maketif = eos_convert.maketif

function open(f)
    open(f,"r")
end
function open(f,mode::String)
    HDF5fd.filesDict(f,mode)
end

close = HDF5fd.closeall


end # module
