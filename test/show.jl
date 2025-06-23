using Random
using ZebraPuzzles: ZebraPuzzles as ZP

@testset "phrases" begin
    Random.seed!(42)
    rand_clues = [rand(Clue, ZP.EINSTEINS_ZEBRA) for _ in Base.OneTo(100)]
    @test all(isuppercase(first(ZP.phrase(c))) && last(ZP.phrase(c)) == '.' for c in rand_clues)
end
