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
