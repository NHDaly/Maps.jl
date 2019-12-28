module Maps # end

using Makie

using FileIO, Colors

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
globe()


end # module
