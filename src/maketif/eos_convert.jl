using ArchGDAL, CSV, DataFrames, HDF5, DataFramesMeta

  
  # O(length(x)+length(y))
  closestDistanceFunction = f_closestDistanceFunction
  extractWvl = f_extractWvl


  function closestWvl(wvl::Array{Int64,1}, x::Int64)
      y = abs.(wvl .- x)
    # lapply(selbands_vnir, FUN = function(x) which.min(abs(wl_vnir - x))))
      minimum(abs.(wvl .- x))
  end

  """
  maketif(
    in_file,##NB: in_file dev esser già aperto, a diff di pr_convert
    out_file::String;
    allowed_errors = nothing, #array containing ids of errors to cut from product tif
    source="HCO",
    PAN=true,#boolean: true-> creates panchromatic tif
    VNIR=true,#boolean: true-> creates vnir tif
    SWIR=true, #boolean: true-> creates swir tif 
    FULL=true,#boolean: true-> creates full tif
    join_priority="VNIR", #choose wether to overwrite SWIR or VNIR bands in FULL tif
    overwrite=false, #choose wether to overwrite files
    selbands_vnir=nothing, #vnir bands to get
    selbands_swir=nothing, #swir bands to get
    indexes=nothing,
    cust_indexes=nothing
    )


Gets bands from an already opened HDF5 file and saves them in a .tif raster file
```julia
using PrismaConvert
maketif(my_dict["file 0"], "out/result")
```
"""
  function maketif(in_file,##NB: in_file dev esser già aperto, a diff di pr_convert
      out_file::String;
      allowed_errors = nothing,
      source="HCO",
      PAN=true,#boolean: true-> crea tif pancromatico
      VNIR=true,#boolean: true-> crea tif cubo vnir
      SWIR=true, #boolean: true-> crea tif pancromatico
      FULL=true,#boolean: true-> crea tif pancromatico
      join_priority="VNIR",
      overwrite=false,
      selbands_vnir=nothing,
      selbands_swir=nothing,
      indexes=nothing,
      cust_indexes=nothing)

    println("maketif start")


    @show out_folder = f_dirname(out_file)
    println("creating folder $out_folder")
    mkpath(out_folder)
    println("made folder")


    basefile = f_fileSansExt(out_file)

    ##raccolta attributi
    println("loading attributes...")
    proc_lev = getAttr(in_file, "Processing_Level")

    # Get wavelengths and fwhms ----
    wl_vnir = getAttr(in_file, "List_Cw_Vnir")
    wl_swir = getAttr(in_file, "List_Cw_Swir")
    fwhm_vnir = getAttr(in_file, "List_Fwhm_Vnir")
    fwhm_swir = getAttr(in_file, "List_Fwhm_Swir")

    # get additional metadata
    sunzen  = getAttr(in_file, "Sun_zenith_angle")
    sunaz  = getAttr(in_file, "Sun_azimuth_angle")
    acqtime  = getAttr(in_file, "Product_StartTime")

    # riordinazioni
    order_vnir = sortperm(wl_vnir)# permut
    wl_vnir = wl_vnir[order_vnir]
    order_swir = sortperm(wl_swir)
    wl_swir = wl_swir[order_swir]
    fwhm_vnir = fwhm_vnir[order_vnir]
    fwhm_swir = fwhm_swir[order_swir]

    # join
    fwhms = vcat(fwhm_vnir, fwhm_swir)
    wls = vcat(wl_vnir, wl_swir)


    #type check selbands
    if !isnothing(selbands_vnir) && typeof(selbands_vnir[1])!= Float32
      selbands_vnir = Base.convert(Array{Float32,1},selbands_vnir)
    end
    if !isnothing(selbands_swir) && typeof(selbands_swir[1])!= Float32
      selbands_swir = Base.convert(Array{Float32,1},selbands_swir)
    end


    # create the "META" ancillary txt file----
    out_file_angles = string(basefile, "_ANGLES.txt")
    ang_df = DataFrame(date=acqtime, sunzen=sunzen, sunaz=sunaz)
    CSV.write(out_file_angles, ang_df)


    # get VNIR data cube and convert to raster ----
    if VNIR
      println("building VNIR raster...")
      try
        out_file_vnir = create_cube(in_file,proc_lev,source,basefile,wl_vnir,order_vnir,fwhm_vnir;
          overwrite =overwrite,type="VNIR",selbands=selbands_vnir, allowed_errors=allowed_errors)
      catch e
        println("error:")
        println(e)
        VNIR = false
      end
    end



    # get SWIR data cube and convert to raster ----
    if SWIR
      println("building SWIR raster...")
      try
        out_file_swir = create_cube(in_file,proc_lev,source,basefile,wl_swir,order_swir,fwhm_swir;
          overwrite =overwrite,type="SWIR",selbands=selbands_swir, allowed_errors=allowed_errors)
      catch e
        println("error:")
        println(e)
        SWIR = false
      end
    end



    #    Create and write the FULL hyperspectral cube if needed ----
    if FULL
      println("building FULL raster...")
      #get geo
      try
        geo = eos_geoloc.get(in_file,"VNIR")#
        out_file_full = create_full(basefile,join_priority,overwrite,geo)
      catch e
        println("error:")
        println(e)
        FULL = false
      end
    end


    # Save PAN if requested ----
    if PAN
      try
        out_file_pan = create_pan(in_file,proc_lev,basefile;overwrite=overwrite)
      catch e
        println("error:")
        println(e)
        PAN = false
      end
    end

  end

