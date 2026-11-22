## "random" ##

using ZebraPuzzles: ZebraPuzzles as ZP
using Random, Logging

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

@testset "puzzle generation dimensions" begin
    # regression: rectangular generation used to swap the documented subject and attribute counts
    @testset "rectangular generation" begin
        for (K, N) in ((2, 3), (3, 2), (4, 3))
            puzzle = rand(UnsolvedZebraPuzzle{K,N}; clues=false, question=false)
            @test puzzle isa UnsolvedZebraPuzzle{K,N}
            @test length(ZP.attrtypes(puzzle)) == N # `N` attributes per subject
            @test all(length(attributes(puzzle, A)) == K for A in ZP.attrtypes(puzzle)) # `K` subjects
        end
    end

    # regression: the positional overload used to drop the `question` keyword argument
    @testset "positional overload keywords" begin
        with_logger(Logging.NullLogger()) do
            puzzle = rand(UnsolvedZebraPuzzle, 2, 3; clues=false, question=false)
            @test puzzle isa UnsolvedZebraPuzzle{2,3}
            @test isempty(puzzle.questions)

            puzzle = rand(UnsolvedZebraPuzzle, 2, 3; clues=false, question=true)
            @test length(puzzle.questions) == 1
        end
    end
end

@testset "fill_clues!" begin
    Random.seed!(20260101)
    with_logger(Logging.NullLogger()) do
        # unexpected errors surface instead of being retried away: a clue with an attribute type
        # that the puzzle does not have breaks the solver assertions with a `KeyError`
        foreign = ZebraPuzzle(Drink => ("coffee", "tea"), House => ("green", "red"))
        push!(foreign.clues, Clue(Hat("fedora"), House("green")))
        @test_throws KeyError fill_clues!(foreign)

        # the successful termination behavior is unchanged
        puzzle = ZebraPuzzle(Drink => ("coffee", "tea"), House => ("green", "red"))
        @test fill_clues!(puzzle) === puzzle
        @test ZP.has_unique_solution(puzzle)
    end
end
