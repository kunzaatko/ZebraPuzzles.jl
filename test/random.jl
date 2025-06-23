using ZebraPuzzles: ZebraPuzzles as ZP
using Random

Random.seed!(42)

solved_random_clues = [rand(Clue, ZP.EINSTEINS_ZEBRA) for _ in Base.OneTo(1000)]

@test all(solved_random_clues) do c # all randomly generated clues are valid and have the correct types and variants
    return try
        ZP.check(ZP.EINSTEINS_ZEBRA, c; valid=true, variants=true, implied=false, types=true, duplicates=false, minimal=false)
        true
    catch
        false
    end
end

unsolved_random_clues = [rand(Clue, ZP.UNSOLVED_EINSTEINS_ZEBRA) for _ in Base.OneTo(1000)]
@test all(unsolved_random_clues) do c
    return try
        ZP.check(ZP.UNSOLVED_EINSTEINS_ZEBRA, c; valid=false, variants=true, implied=false, types=true, duplicates=false, minimal=false)
        true
    catch
        false
    end
end
