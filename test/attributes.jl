## "attributes" ##

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

## Phase 1 categorical attributes ##

const PHASE1_TYPES = (Job, Hobby, Food, FavouriteColour, Destination)

@testset "phase 1 vocabularies" begin
    for T in PHASE1_TYPES
        value = first(ZP.variants(T))
        attribute = T(value)
        @test ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, T; throw_error=false) == false # not part of Einstein's zebra
        @test !isempty(ZP.attributed(attribute))
        @test all(isa.(ZP.attributed(attribute), String))
        @test !isempty(ZP.attribution(attribute))
        @test !isempty(ZP.negation(attribute))
        @test !isempty(ZP.question(T, "the Spaniard"))
        @test all(isa.(ZP.attribution(attribute), String))
        @test all(isa.(ZP.negation(attribute), String))
        @test all(isa.(ZP.question(T, "the Spaniard"), String))
    end
    # every negation mirrors the attribution relation
    @test length(ZP.attribution(Job("artist"))) == length(ZP.negation(Job("artist")))
    @test length(ZP.attribution(Hobby("reading"))) == length(ZP.negation(Hobby("reading")))
    @test length(ZP.attribution(Food("sushi"))) == length(ZP.negation(Food("sushi")))
    @test length(ZP.attribution(FavouriteColour("lilac"))) ==
          length(ZP.negation(FavouriteColour("lilac")))
    @test length(ZP.attribution(Destination("Italy"))) ==
          length(ZP.negation(Destination("Italy")))
end

@testset "phase 1 phrases render" begin
    @test ZP.phrase(Clue(Job("engineer"), Hobby("gardening"))) isa String
    @test ZP.phrase(Clue(Food("pizza"), Destination("Italy"))) isa String
    @test ZP.phrase(Clue(Nationality("Spaniard"), FavouriteColour("lilac"))) isa String
    @test ZP.phrase(NegativeClue(Job("artist"), Food("sushi"))) isa String
    @test ZP.phrase(AttributeQuestion{Food}(Job("teacher"))) isa String
end

@testset "phase 1 wording contracts" begin
    # the exact template strings pin the relation that each attribute encodes; the negations must
    # mirror the attributions and the questions must ask about the same relation
    @test ZP.attributed(Hobby("reading")) == [
        "the man whose hobby is reading",
        "the person whose hobby is reading",
        "the individual whose hobby is reading",
    ]
    @test ZP.attribution(Hobby("reading")) == ["has reading as their hobby"]
    @test ZP.negation(Hobby("reading")) == ["does not have reading as their hobby"]
    @test ZP.question(Hobby, "the Spaniard") == ["What is the hobby of the Spaniard?"]

    @test ZP.attribution(Destination("Italy")) == ["plans to visit Italy"]
    @test ZP.negation(Destination("Italy")) == ["does not plan to visit Italy"]
    @test ZP.question(Destination, "the Spaniard") == [
        "Where does the Spaniard plan to travel?",
        "Which country does the Spaniard plan to visit?",
    ]

    @test ZP.attribution(Job("artist")) == ["is the artist", "works as the artist"]
    @test ZP.negation(Job("artist")) ==
          ["is not the artist", "does not work as the artist"]
    @test ZP.question(Job, "the Spaniard") == [
        "What is the occupation of the Spaniard?",
        "What does the Spaniard do for a living?",
    ]

    @test ZP.attribution(Food("sushi")) == ["eats sushi", "is an eater of sushi"]
    @test ZP.negation(Food("sushi")) ==
          ["does not eat sushi", "is not an eater of sushi"]
    @test ZP.question(Food, "the Spaniard") == [
        "Which food does the Spaniard eat?",
        "What food does the Spaniard eat?",
        "What does the Spaniard eat?",
    ]

    @test ZP.attribution(FavouriteColour("lilac")) ==
          ["has lilac as their favourite colour"]
    @test ZP.negation(FavouriteColour("lilac")) ==
          ["does not have lilac as their favourite colour"]
    @test ZP.question(FavouriteColour, "the Spaniard") == [
        "What is the favourite colour of the Spaniard?",
        "Which colour does the Spaniard like the most?",
    ]
end

@testset "phase 1 puzzle pipeline" begin
    puzzle = ZebraPuzzle(
        Person => ("Martin", "David", "Lucas"),
        Job => ("engineer", "teacher", "artist"),
        Hobby => ("gardening", "reading", "cooking"),
        Food => ("pizza", "sushi", "pasta"),
    )
    add_clues!(
        puzzle,
        [
            Clue(Job("engineer"), Hobby("gardening")),
            Clue(Job("teacher"), Food("sushi")),
            Clue(Job("artist"), Hobby("cooking")),
            Clue(Hobby("cooking"), Food("pasta")),
            Clue(Person("Martin"), Job("engineer")),
            Clue(Person("David"), Food("sushi")),
            AbsolutePosition(Person("Martin"), 1, 3),
            AbsolutePosition(Person("David"), 2, 3),
        ],
    )
    add_question!(puzzle, AttributeQuestion{Food}(Job("teacher")))
    solve!(puzzle)
    @test ZP.answer(only(puzzle.questions), puzzle) == Food("sushi")
    @test ZP.has_unique_solution(puzzle)
    @test riddle(puzzle; quiet=true) isa String

    puzzle2 = ZebraPuzzle(
        Person => ("Martin", "David"),
        FavouriteColour => ("lilac", "purple"),
        Destination => ("Italy", "Egypt"),
    )
    add_clues!(
        puzzle2,
        [
            Clue(Person("Martin"), FavouriteColour("lilac")),
            Clue(FavouriteColour("purple"), Destination("Egypt")),
            AbsolutePosition(Person("Martin"), 1, 2),
        ],
    )
    add_question!(puzzle2, PositionQuestion(Person("David")))
    solve!(puzzle2)
    @test ZP.answer(only(puzzle2.questions), puzzle2) == 2
    @test ZP.has_unique_solution(puzzle2)
    @test riddle(puzzle2; quiet=true) isa String
end

## Phase 2 orderable categories (categorical-only) ##

const PHASE2_TYPES = (Age, Month)

@testset "phase 2 vocabularies" begin
    for T in PHASE2_TYPES
        attribute = T(first(ZP.variants(T)))
        @test ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, T; throw_error=false) == false
        @test !isempty(ZP.attributed(attribute))
        @test !isempty(ZP.attribution(attribute))
        @test !isempty(ZP.negation(attribute))
        @test !isempty(ZP.question(T, "the Spaniard"))
        @test all(isa.(ZP.attributed(attribute), String))
        @test all(isa.(ZP.question(T, "the Spaniard"), String))
    end
    @test length(ZP.attribution(Age("40"))) == length(ZP.negation(Age("40")))
    @test length(ZP.attribution(Month("June"))) == length(ZP.negation(Month("June")))
    @test length(ZP.variants(Month)) == 12
    @test length(unique(ZP.variants(Month))) == 12 # twelve distinct month names
end

@testset "phase 2 wording contracts" begin
    @test ZP.attributed(Age("40")) == [
        "the 40-year-old person",
        "the man who is 40 years old",
        "the person who is 40 years old",
        "the individual who is 40 years old",
    ]
    @test ZP.attribution(Age("40")) == ["is 40 years old"]
    @test ZP.negation(Age("40")) == ["is not 40 years old"]
    @test ZP.question(Age, "the Spaniard") == ["How old is the Spaniard?"]

    @test ZP.attributed(Month("June")) == [
        "the man born in June",
        "the person born in June",
        "the individual born in June",
    ]
    @test ZP.attribution(Month("June")) == ["was born in June"]
    @test ZP.negation(Month("June")) == ["was not born in June"]
    @test ZP.question(Month, "the Spaniard") == [
        "In which month was the Spaniard born?",
        "When was the Spaniard born?",
    ]
end

@testset "phase 2 phrases render" begin
    @test ZP.phrase(Clue(Age("40"), Month("June"))) isa String
    @test ZP.phrase(NegativeClue(Month("January"), Age("25"))) isa String
    @test ZP.phrase(AttributeQuestion{Age}(Month("June"))) isa String
    @test ZP.phrase(PositionQuestion(Age("30"))) isa String
end

@testset "phase 2 puzzle pipeline" begin
    puzzle = ZebraPuzzle(
        Person => ("Martin", "David", "Lucas"),
        Age => ("30", "40", "50"),
        Month => ("January", "June", "October"),
    )
    add_clues!(
        puzzle,
        [
            Clue(Person("Martin"), Age("40")),
            Clue(Person("David"), Month("June")),
            Clue(Age("30"), Month("January")),
            AbsolutePosition(Person("Martin"), 1, 3),
            AbsolutePosition(Person("David"), 2, 3),
        ],
    )
    add_question!(puzzle, AttributeQuestion{Age}(Month("June")))
    add_question!(puzzle, PositionQuestion(Age("30")))
    solve!(puzzle)
    @test ZP.answer(puzzle.questions[1], puzzle) == Age("50")
    @test ZP.answer(puzzle.questions[2], puzzle) == 3
    @test ZP.has_unique_solution(puzzle)
    @test riddle(puzzle; quiet=true) isa String
end

## Phase 3 subject dispatch + Car ##

using Random

@testset "phase 3 subject dispatch" begin
    @test ZP.is_location(House) && ZP.is_location(Car)
    @test !ZP.is_location(Person)
    @test !ZP.is_location(Drink)
    @test ZP.position_verb(House) == "is"
    @test ZP.position_verb(Car) == "is"
    @test ZP.position_verb(Person) == "lives"
    @test ZP.position_verb(Drink) == "lives"
    @test ZP.position_noun(House) == "position"
    @test ZP.position_noun(Car) == "parking spot"
    @test ZP.position_noun(Person) == "house"
    @test ZP.position_noun(Drink) == "house"
end

@testset "phase 3 car vocabulary" begin
    @test ZP.attributed(Car("red")) == ["the red car"]
    @test ZP.attribution(Car("red")) == ["owns the red car"]
    @test ZP.negation(Car("red")) == ["does not own the red car"]
    @test ZP.question(Car, "the Spaniard") ==
          ["Which car does the Spaniard own?", "What car does the Spaniard own?"]
    @test length(ZP.variants(Car)) == 8
end

@testset "phase 3 phrases render" begin
    # the swap normalizes location-like attributes into the predicate position regardless of the
    # clue argument order; both single-form vocabularies make these phrases deterministic
    @test ZP.phrase(Clue(Car("red"), Person("Martin"))) == "Martin owns the red car."
    @test ZP.phrase(Clue(Person("Martin"), Car("red"))) == "Martin owns the red car."
    @test ZP.phrase(NegativeClue(Car("red"), Person("Martin"))) ==
          "Martin does not own the red car."
    @test ZP.phrase(PositionQuestion(Car("red"))) in
          ("At which position is the red car?", "What is the position of the red car?")
    @test ZP.phrase(PositionQuestion(House("red"))) in
          ("At which position is the red house?", "What is the position of the red house?")
    @test ZP.phrase(PositionQuestion(Person("Martin"))) in
          ("At which position does Martin live?", "What is the position of Martin?")
    @test ZP.phrase(ExactRelativePosition(Car("red"), Person("Martin"), 1)) isa String
    @test ZP.phrase(AbsolutePosition(Car("blue"), 2, 3)) ==
          "The blue car is in the middle parking spot."
    @test ZP.phrase(AbsoluteDistance(Car("red"), Person("Martin"), 1)) isa String
    @test ZP.phrase(DirectionClue(Car("red"), Person("Martin"), ZP.d_right)) isa String
end

@testset "phase 3 question generator" begin
    # deterministic: subject-like requested types are never paired with subject-like subjects, and
    # person-centric types (see `person_centric`) are never asked about location-like subjects
    mixed = ZebraPuzzle(
        House => ("red", "blue"),
        Car => ("red", "blue"),
        Drink => ("tea", "coffee"),
        Job => ("engineer", "teacher"),
    )
    Random.seed!(7)
    for _ in 1:20
        @test rand(ZP.AttributeQuestion{House}, mixed).subject isa Union{Drink, Job}
        @test rand(ZP.AttributeQuestion{Car}, mixed).subject isa Union{Drink, Job}
        @test rand(ZP.AttributeQuestion{Job}, mixed).subject isa Drink
        @test rand(ZP.AttributeQuestion{Drink}, mixed) isa AttributeQuestion{Drink}
    end
    # regression: person-centric questions are never asked about location-like subjects; the
    # generator selects a valid (requested type, subject type) pair instead of falling back to an
    # incoherent one, and `Person` subjects stay valid for person-centric questions
    categorical = ZebraPuzzle(House => ("red", "blue"), Age => ("30", "40"))
    @test_throws ArgumentError rand(ZP.AttributeQuestion{Age}, categorical)
    for _ in 1:20
        question = rand(Question, categorical)
        @test question isa PositionQuestion || (
            question isa AttributeQuestion &&
            ZP.qattrtype(question) === House &&
            question.subject isa Age
        ) # the house colour of the 30-year-old is sensible, the age of a house is not
    end
    with_person = ZebraPuzzle(Person => ("Martin", "David"), Age => ("30", "40"))
    for _ in 1:20
        @test rand(ZP.AttributeQuestion{Age}, with_person).subject isa Person
        @test rand(Question, with_person) isa Question
    end
    # regression: `Destination` is person-centric, so houses are never asked about travel plans
    travel = ZebraPuzzle(
        House => ("red", "blue"),
        Job => ("engineer", "teacher"),
        Destination => ("Italy", "Egypt"),
    )
    for _ in 1:20
        @test rand(ZP.AttributeQuestion{Destination}, travel).subject isa Job
        @test rand(ZP.AttributeQuestion{Job}, travel).subject isa Destination
        @test rand(ZP.AttributeQuestion{House}, travel).subject isa Union{Job, Destination}
    end
    # the all-subject fallback keeps the old behaviour instead of erroring
    two = ZebraPuzzle(House => ("red", "blue"), Person => ("Martin", "David"))
    @test_throws ArgumentError rand(ZP.AttributeQuestion{House}, two)
    for _ in 1:20
        @test rand(Question, two) isa PositionQuestion
    end
end

@testset "phase 3 car subject pipeline" begin
    puzzle = ZebraPuzzle(
        Car => ("red", "blue", "green"),
        Person => ("Martin", "David", "Lucas"),
        Job => ("engineer", "teacher", "artist"),
    )
    add_clues!(
        puzzle,
        [
            Clue(Person("Martin"), Car("red")),
            Clue(Person("David"), Job("teacher")),
            Clue(Person("Lucas"), Job("engineer")),
            AbsolutePosition(Car("green"), 3, 3),
            AbsolutePosition(Person("David"), 2, 3),
        ],
    )
    add_question!(puzzle, PositionQuestion(Car("red")))
    solve!(puzzle)
    @test ZP.answer(only(puzzle.questions), puzzle) == 1
    @test ZP.has_unique_solution(puzzle)
    riddle_text = riddle(puzzle; quiet=true)
    @test occursin("There are 3 cars.", riddle_text)
    # non-Car attributes take the story-neutral positional wording of the car story
    @test ZP.phrase(AbsolutePosition(Person("David"), 2, 3), Car) ==
          "David is in the middle parking spot."
    @test occursin("David is in the middle parking spot.", riddle_text)
    @test occursin("The green car is in the last parking spot.", riddle_text)
end
