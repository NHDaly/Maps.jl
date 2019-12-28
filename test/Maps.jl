import Maps
using Test

@testset "earth globe" begin
    scene = (Maps.globe())
end
@testset "mars globe" begin
    display(Maps.globe(Maps.mars_img()))
end

@testset "usa" begin
    display(Maps.usa())
end
