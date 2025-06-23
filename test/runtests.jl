using ZebraPuzzles
using Test
using Aqua

@testset "ZebraPuzzles.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ZebraPuzzles)
    end
    # Write your tests here.
end
