const PUZZLE_RECORD_SCHEMA_VERSION = 1

"""
    attribute_record(a::Attribute)::Dict{String,Any}
JSON-compatible representation of the [`Attribute`](@ref) `a`: its type name and raw string value.
"""
attribute_record(a::Attribute) =
    Dict{String,Any}("attribute_type" => string(nameof(typeof(a))), "value" => string(a))

"""
    question_record(q::AttributeQuestion)::Dict{String,Any}
    question_record(q::PositionQuestion)::Dict{String,Any}
JSON-compatible representation of the question `q`: its `kind`, its `subject` (see
[`attribute_record`](@ref)) and, for [`AttributeQuestion`](@ref)s only, the `attribute_type` of the
requested category.
"""
question_record(q::AttributeQuestion) = Dict{String,Any}(
    "kind" => "attribute",
    "subject" => attribute_record(q.subject),
    "attribute_type" => string(nameof(qattrtype(q))),
)
question_record(q::PositionQuestion) = Dict{String,Any}(
    "kind" => "position",
    "subject" => attribute_record(q.subject),
)

"""
    answer_record(q::Question, solved::UnsolvedZebraPuzzle)::Dict{String,Any}
JSON-compatible representation of the answer to the question `q` in the solved puzzle `solved`.

The answer of a [`PositionQuestion`](@ref) is the one-based position as a JSON-compatible integer,
the answer of an [`AttributeQuestion`](@ref) is the linked attribute (see
[`attribute_record`](@ref)).
"""
function answer_record(q::Question, solved::UnsolvedZebraPuzzle)
    a = answer(q, solved)
    if q isa PositionQuestion
        return Dict{String,Any}("kind" => "position", "value" => a)
    else
        return Dict{String,Any}(
            "kind" => "attribute",
            "attribute_type" => string(nameof(typeof(a))),
            "value" => string(a),
        )
    end
end

"""
    unique_solution_assignment(puzzle::UnsolvedZebraPuzzle)::Matrix{Int}

Solve the rule and clue assertions of `puzzle` with two solver queries and return the found
assignment of the [`AttributeExprs`](@ref) as a matrix of positions.

The first query must find a solution and a second query excluding the found assignment must be
unsatisfiable, which proves that the solution is unique. Unsatisfiable, non-unique and inconclusive
solver outcomes throw an `ArgumentError`. The assignment is snapshotted before the second query
because `Satisfiability.sat!` overwrites (or clears) the model values of its expressions.

The stored truth table of the puzzle is never consulted: a complete table may be stale and
[`solve!`](@ref) only warns about non-unique solutions.
"""
function unique_solution_assignment(puzzle::UnsolvedZebraPuzzle)
    exprs = AttributeExprs(puzzle)
    puzzle_assertions = and(assertions(puzzle, exprs))
    status = sat!(puzzle_assertions)
    if status == :UNSAT
        throw(ArgumentError(
            "Cannot export the puzzle: its rules and clues are unsatisfiable (no solution exists)."
        ))
    elseif status != :SAT
        throw(ArgumentError(
            "Cannot export the puzzle: the solver could not decide satisfiability (status `$status`)."
        ))
    end
    values = value(exprs)
    if any(isnothing, values)
        throw(ArgumentError(
            "Cannot export the puzzle: the solver returned no usable model for a satisfiable puzzle."
        ))
    end
    assignment = Int.(values) # snapshot before the second query overwrites the solver state
    exclusion_status = sat!(and(puzzle_assertions, or(exprs.exprs .!= assignment)))
    if exclusion_status == :SAT
        throw(ArgumentError(
            "Cannot export the puzzle: its rules and clues do not determine a unique solution. " *
                "`solve!` only warns about this.",
        ))
    elseif exclusion_status != :UNSAT
        throw(ArgumentError(
            "Cannot export the puzzle: the solver could not decide the uniqueness of the solution " *
                "(status `$exclusion_status`)."
        ))
    end
    return assignment
end

"""
    fill_truthtable!(puzzle::UnsolvedZebraPuzzle, assignment::Matrix{Int})
Fill the truth table of `puzzle` with the attributes at the positions given by the solver
`assignment` (see [`unique_solution_assignment`](@ref)). Any previously stored (possibly stale) table
content is overwritten.
"""
function fill_truthtable!(puzzle::UnsolvedZebraPuzzle, assignment::Matrix{Int})
    foreach(attributes(puzzle)) do a
        puzzle.table[assignment[indexof(puzzle, a)...], col(a)] = a
    end
    return puzzle
end

"""
    puzzle_record(puzzle::UnsolvedZebraPuzzle)::Dict{String,Any}
Export `puzzle` as a validated, detached and JSON-compatible record: a `Dict{String,Any}` with
string keys, arrays, strings and integers (schema version `1`).

The puzzle must hold exactly one supported question (an [`AttributeQuestion`](@ref) or a
[`PositionQuestion`](@ref)) and its rules and clues must determine a unique solution. The record is
always derived from a fresh solve of a copy of the puzzle, whether or not its internal truth table
was previously filled. The stored table is never trusted: a complete table may be stale after clue
edits and [`solve!`](@ref) only warns about non-unique solutions. Unsatisfiable, non-unique and
inconclusive solver outcomes are rejected, as are puzzles with zero, multiple, invalid or
unsupported questions. The input `puzzle` is not mutated and nothing is printed.

# Record fields
- `schema_version::Int` -- always `1`.
- `riddle::String` -- the rendered riddle text including the one question.
- `dimensions::Dict{String,Any}` -- `subjects`, `attribute_types` and `clue_count` measured from the puzzle.
- `question::Dict{String,Any}` -- `kind` (`"attribute"` or `"position"`), the `subject` as an object with `attribute_type` and raw string `value` and, for attribute questions only, the `attribute_type` of the requested category.
- `solution::Dict{String,Any}` -- `columns` (the declared category names) and `rows` (arrays of raw attribute strings in that column order). Rows are in position order; the first row is position 1.
- `answer::Dict{String,Any}` -- `{"kind" => "attribute", "attribute_type" => ..., "value" => ...}` or `{"kind" => "position", "value" => <one-based position integer>}`.

# JSON encoding
JSON encoding is deliberately kept out of the package: the returned value is plain data that can be
serialized by a JSON library in the caller's environment, e.g. with JSON.jl v1

```julia
using JSON

record = puzzle_record(puzzle)
JSON.json(record) # one compact UTF-8 JSON object
```

A batch writer can emit one compact UTF-8 JSON object per line (JSON Lines) with a trailing newline
and no blank lines

```julia
open("puzzles.jsonl", "w") do io
    for puzzle in puzzles
        println(io, JSON.json(puzzle_record(puzzle)))
    end
end
```

!!! note "Phrasing is randomized"
    Clue and question phrasing uses `rand`, so the `riddle` text differs from call to call. Persist
    the returned record instead of trying to reproduce the text from a seed: the seed to phrase
    mapping is not guaranteed to be stable across Julia or package versions.

# Examples
```jldoctest
julia> puzzle = ZP.UNSOLVED_EINSTEINS_ZEBRA |> deepcopy;

julia> add_question!(puzzle, AttributeQuestion{Drink}(House("ivory")));

julia> record = puzzle_record(puzzle);

julia> record["schema_version"]
1

julia> (record["dimensions"]["subjects"], record["dimensions"]["attribute_types"], record["dimensions"]["clue_count"])
(5, 5, 14)

julia> (record["question"]["kind"], record["question"]["subject"]["value"], record["question"]["attribute_type"])
("attribute", "ivory", "Drink")

julia> (record["answer"]["kind"], record["answer"]["attribute_type"], record["answer"]["value"])
("attribute", "Drink", "orange juice")

julia> record["solution"]["columns"]
5-element Vector{String}:
 "Drink"
 "House"
 "Nationality"
 "Pet"
 "Smoke"

julia> record["solution"]["rows"][4]
5-element Vector{String}:
 "orange juice"
 "ivory"
 "Spaniard"
 "dog"
 "Lucky Strike"

julia> position_puzzle = ZP.UNSOLVED_EINSTEINS_ZEBRA |> deepcopy;

julia> add_question!(position_puzzle, PositionQuestion(House("ivory")));

julia> position_record = puzzle_record(position_puzzle);

julia> (position_record["answer"]["kind"], position_record["answer"]["value"])
("position", 4)
```
"""
function puzzle_record(puzzle::UnsolvedZebraPuzzle)
    length(puzzle.questions) == 1 || throw(ArgumentError(
        "Cannot export the puzzle: it must hold exactly one question, got " *
            "$(length(puzzle.questions))."
    ))
    question = only(puzzle.questions)
    if !(question isa PositionQuestion) &&
        !(question isa AttributeQuestion && question.subject isa Attribute)
        throw(ArgumentError(
            "Cannot export the question $(string(question)) of type $(typeof(question)): only " *
                "`AttributeQuestion`s about attributes and `PositionQuestion`s are supported."
        ))
    end
    check(puzzle, question) # throws `AttributeTypeError`/`AttributeVariantError` for invalid questions
    any(a -> a <: Subject, attrtypes(puzzle)) || throw(ArgumentError(
        "Cannot export the puzzle: rendering the riddle requires an attribute type subtyping " *
            "`Subject` (`House` or `Person`), got `$(attrtypes(puzzle))`."
    ))

    solved = deepcopy(puzzle) # never mutate (or trust) the input puzzle and its stored table
    assignment = unique_solution_assignment(solved)
    fill_truthtable!(solved, assignment)

    table = solved.table
    columns = names(table)
    rows = [[string(table[i, name]) for name in columns] for i in axes(table, 1)]
    return Dict{String,Any}(
        "schema_version" => PUZZLE_RECORD_SCHEMA_VERSION,
        "riddle" => riddle(puzzle; quiet=true),
        "dimensions" => Dict{String,Any}(
            "subjects" => size(table, 1),
            "attribute_types" => size(table, 2),
            "clue_count" => length(puzzle.clues),
        ),
        "question" => question_record(question),
        "solution" => Dict{String,Any}("columns" => columns, "rows" => rows),
        "answer" => answer_record(question, solved),
    )
end

export puzzle_record
