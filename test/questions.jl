## "questions" ##

@test rand(ZP.AttributeQuestion, ZP.EINSTEINS_ZEBRA) isa ZP.AttributeQuestion
@test rand(ZP.AttributeQuestion{House}, ZP.EINSTEINS_ZEBRA) isa ZP.AttributeQuestion{House}
@test rand(ZP.AttributeQuestion{House,Drink}, ZP.EINSTEINS_ZEBRA) isa ZP.AttributeQuestion{House,Drink}

@test all(q -> allunique(typeof(q).parameters), [rand(AttributeQuestion, ZP.EINSTEINS_ZEBRA) for _ in Base.OneTo(100)])

@test rand(ZP.PositionQuestion{House}, ZP.EINSTEINS_ZEBRA) isa ZP.PositionQuestion{House}
@test rand(ZP.PositionQuestion, ZP.EINSTEINS_ZEBRA) isa ZP.PositionQuestion

@testset "check" begin
    @test_throws ZP.AttributeTypeError ZP.check(ZP.EINSTEINS_ZEBRA, AttributeQuestion{House}(Hat("sobrero")))
    @test_throws ZP.AttributeTypeError ZP.check(ZP.EINSTEINS_ZEBRA, AttributeQuestion{Hat}(House("pink")))
    @test_throws ZP.AttributeTypeError ZP.check(ZP.EINSTEINS_ZEBRA, PositionQuestion(Hat("sombrero")))

    @test_throws ZP.AttributeVariantError ZP.check(ZP.EINSTEINS_ZEBRA, AttributeQuestion{Smoke}(House("pink")))
end

@test rand(Question, ZP.EINSTEINS_ZEBRA) isa Question

@test ZP.answer(ZP.AttributeQuestion{Smoke}(House("red")), ZP.EINSTEINS_ZEBRA) isa ZP.Attribute
@test_throws ZP.UnsolvedPuzzle ZP.answer(ZP.AttributeQuestion{Smoke}(House("red")), ZP.UNSOLVED_EINSTEINS_ZEBRA)

@test ZP.answer(ZP.PositionQuestion(Smoke("Kools")), ZP.EINSTEINS_ZEBRA) isa Number
@test_throws ZP.UnsolvedPuzzle ZP.answer(ZP.PositionQuestion(Smoke("Kools")), ZP.UNSOLVED_EINSTEINS_ZEBRA)

puz = ZP.UNSOLVED_EINSTEINS_ZEBRA |> deepcopy
solve!(puz)

@test ZP.answer(ZP.PositionQuestion(Smoke("Kools")), puz) == 1
@test ZP.answer(ZP.AttributeQuestion{Smoke}(House("red")), puz) == Smoke("Old Gold")

@test all(ZP.answer(q, ZP.EINSTEINS_ZEBRA) == ZP.answer(q, puz) for q in (rand(Question, ZP.EINSTEINS_ZEBRA) for i in Base.OneTo(100)))
