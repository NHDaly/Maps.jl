import Maps
using Test

@testset "earth globe" begin
    scene = (Maps.globe())
end
@testset "mars globe" begin
    display(Maps.globe(Maps.mars_img()))
end

@testset "usa small" begin
    display(Maps.usa(0.001))
end
@testset "usa default" begin
    display(Maps.usa())
end
