using ZebraPuzzles: ZebraPuzzles as ZP

@test ZebraPuzzle(
    (Person("1"), Hat("A"), Smoke("I")),
    (Person("2"), Hat("B"), Smoke("II"))
) isa ZP.SolvedZebraPuzzle

@test ZebraPuzzle(
    Person => ("Martin", "David", "Lucas"),
    House => ("red", "blue", "yellow"),
    Pet => ("Weasel", "Cow", "Mammoth")
) isa ZP.UnsolvedZebraPuzzle

@test ZebraPuzzle(ZP.EINSTEINS_ZEBRA.table, ZP.EINSTEINS_ZEBRA.clues) isa ZP.SolvedZebraPuzzle
