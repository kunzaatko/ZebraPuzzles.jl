## "export" ##

using ZebraPuzzles
using ZebraPuzzles: ZebraPuzzles as ZP
using Test, Random, Logging, DataFrames
import JSON

# A question type that the exporter does not support.
struct BogusQuestion <: Question end

# The known solution of Einstein's zebra in the declared column order
# `["Drink", "House", "Nationality", "Pet", "Smoke"]`, rows in position order.
const EINSTEIN_TABLE = [
    ["water", "yellow", "Norwegian", "fox", "Kools"],
    ["tea", "blue", "Ukrainian", "horse", "Chesterfields"],
    ["milk", "red", "Englishman", "snails", "Old Gold"],
    ["orange juice", "ivory", "Spaniard", "dog", "Lucky Strike"],
    ["coffee", "green", "Japanese", "zebra", "Parliaments"],
]
const DECLARED_COLUMNS = ["Drink", "House", "Nationality", "Pet", "Smoke"]

column_index(columns, name) = findfirst(==(name), columns)

@testset "puzzle_record" begin
    @testset "attribute question" begin
        puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
        add_question!(puzzle, AttributeQuestion{Smoke}(Nationality("Englishman")))
        record = puzzle_record(puzzle)

        @test record["schema_version"] === 1
        @test record["dimensions"] ==
              Dict("subjects" => 5, "attribute_types" => 5, "clue_count" => 14)
        @test record["question"] == Dict(
            "kind" => "attribute",
            "subject" => Dict("attribute_type" => "Nationality", "value" => "Englishman"),
            "attribute_type" => "Smoke",
        )
        @test record["answer"] == Dict(
            "kind" => "attribute", "attribute_type" => "Smoke", "value" => "Old Gold"
        )

        # the exported truth table
        @test record["solution"]["columns"] == DECLARED_COLUMNS
        rows = record["solution"]["rows"]
        @test length(rows) == 5
        @test all(length.(rows) .== 5)
        @test all(isa.(reduce(vcat, rows), String))
        @test first(rows) == first(EINSTEIN_TABLE) # the first row is position 1
        @test rows[4] == EINSTEIN_TABLE[4]

        # the answer agrees with the exported truth table
        subject_row = findfirst(
            row -> row[column_index(DECLARED_COLUMNS, "Nationality")] == "Englishman", rows
        )
        @test rows[subject_row][column_index(DECLARED_COLUMNS, "Smoke")] ==
              record["answer"]["value"]

        # the riddle is the rendered text with the introduction, the clues and the one question
        riddle_text = record["riddle"]
        @test riddle_text isa String
        @test occursin("There are 5 houses.", riddle_text)
        @test occursin('?', riddle_text)
        @test count('\n', riddle_text) >= 14
        @test !occursin("┌", riddle_text) # no pretty-printed table
        @test !occursin("UnsolvedZebraPuzzle", riddle_text) # no Julia type display
    end

    @testset "position question" begin
        puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
        add_question!(puzzle, PositionQuestion(House("ivory")))
        record = puzzle_record(puzzle)

        @test record["question"] == Dict(
            "kind" => "position",
            "subject" => Dict("attribute_type" => "House", "value" => "ivory"),
        )
        @test !haskey(record["question"], "attribute_type")
        @test record["answer"] == Dict("kind" => "position", "value" => 4)
        @test record["answer"]["value"] isa Int # one-based JSON integer, not a string

        # the answer agrees with the exported truth table
        rows = record["solution"]["rows"]
        house_index = column_index(DECLARED_COLUMNS, "House")
        @test rows[record["answer"]["value"]][house_index] == "ivory"
        @test count(row -> row[house_index] == "ivory", rows) == 1

        # same exported truth table as the attribute question of the same puzzle
        attr_puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
        add_question!(attr_puzzle, AttributeQuestion{Smoke}(Nationality("Englishman")))
        @test puzzle_record(attr_puzzle)["solution"] == record["solution"]
        @test puzzle_record(attr_puzzle)["dimensions"] == record["dimensions"]
    end

    @testset "rectangular dimensions" begin
        puzzle = ZebraPuzzle(
            Drink => ("tea", "coffee", "milk"),
            House => ("red", "green", "blue"),
        )
        add_clues!(
            puzzle,
            [
                AbsolutePosition(Drink("milk"), 2, 3),
                Clue(House("red"), Drink("tea")),
                AbsolutePosition(House("red"), 3, 3),
                ExactRelativePosition(House("green"), House("blue"), 1),
            ],
        )
        add_question!(puzzle, PositionQuestion(Drink("coffee")))
        record = puzzle_record(puzzle)

        @test record["dimensions"] ==
              Dict("subjects" => 3, "attribute_types" => 2, "clue_count" => 4)
        @test record["solution"]["columns"] == ["Drink", "House"]
        @test record["solution"]["rows"] ==
              [["coffee", "blue"], ["milk", "green"], ["tea", "red"]]
        @test record["answer"] == Dict("kind" => "position", "value" => 1)
    end

    @testset "question validation" begin
        @testset "solved puzzle input" begin
            # v1 only accepts `UnsolvedZebraPuzzle`s
            @test_throws MethodError puzzle_record(ZP.EINSTEINS_ZEBRA)
        end

        @testset "zero questions" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            @test_throws r"exactly one question" puzzle_record(puzzle)
        end

        @testset "multiple questions" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            add_question!(puzzle, PositionQuestion(Pet("zebra")))
            add_question!(puzzle, PositionQuestion(Drink("tea")))
            @test_throws r"exactly one question" puzzle_record(puzzle)
        end

        @testset "invalid question type" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            push!(puzzle.questions, AttributeQuestion{Hat}(House("red"))) # `Hat` is not in the puzzle
            @test_throws ZP.AttributeTypeError puzzle_record(puzzle)
        end

        @testset "invalid question variant" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            push!(puzzle.questions, AttributeQuestion{Smoke}(Nationality("Martian")))
            @test_throws ZP.AttributeVariantError puzzle_record(puzzle)
        end

        @testset "unsupported question" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            push!(puzzle.questions, BogusQuestion())
            @test_throws r"only `AttributeQuestion`s about attributes and `PositionQuestion`s" puzzle_record(puzzle)
        end

        @testset "unsupported question subject" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            push!(puzzle.questions, ZP.AttributeQuestion{Smoke,Int}(2))
            @test_throws r"only `AttributeQuestion`s about attributes and `PositionQuestion`s" puzzle_record(puzzle)
        end
    end

    @testset "solution validation" begin
        @testset "unsatisfiable clues" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            add_question!(puzzle, PositionQuestion(Pet("zebra")))
            push!(puzzle.clues, Clue(Drink("tea"), House("red"))) # tea is in the blue house
            @test_throws r"unsatisfiable" puzzle_record(puzzle)
        end

        @testset "non-unique solution" begin
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            add_question!(puzzle, PositionQuestion(Pet("zebra")))
            empty!(puzzle.clues)
            add_clue!(puzzle, Clue(Nationality("Englishman"), House("red")); ischecked=true)
            @test_throws r"unique solution" puzzle_record(puzzle)
        end

        @testset "stale stored table after clue edits" begin
            # a complete stored table must not be trusted when the clues no longer pin it down
            nonunique = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            add_question!(nonunique, PositionQuestion(Pet("zebra")))
            solve!(nonunique)
            @test ZP.issolved(nonunique)
            empty!(nonunique.clues)
            @test_throws r"unique solution" puzzle_record(nonunique)

            # ...nor when the edited clues are unsatisfiable
            unsatisfiable = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            add_question!(unsatisfiable, PositionQuestion(Pet("zebra")))
            solve!(unsatisfiable)
            push!(unsatisfiable.clues, Clue(Drink("tea"), House("red")))
            @test_throws r"unsatisfiable" puzzle_record(unsatisfiable)
        end

        @testset "previously filled table" begin
            # a still-valid filled table is simply re-derived
            puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
            add_question!(puzzle, AttributeQuestion{Pet}(Nationality("Japanese")))
            solve!(puzzle)
            record = puzzle_record(puzzle)
            rows = record["solution"]["rows"]
            japanese_row = findfirst(
                row ->
                    row[column_index(DECLARED_COLUMNS, "Nationality")] == "Japanese",
                rows,
            )
            @test rows[japanese_row][column_index(DECLARED_COLUMNS, "Pet")] ==
                  record["answer"]["value"] == "zebra"
        end
    end

    @testset "input integrity" begin
        puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
        add_question!(puzzle, PositionQuestion(Pet("zebra")))
        before = deepcopy(puzzle)

        @test !ZP.issolved(puzzle)
        @test_logs puzzle_record(puzzle) # no logging, in particular no `solve!` warnings
        @test puzzle == before # not mutated
        @test !ZP.issolved(puzzle) # the stored table stays empty

        # no printing
        old_stdout = stdout
        read_end, write_end = redirect_stdout()
        try
            puzzle_record(puzzle)
        finally
            redirect_stdout(old_stdout)
            close(write_end)
        end
        @test isempty(read(read_end, String))
    end

    @testset "record independence from later input mutation" begin
        puzzle = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
        add_question!(puzzle, PositionQuestion(Pet("zebra")))
        record = puzzle_record(puzzle)
        frozen = deepcopy(record)

        empty!(puzzle.clues)
        puzzle.table[1, 1] = Drink("dishwater")
        push!(puzzle.questions, PositionQuestion(Drink("tea")))

        @test record == frozen # the record is detached from the input
        @test record["solution"]["rows"][1][1] == "water"
        @test record["dimensions"]["clue_count"] == 14
    end

    @testset "unicode fixture" begin
        puzzle = ZebraPuzzle(
            Drink => ("káva", "čaj"),
            Person => ("Zoë", "Ångström"),
            House => ("červený", "modrý"),
        )
        add_clues!(
            puzzle,
            [
                Clue(Person("Zoë"), Drink("čaj")),
                Clue(House("červený"), Person("Zoë")),
                AbsolutePosition(Person("Zoë"), 1, 2),
            ],
        )
        add_question!(puzzle, AttributeQuestion{House}(Person("Zoë")))
        record = puzzle_record(puzzle)

        @test record["solution"]["columns"] == ["Drink", "Person", "House"]
        @test record["solution"]["rows"] ==
              [["čaj", "Zoë", "červený"], ["káva", "Ångström", "modrý"]]
        @test record["answer"] ==
              Dict("kind" => "attribute", "attribute_type" => "House", "value" => "červený")
        @test occursin("Zoë", record["riddle"])

        # JSON round-trip with a standard parser preserves Unicode and the multiline riddle
        encoded = JSON.json(record)
        parsed = JSON.parse(encoded)
        @test parsed == record
        @test occursin("Zoë", parsed["riddle"])
        @test occursin("červený", parsed["riddle"])
        @test occursin('\n', parsed["riddle"])
        @test count('\n', parsed["riddle"]) == count('\n', record["riddle"])
        @test parsed["solution"]["rows"] == record["solution"]["rows"]
        @test parsed["answer"]["value"] == "červený"
    end

    @testset "generated puzzle" begin
        Random.seed!(20260101)
        local generated
        with_logger(Logging.NullLogger()) do
            generated = rand(ZP.UnsolvedZebraPuzzle{2,3}; clues=true, question=true)
        end
        @test generated isa ZP.UnsolvedZebraPuzzle{2,3}
        record = puzzle_record(generated)
        @test record["dimensions"]["subjects"] == 2
        @test record["dimensions"]["attribute_types"] == 3
        @test record["dimensions"]["clue_count"] == length(generated.clues)

        # the exported answer is consistent with the exported truth table
        question = only(generated.questions)
        rows = record["solution"]["rows"]
        columns = record["solution"]["columns"]
        subject_column = column_index(columns, string(nameof(typeof(question.subject))))
        if question isa PositionQuestion
            @test record["answer"]["kind"] == "position"
            @test rows[record["answer"]["value"]][subject_column] == string(question.subject)
        else
            @test record["answer"]["kind"] == "attribute"
            subject_row = findfirst(row -> row[subject_column] == string(question.subject), rows)
            answer_column = column_index(columns, string(nameof(ZP.qattrtype(question))))
            @test rows[subject_row][answer_column] == record["answer"]["value"]
            @test record["answer"]["attribute_type"] == string(nameof(ZP.qattrtype(question)))
        end
    end
end
