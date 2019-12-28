import Maps
using Test

@testset "globe" begin
    display(Maps.globe())
end

@testset "usa" begin
    display(Maps.usa())
end
