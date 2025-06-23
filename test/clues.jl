using ZebraPuzzles: ZebraPuzzles as ZP
using ZebraPuzzles.Satisfiability

directclue_clues = [
    Clue(Smoke("Old Gold"), Not(Drink("coffee"))),
    Clue(House("ivory"), Not(Drink("milk"))),
    Clue(Nationality("Spaniard"), Drink("orange juice")),
    Clue(Nationality("Englishman"), House("red")),
    Clue(House("red"), Smoke("Old Gold")),
    Clue(Smoke("Kools"), Drink("water")),
    Clue(Nationality("Englishman"), Pet("snails")),
    Clue(Smoke("Chesterfields"), House("blue")),
    Clue(Nationality("Norwegian"), Not(House("red"))),
    Clue(Smoke("Lucky Strike"), Not(House("red")))
]

absoluteposition_clues = [
    AbsolutePosition(Smoke("Old Gold"), 3),
    AbsolutePosition(Pet("fox"), 1),
    AbsolutePosition(Nationality("Japanese"), 5),
    AbsolutePosition(Nationality("Spaniard"), 4),
    AbsolutePosition(Drink("orange juice"), 4),
    AbsolutePosition(Nationality("Ukrainian"), 2),
    AbsolutePosition(Smoke("Lucky Strike"), 4),
    AbsolutePosition(Nationality("Norwegian"), 1),
    AbsolutePosition(House("green"), 5),
    AbsolutePosition(Pet("horse"), 2)
]

absolutedistance_clues = [
    AbsoluteDistance(Drink("tea"), Nationality("Japanese"), 3),
    AbsoluteDistance(Pet("dog"), Drink("tea"), 2),
    AbsoluteDistance(Nationality("Norwegian"), House("green"), 4),
    AbsoluteDistance(Pet("horse"), Drink("coffee"), 3),
    AbsoluteDistance(Drink("orange juice"), House("blue"), 2),
    AbsoluteDistance(Drink("water"), Drink("tea"), 1),
    AbsoluteDistance(Pet("snails"), Pet("zebra"), 2),
    AbsoluteDistance(Pet("dog"), Smoke("Kools"), 3),
    AbsoluteDistance(Drink("milk"), Nationality("Japanese"), 2),
    AbsoluteDistance(House("ivory"), Smoke("Parliaments"), 1)
]

directionclue_clues = [
    DirectionClue(Nationality("Englishman"), Pet("fox"), ZebraPuzzles.d_right),
    DirectionClue(Smoke("Kools"), Smoke("Chesterfields"), ZebraPuzzles.d_left),
    DirectionClue(House("ivory"), Pet("snails"), ZebraPuzzles.d_right),
    DirectionClue(Nationality("Ukrainian"), Pet("snails"), ZebraPuzzles.d_left),
    DirectionClue(Nationality("Spaniard"), Drink("water"), ZebraPuzzles.d_right),
    DirectionClue(Smoke("Kools"), Drink("coffee"), ZebraPuzzles.d_left),
    DirectionClue(Nationality("Norwegian"), Smoke("Lucky Strike"), ZebraPuzzles.d_left),
    DirectionClue(Pet("zebra"), Drink("tea"), ZebraPuzzles.d_right),
    DirectionClue(Drink("coffee"), Pet("horse"), ZebraPuzzles.d_right),
    DirectionClue(Drink("tea"), Nationality("Japanese"), ZebraPuzzles.d_left)
]

exactrelativeposition_clues = [
    ExactRelativePosition(Smoke("Chesterfields"), Nationality("Englishman"), -1),
    ExactRelativePosition(Nationality("Ukrainian"), Smoke("Parliaments"), -3),
    ExactRelativePosition(Nationality("Japanese"), Nationality("Norwegian"), 4),
    ExactRelativePosition(Drink("tea"), Pet("dog"), -2),
    ExactRelativePosition(Drink("milk"), Smoke("Lucky Strike"), -1),
    ExactRelativePosition(House("green"), House("red"), 2),
    ExactRelativePosition(Pet("horse"), Pet("snails"), -1),
    ExactRelativePosition(Drink("tea"), Drink("orange juice"), -2),
    ExactRelativePosition(Nationality("Ukrainian"), Drink("milk"), -1),
    ExactRelativePosition(Pet("fox"), Smoke("Lucky Strike"), -3)
]

@testset "check" begin
    @testset "errors" begin
        @test_throws ZP.AttributeTypeError ZP.check(ZP.EINSTEINS_ZEBRA, Clue(Hat("pink"), Smoke("Chesterfields")))
        @test_throws ZP.AttributeVariantError ZP.check(ZP.EINSTEINS_ZEBRA, Clue(House("pink"), Smoke("Chesterfields")))
        @test_throws ["is not satisfied in the puzzle"] ZP.check(ZP.EINSTEINS_ZEBRA, Clue(House("blue"), Not(Nationality("Ukrainian"))))
        @test_throws ["is not satisfied in the puzzle"] ZP.check(ZP.EINSTEINS_ZEBRA, Clue(House("blue"), Nationality("Englishman")))
    end

    for i in [directclue_clues, absoluteposition_clues, absolutedistance_clues, directionclue_clues, exactrelativeposition_clues]
        @testset "check $(nameof(eltype(i)))" begin
            @test all(ZP.check(ZP.EINSTEINS_ZEBRA, c; implied=false, minimal=false, duplicates=false) for c in i)
            @test all(i) do c
                try
                    ZP.check_implied(ZP.EINSTEINS_ZEBRA, c)
                    return false
                catch
                    return true
                end
            end
            @test all(i) do c
                try
                    ZP.check_minimal(ZP.EINSTEINS_ZEBRA, c)
                    return false
                catch
                    return true
                end
            end
        end
    end
end

@testset "construction" begin
    @test_throws ["must be different"] Clue(House("A"), House("A"))
    @test_throws ["must have a different type"] Clue(House("A"), House("B"))
    @test Clue(House("1"), Hat("A")) isa PositiveClue
    @test Clue(House("1"), Not(Hat("A"))) isa NegativeClue
end

@testset "rand" begin
    @test rand(Clue, ZP.EINSTEINS_ZEBRA) isa Clue
    @test rand(PositiveClue, ZP.EINSTEINS_ZEBRA) isa PositiveClue
    @test rand(NegativeClue, ZP.EINSTEINS_ZEBRA) isa NegativeClue
    @test rand(ExactRelativePosition, ZP.EINSTEINS_ZEBRA) isa ExactRelativePosition
    @test rand(DirectionClue, ZP.EINSTEINS_ZEBRA) isa DirectionClue
    @test rand(AbsolutePosition, ZP.EINSTEINS_ZEBRA) isa AbsolutePosition
    @test rand(AbsoluteDistance, ZP.EINSTEINS_ZEBRA) isa AbsoluteDistance
end

@testset "expr" begin
    struct NewClue <: ZP.Clue end
    @test_throws ["`NewClue` does not implement the obligatory interface"] ZP.expr(NewClue(), ZP.AttributeExprs(ZP.EINSTEINS_ZEBRA))
    exprs = ZP.AttributeExprs(ZP.EINSTEINS_ZEBRA)
    @test and(ZP.expr(c, exprs) for c in ZP.EINSTEINS_ZEBRA.clues) isa BoolExpr
end
