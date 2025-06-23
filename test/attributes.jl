using ZebraPuzzles: ZebraPuzzles as ZP

@test ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, House("yellow"))
@test ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, House("pink")) # does not throw even if House("pink") is not in the puzzle
@test_throws ZP.AttributeVariantError ZP.check_attrvariant(ZP.EINSTEINS_ZEBRA, House("pink"))
@test_throws ZP.AttributeVariantError attributes(ZP.EINSTEINS_ZEBRA, House("pink")) # unlike the previous test throws 
@test_throws ZP.AttributeTypeError ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, Hat)
@test_throws ZP.AttributeTypeError attributes(ZP.EINSTEINS_ZEBRA, Hat)

@test length(attributes(ZP.EINSTEINS_ZEBRA, Not(Pet("fox")))) == 20
@test length(attributes(ZP.EINSTEINS_ZEBRA, Pet("fox"))) == 4

@test length(attributes(ZP.EINSTEINS_ZEBRA, Not(Pet))) == 20
@test length(attributes(ZP.UNSOLVED_EINSTEINS_ZEBRA, Not(Pet))) == 20
@test length(attributes(ZP.UNSOLVED_EINSTEINS_ZEBRA, Pet)) == 5
@test length(attributes(ZP.EINSTEINS_ZEBRA, Pet)) == 5

@test attributes(Clue(House("yellow"), Drink("water"))) == (House("yellow"), Drink("water"))
