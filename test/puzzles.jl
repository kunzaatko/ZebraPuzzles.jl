## "puzzles" ##

using ZebraPuzzles: ZebraPuzzles as ZP

z = deepcopy(ZP.EINSTEINS_ZEBRA)
empty!(z.clues)
@test all(ZP.check(z, c) for c in ZP.EINSTEINS_ZEBRA.clues)
@test ZP.add_clues!(z, ZP.EINSTEINS_ZEBRA.clues) isa ZebraPuzzle
@test_throws ZP.MinimalityViolation begin
    c = rand(Clue, ZP.EINSTEINS_ZEBRA)
    while !(ZP.check_duplicate(ZP.EINSTEINS_ZEBRA, c; throw_error=false))
        c = rand(Clue, ZP.EINSTEINS_ZEBRA)
    end
    ZP.add_clue!(z, c)
end
