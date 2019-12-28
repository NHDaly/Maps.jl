module Maps # end

using Makie

using FileIO, Colors, JSON

function globe()
    earth = try
        load(download("https://svs.gsfc.nasa.gov/vis/a000000/a002900/a002915/bluemarble-2048.png"))
    catch e
        @warn("Downloading the earth failed. Using random image, so this test will fail! (error: $e)")
        rand(RGBAf0, 100, 100) # don't error test when e.g. offline
    end;
    m = GLNormalUVMesh(Sphere(Point3f0(0), 1f0), 60);
    scene = mesh(m, color = earth, shading = false);
    Makie.AbstractPlotting.cam3d_cad!(scene)

    scene
end


function usa(resolution = 0.025)
    allregions = usa_polygons()
    scene = plot_regions(allregions, resolution = resolution)
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
