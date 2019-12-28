module Maps # end

using Makie

using FileIO, Colors, JSON

earth_img() = "https://svs.gsfc.nasa.gov/vis/a000000/a002900/a002915/bluemarble-2048.png"
mars_img() = "https://www.jpl.nasa.gov/spaceimages/images/largesize/PIA23518_hires.jpg"

"""
    globe(args...)
Display a 3D globe in a Makie plot.

Any extra plotting arguments will be passed-through to Makie.
See [Makie.plot](@ref) arguments for more details.
"""
function globe(image=earth_img(), args...; kwargs...)
    earth = try
        load(download(image))
    catch e
        @warn("Downloading the image failed. Using random image, so this test will fail! (error: $e)")
        rand(RGBAf0, 100, 100) # don't error test when e.g. offline
    end;
    m = GLNormalUVMesh(Sphere(Point3f0(0), 1f0), 60);
    scene = mesh(m, args...; color = earth, shading = false, kwargs...);
    Makie.AbstractPlotting.cam3d_cad!(scene)

    scene
end


"""
    usa(resolution = 0.025, args...)
Display a 2D map of the United States, on an Equirectangular projection.

Any extra plotting arguments will be passed-through to Makie.
See [Makie.plot](@ref) arguments for more details.

Data comes from http://openstreetmap.org.
"""
function usa(resolution = 0.015, args...; kwargs...)
    allregions = usa_polygons()
    scene = plot_regions(allregions, args...; resolution = resolution, kwargs...)
    text!(scene,
          "© OpenStreetMap contributors",
          position = (0,0),
          color = :red,
         )
    scene
end
function usa_polygons()
    USA_json = JSON.parse(open("data/nominatim/USA.json", "r"))
    allregions = USA_json[1]["geojson"]["coordinates"]
    # Flatten the regions (for some reason they're all in a nested vector)
    allregions = [Point2f0.(map.(Float32, c))
                     for r in allregions
                     for c in r]
    sort(allregions, by=length, rev=true)
end

function scale_region(region, resolution)
    scale = (1/resolution)
    orig_size = length(region)
    if scale >= orig_size÷2
        scale = orig_size÷2 - 1
    end

    # Skip every nth element, incrementing counter by floating point
    out_size = Int(ceil(1/scale * orig_size))
    out = similar(region, out_size)
    r_idx, out_idx = 1,1
    while floor(Int, r_idx) <= orig_size
        out[out_idx] = region[floor(Int, r_idx)]
        r_idx += scale
        out_idx += 1
    end
    out
end
function plot_regions(regions, args...; kwargs...)
    scene = Scene()
    for r in regions
        plot_region!(scene, r, args...; kwargs...)
    end
    scene
end
function plot_region!(scene, region::Array{Point2f0}, pltargs...; resolution = 0.01, pltkwargs...)
    scaled = scale_region(region, resolution)
    # NOTE: there is an error in `poly` that it sometimes deletes a point from inputs! D:
    # https://github.com/JuliaPlots/Makie.jl/issues/417
    # So for now, we copy() the input and wrap it in a try/catch
    try
        Makie.poly!(scene, copy(scaled), pltargs...; pltkwargs...)
    catch e
        e isa ErrorException && return scene
        rethrow()
    end
end



end # module
