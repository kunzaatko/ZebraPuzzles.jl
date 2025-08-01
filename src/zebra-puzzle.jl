using Tables, DataAPI, Markdown

include("satisfiability.jl")

Tables.istable(::Type{<:ZebraPuzzle}) = true
Tables.rowaccess(::Type{<:ZebraPuzzle}) = true
Tables.rows(x::ZebraPuzzle) = Tables.rows(x.table)
Tables.columnaccess(::Type{<:ZebraPuzzle}) = true
Tables.columns(x::ZebraPuzzle) = Tables.columns(x.table)
Tables.schema(x::ZebraPuzzle) = Tables.schema(x.table)
Tables.subset(x::ZebraPuzzle, inds; viewhint) = Tables.subset(x.table, inds; viewhint)

"""
    nrow(z::ZebraPuzzle)
Returns the number of rows of the solution table for the puzzle `z` which is equal to the number of subjects the puzzle
is about.

See also [`ncol`](@ref), [`nattr`](@ref)

```jldoctest
julia> ZP.nrow(ZP.EINSTEINS_ZEBRA)
5
```
"""
DataAPI.nrow(::ZebraPuzzle{K}) where {K} = K

"""
    ncol(z::ZebraPuzzle)
Returns the number of columns of the solution table for the puzzle `z` which is equal to the number of attributes linked
to each of the puzzle subjects.

See also [`nrow`](@ref), [`nattr`](@ref)


```jldoctest
julia> ZP.ncol(ZP.EINSTEINS_ZEBRA)
5
```
"""
DataAPI.ncol(::ZebraPuzzle{<:Any,N}) where {N} = N

"""
    indexof(z::ZebraPuzzle, A::Type{<:Attribute})
    indexof(z::ZebraPuzzle, a::Attribute)
Return the internal index of the attribute / attribute type

This internal index is used indexing into the [`AttributeExprs`](@ref) of the puzzle, which holds the [`Satisfiability.jl`](@extref Satisfiability :std:doc:`index`) variable used for solving the puzzle. 

Every subtype of `ZebraPuzzle` must implement this interface.

```jldoctests
julia> ZP.indexof(ZP.EINSTEINS_ZEBRA, Smoke("Chesterfields"))
(2, 3)

julia> ZP.indexof(ZP.EINSTEINS_ZEBRA, Smoke)
3
```
"""
@interface indexof(z::ZebraPuzzle, ::Type{<:Attribute})
@interface indexof(z::ZebraPuzzle, ::Attribute)

"""
    truthtable(puzzle::ZebraPuzzle)
Get the truth table of the `puzzle`.

Throws a `PuzzleError` if the puzzle is not solved yet.
"""
@interface truthtable(z::ZebraPuzzle)

"""
    attributes(puzzle::ZebraPuzzle)
Get all the attributes of the `puzzle`

Every subtype of `ZebraPuzzle` must implement this interface.

```jldoctest
julia> attributes(ZP.EINSTEINS_ZEBRA)
25-element Vector{ZebraPuzzles.Attribute}:
 House("yellow")
 House("blue")
 House("red")
 House("ivory")
 House("green")
 Nationality("Norwegian")
 Nationality("Ukrainian")
 Nationality("Englishman")
 Nationality("Spaniard")
 Nationality("Japanese")
 ⋮
 Drink("tea")
 Drink("milk")
 Drink("orange juice")
 Drink("coffee")
 Pet("fox")
 Pet("horse")
 Pet("snails")
 Pet("dog")
 Pet("zebra")
```
"""
@interface attributes(z::ZebraPuzzle)

"""
    attributes(puzzle::ZebraPuzzle, S::Type{<:Attribute})
Get the attributes of the puzzle of the given type `s`.

Every subtype of `ZebraPuzzle` must implement this interface.

```jldoctest
julia> attributes(ZP.EINSTEINS_ZEBRA, Smoke)
5-element Vector{Smoke}:
 Smoke("Kools")
 Smoke("Chesterfields")
 Smoke("Old Gold")
 Smoke("Lucky Strike")
 Smoke("Parliaments")
```
"""
@interface attributes(z::ZebraPuzzle, ::Type{<:Attribute})

"""
    attributes(puzzle::ZebraPuzzle, S::Not{<:Type{<:Attribute}})
Get the attributes of the puzzle other than the given type `S`.

Every subtype of `ZebraPuzzle` must implement this interface.

```jldoctest
julia> attributes(ZP.EINSTEINS_ZEBRA, Not(Smoke))
20-element Vector{ZebraPuzzles.Attribute}:
 House("yellow")
 House("blue")
 House("red")
 House("ivory")
 House("green")
 Nationality("Norwegian")
 Nationality("Ukrainian")
 Nationality("Englishman")
 Nationality("Spaniard")
 Nationality("Japanese")
 Drink("water")
 Drink("tea")
 Drink("milk")
 Drink("orange juice")
 Drink("coffee")
 Pet("fox")
 Pet("horse")
 Pet("snails")
 Pet("dog")
 Pet("zebra")
```
"""
function attributes(z::ZebraPuzzle, s::Not{<:Type})
    check_attrtype(z, s.skip)
    return vcat((attributes(z, t) for t in filter(!=(s.skip), attrtypes(z)))...)
end

"""
    nattr(z::ZebraPuzzle)
Returns the total number of attributes of the puzzle `z` which is equal to `nrow(z) * ncol(z)`

See also [`nrow`](@ref), [`ncol`](@ref)

```jldoctest
julia> ZP.nattr(ZP.EINSTEINS_ZEBRA)
25
```
"""
nattr(z::ZebraPuzzle) = ncol(z) * nrow(z)

"""
    attrtypes(puzzle)
Get the attribute parameters of the `puzzle`

```jldoctest
julia> ZP.attrtypes(ZP.EINSTEINS_ZEBRA)
5-element Vector{DataType}:
 House
 Nationality
 Drink
 Smoke
 Pet
```
"""
attrtypes(::ZebraPuzzle{<:Any,<:Any,Attrs}) where {Attrs} = [Attrs.parameters...]

"""
    AttributeError <: Exception
Thrown when an attribute is passed in the context of a puzzle, where this attribute is not valid.

Subtypes defined in `ZebraPuzzles` are [`AttributeTypeError`](@ref) and [`AttributeVariantError`](@ref)
"""
abstract type AttributeError <: Exception end

"""
    AttributeTypeError <: AttributeError
An error thrown when an attribute has an invalid type for the given puzzle

See also [`check_attrtype`](@ref) and [`AttributeVariantError`](@ref)
"""
struct AttributeTypeError <: AttributeError
    attrtype::Type{<:Attribute}
    puzzle::Ref{<:ZebraPuzzle}
end
function Base.showerror(io::IO, e::AttributeTypeError)
    return print(
        io,
        "AttributeTypeError: attribute type `$(e.attrtype)` is invalid for the given puzzle. Valid types are `$(attrtypes(e.puzzle[]))`",
    )
end

"""
    check_attrtype(puzzle, s::Type{<:Attribute})
    check_attrtype(puzzle, s::Attribute)
Check that the attribute of type `s` is a valid attribute type in the `puzzle`

```jldoctest
julia> ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, House)
true

julia> ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, House("red"))
true

julia> ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, House("pink")) # !!! This only checks the type !!!
true

julia> ZP.check_attrtype(ZP.EINSTEINS_ZEBRA, Hat)
ERROR: AttributeTypeError: attribute type `Hat` is invalid for the given puzzle. Valid types are `DataType[House, Nationality, Drink, Smoke, Pet]`
[...]
```
"""
function check_attrtype(z::ZebraPuzzle, s::Type{<:Attribute})
    return s in attrtypes(z) || throw(AttributeTypeError(s, Ref(z)))
end
check_attrtype(z::ZebraPuzzle, s::Attribute) = check_attrtype(z, typeof(s))

"""
    AttributeVariantError <: AttributeError
An error thrown when an attribute has a variant but the puzzle does not contain the variant of the attribute passed in the context of the puzzle.

See also [`check_attrvariant`](@ref)
"""
struct AttributeVariantError <: AttributeError
    attr::Attribute
    puzzle::Ref{<:ZebraPuzzle}
end
function Base.showerror(io::IO, e::AttributeVariantError)
    return print(
        io,
        "AttributeVariantError: attribute `$(e.attr)` has puzzle type but the puzzle does not contain the variant. Puzzle variants for this attribute type are `$(map(string, attributes(e.puzzle[], typeof(e.attr))))`",
    )
end

"""
    check_attrvariant(puzzle, s::Attribute)
Check that the attribute variant `s` is included in the `puzzle`.

!!! warning
    Assumes that the attribute type `typeof(s)` is valid for the `puzzle`.
"""
function check_attrvariant(z::ZebraPuzzle, s::Attribute)
    return s in attributes(z, typeof(s)) || throw(AttributeVariantError(s, Ref(z)))
end

"""
    ClueError <: Exception
Thrown when a clue is in conflict with puzzle rules or not compatible with current rules of a puzzle passed within the same context.

Subtypes defined in `ZebraPuzzles` are [`DuplicateClue`](@ref) and [`ImpliedClue`](@ref)
"""
abstract type ClueError <: Exception end

"""
    DuplicateClue <: ClueError
An error thrown when trying to add a clue that is already included in the puzzle.

See also [`check_duplicate`](@ref)
"""
struct DuplicateClue <: ClueError
    c::Clue
    puzzle::Ref{<:ZebraPuzzle}
end
function Base.showerror(io::IO, e::DuplicateClue)
    return print(
        io,
        "DuplicateClue: clue $(string(e.c)) is already inlcuded in the puzzle on the $(findfirst(==(e.c), e.puzzle[].clues)) place.",
    )
end

"""
    check_duplicate(puzzle, c::Clue)
Check that the clue `c` is not already included in the `puzzle`.
"""
function check_duplicate(z::ZebraPuzzle, c::Clue)
    return c in z.clues && throw(DuplicateClue(c, Ref(z)))
end

"""
    ImpliedClue <: ClueError
An error thrown when trying to add a clue that is implied by the rules and clues already included in the puzzle.

See also [`check_implied`](@ref), [`MinimalityViolation`](@ref)
"""
struct ImpliedClue <: ClueError
    c::Clue
    puzzle::Ref{<:ZebraPuzzle}
end
function Base.showerror(io::IO, e::ImpliedClue)
    return print(
        io,
        "ImpliedClue: clue $(string(e.c)) is implied by the rules and clues already included in the puzzle.",
    )
end

"""
    check_implied(puzzle, c::Clue, exprs::AttributeExprs=AttributeExprs(puzzle))
Check that the clue `c` is not implied by the rules and clues already included in the `puzzle`.

```jldoctest
julia> z = ZebraPuzzle(Drink => ("coffee", "tea"), Smoke => ("Old Gold", "Chesterfields"), House => ("green", "red"));

julia> ZP.add_clue!(z, Clue(House("red"), Smoke("Old Gold")));

julia> ZP.add_clue!(z, Clue(Smoke("Old Gold"), Drink("tea")))
UnsolvedZebraPuzzle{2, 3, Tuple{Drink, Smoke, House}} with 2 clues
┌────────────────────────────────┐
│ Drink        coffee, tea       │
├────────────────────────────────┤
│ Smoke  Old Gold, Chesterfields │
├────────────────────────────────┤
│ House        green, red        │
└────────────────────────────────┘

clues:
1) House("red") ⟹ Smoke("Old Gold")
2) Smoke("Old Gold") ⟹ Drink("tea")

julia> ZP.check_implied(z, AbsolutePosition(House("red"), 1)) # independent clue
true

julia> ZP.check_implied(z, Clue(Drink("tea"), House("red"))) # (red => old gold) ∧ (old gold => tea) => (red => tea)
ERROR: ImpliedClue: clue Drink("tea") ⟹ House("red") is implied by the rules and clues already included in the puzzle.
[...]
```
"""
function check_implied(z::ZebraPuzzle, c::Clue, exprs::AttributeExprs=AttributeExprs(z))
    return sat!(and(not(expr(c, exprs)), and(assertions(z, exprs)))) == :SAT ||
           throw(ImpliedClue(c, Ref(z)))
end

"""
    PuzzleError <: Exception
Thrown when a puzzle would violate some optimality conditions by undergoing an operation.

Subtypes defined in `ZebraPuzzles` are [`MinimalityViolation`](@ref)
"""
abstract type PuzzleError <: Exception end

"""
    MinimalityViolation <: PuzzleError
An error thrown when the puzzle minimality would be violated by an operation.

Minimality of the puzzle means that there are no clues which could be discarded and still leave the puzzle solution intact and tractable.

See also [`check_minimal`](@ref), [`ImpliedClue`](@ref)
"""
struct MinimalityViolation <: PuzzleError
    c::Clue
    puzzle::Ref{<:ZebraPuzzle}
end
function Base.showerror(io::IO, e::MinimalityViolation)
    return print(
        io,
        "MinimalityViolation: adding the clue `$(string(e.c))` would break the minimality of the clue set for the puzzle. I.e. the current puzzle clues `$(e.puzzle[].clues)` already imply the puzzle solution.",
    )
end

"""
    check_minimal(puzzle, c::Clue, exprs::AttributeExprs=AttributeExprs(puzzle))
Check that the clue `c` is not breaking the minimality of the `puzzle` clue set. I.e. that adding the additional clue is not necessary for finding the solution.
"""
function check_minimal(z::ZebraPuzzle, c::Clue, exprs::AttributeExprs=AttributeExprs(z))
    puzzle_assertions = assertions(z, exprs)
    status = sat!(puzzle_assertions) # populates the model with a solution -> we can get the model with values(exprs)
    @assert status == :SAT "Solver did not succeed with the current rules and clues. status = $status"
    @assert !any(isnothing.(value(exprs))) "Solved model was not created"
    # NOTE: Check whether the all the clues and rules are compatible with multiple solutions (i.e. any of the model
    # values is different) <11-06-25> 
    return sat!(and(and(puzzle_assertions), or(exprs.exprs .!= value(exprs)))) == :SAT ||
           throw(MinimalityViolation(c, Ref(z)))
end

"""
    check(z::ZebraPuzzle, c::Clue)
Check that the clue `c` is compatible with the puzzle `z`. 

All subtypes of `ZebraPuzzle` must implement this interface

See also [`check_attrtype`](@ref), [`check_attrvariant`](@ref), [`check_minimal`](@ref), [`check_implied`](@ref)

```jldoctest
julia> all(ZP.check.(fill(ZP.EINSTEINS_ZEBRA), ZP.EINSTEINS_ZEBRA.clues; duplicates=false, minimal=false, implied=false))
true
```
"""
@interface check(z::ZebraPuzzle, ::Clue; kwargs...)

"""
    add_clue!(z::ZebraPuzzle, c::Clue; ischecked=false, kwargs...)
Adds a single clue `c` to the `ZebraPuzzle` `z`.

The clue is checked (See [`check`](@ref)) prior to its addition if `ischecked == false`. Any other keyword arguments
are passed to [`check`](@ref).

See also [`add_clues!`](@ref)

```jldoctest
julia> z = ZP.SIMPLE_ZEBRA |> deepcopy;

julia> add_clue!(z, Clue(House("green"), Smoke("Parliaments")))
SolvedZebraPuzzle{3, 4, Tuple{House, Nationality, Smoke, Drink}} with 1 clues
┌────────────────────────────────────────────────┐
│ House  Nationality     Smoke         Drink     │
├────────────────────────────────────────────────┤
│  red   Englishman     Old Gold        tea      │
├────────────────────────────────────────────────┤
│ green   Japanese    Parliaments      coffee    │
├────────────────────────────────────────────────┤
│ ivory   Spaniard    Lucky Strike  orange juice │
└────────────────────────────────────────────────┘

clues:
1) House("green") ⟹ Smoke("Parliaments")
```
"""
function add_clue!(z::ZebraPuzzle, c::Clue; ischecked=false, kwargs...)
    !ischecked && check(z, c; kwargs...)
    push!(z.clues, c)
    return z
end
|
"""
    add_clue!(z::ZebraPuzzle)

Adds a randomly generated clue to the `ZebraPuzzle` `z`.

```jldoctest; setup = :(using Random; Random.seed!(42))
julia> z = ZP.SIMPLE_ZEBRA |> deepcopy;

julia> add_clue!(z)
SolvedZebraPuzzle{3, 4, Tuple{House, Nationality, Smoke, Drink}} with 1 clues
┌────────────────────────────────────────────────┐
│ House  Nationality     Smoke         Drink     │
├────────────────────────────────────────────────┤
│  red   Englishman     Old Gold        tea      │
├────────────────────────────────────────────────┤
│ green   Japanese    Parliaments      coffee    │
├────────────────────────────────────────────────┤
│ ivory   Spaniard    Lucky Strike  orange juice │
└────────────────────────────────────────────────┘

clues:
1) Pos[Nationality("Japanese")] < Pos[Smoke("Lucky Strike")]
```
"""
function add_clue!(z::ZebraPuzzle)
    c = rand(Clue, z)
    return add_clue!(z, c; types=false, variants=false) # NOTE: Valid must be checked in case of UnsolvedZebraPuzzle since we need to ensure the consistency of the clue set
end

"""
    add_clues!(z::ZebraPuzzle, cs::Vector{<:Clue}; ischecked=false, kwargs...)

Adds clues from `cs` to the `ZebraPuzzle` `z`.

The clues are checked (See [`check`](@ref)) prior to their addition if `ischecked == false`. Any other keyword arguments
    are passed to [`check`](@ref).

```jldoctest
julia> z = ZP.SIMPLE_ZEBRA |> deepcopy;

julia> add_clues!(z, [
            Clue(House("red"), Smoke("Old Gold")),
            Clue(Nationality("Spaniard"), Drink("orange juice"))
        ])
SolvedZebraPuzzle{3, 4, Tuple{House, Nationality, Smoke, Drink}} with 2 clues
┌────────────────────────────────────────────────┐
│ House  Nationality     Smoke         Drink     │
├────────────────────────────────────────────────┤
│  red   Englishman     Old Gold        tea      │
├────────────────────────────────────────────────┤
│ green   Japanese    Parliaments      coffee    │
├────────────────────────────────────────────────┤
│ ivory   Spaniard    Lucky Strike  orange juice │
└────────────────────────────────────────────────┘

clues:
1) House("red") ⟹ Smoke("Old Gold")
2) Nationality("Spaniard") ⟹ Drink("orange juice")
```
"""
function add_clues!(z::ZebraPuzzle, cs::Vector{<:Clue}; ischecked=false, kwargs...)
    foreach(c -> add_clue!(z, c; ischecked), cs)
    return z
end

"""
    check(z::ZebraPuzzle, q::Question, types=true, variants=true)
Implementation of the `check` interface for `ZebraPuzzle` that checks the questions `q` for valid types and attribute
variants.

# Keyword Arguments
Keyword arguments control which of the checks are controlled for the clue.
- `types=true` --  question has valid attribute types for the puzzle?
- `variants=true` -- question has valid attribute variants ("names") for the puzzle?
"""
function check(z::ZebraPuzzle, q::Question; types=true, variants=true)
    types && foreach(p -> check_attrtype(z, p), attr_types(q))
    variants && foreach(p -> check_attrvariant(z, p), attributes(q))

    return true
end

"""
    add_question!(z::ZebraPuzzle, q::Question; ischecked=false)
Add a question `q` to the `ZebraPuzzle` `z`.

The question is checked (See [`check`](@ref)) prior to its addition if `ischecked == false`. Any other keyword arguments
are passed to [`check`](@ref).

```jldoctest
julia> z = ZP.SIMPLE_ZEBRA |> deepcopy;

julia> add_question!(z, AttributeQuestion{Drink}(House("red")))
SolvedZebraPuzzle{3, 4, Tuple{House, Nationality, Smoke, Drink}} with no clues and 1 questions
┌────────────────────────────────────────────────┐
│ House  Nationality     Smoke         Drink     │
├────────────────────────────────────────────────┤
│  red   Englishman     Old Gold        tea      │
├────────────────────────────────────────────────┤
│ green   Japanese    Parliaments      coffee    │
├────────────────────────────────────────────────┤
│ ivory   Spaniard    Lucky Strike  orange juice │
└────────────────────────────────────────────────┘

questions:
1) Drink[House("red")]?
```
"""
function add_question!(z::ZebraPuzzle, q::Question; ischecked=false, kwargs...)
    !ischecked && check(z, q; kwargs...)
    push!(z.questions, q)
    return z
end
function add_question!(z::ZebraPuzzle)
    q = rand(Question, z)
    return add_question!(z, q; ischecked=true)
end

"""
    has_unique_solution(z::ZebraPuzzle) 
Check whether the clues of the puzzle lead to one unique solution.

```jldoctest
julia> ZP.has_unique_solution(ZP.UNSOLVED_EINSTEINS_ZEBRA)
true
```
"""
function has_unique_solution(z::ZebraPuzzle, exprs::AttributeExprs=AttributeExprs(z))
    puzzle_assertions = and(assertions(z, exprs))
    status = sat!(puzzle_assertions) # populates the model with a solution -> we can get the model with values(exprs)
    @assert status == :SAT "Solver did not succeed with the current rules and clues. status = $status"
    @assert !any(isnothing.(value(exprs))) "Solved model was not created"
    # NOTE: Check whether the all the clues and rules are compatible with multiple solutions (i.e. any of the model
    # values is different) <11-06-25> 
    return sat!(and(puzzle_assertions, or(exprs.exprs .!= value(exprs)))) == :UNSAT
end

"""
    UnsolvablePuzzle <: PuzzleError
Thrown when calling `riddle` on a puzzle that is not solvable.
"""
struct UnsolvablePuzzle <: PuzzleError
    puzzle::Ref{<:ZebraPuzzle}
end
function Base.showerror(io::IO, e::UnsolvablePuzzle)
    return print(io, "UnsolvablePuzzle: puzzle $(e.puzzle[]) is not solvable")
end

"""
    riddle(puzzle::ZebraPuzzle; <kwargs>)
Return the string of the zebra puzzle introduction and clues in natural language.

The string uses markdown for bullet points or numbers and prints the Markdown using the context IO.

If `introduction=false` is (default `true`) the introduction such as `"There are five houses."` is skipped.
If `bulletpoints=true`, the clues are prefixed with `"- "` and if `numbers=true` the clues are prefixed with `"i)"`. If both are `false` the clues only have a space between them.

If `quiet=true` the riddle is not printed but only returned as a string.

See also [`solve!`](@ref)
"""
function riddle(
    puzzle::ZebraPuzzle{K};
    numbers=false,
    bulletpoints=!numbers,
    introduction=true,
    quiet=false,
) where {K}
    mainsubject = attrtypes(puzzle)[findfirst(a -> a <: Subject, attrtypes(puzzle))]
    has_unique_solution(puzzle) || throw(UnsolvablePuzzle(Ref(puzzle)))
    riddle_string = introduction ? introductionstring(mainsubject, K) * "\n" : ""
    for (i, c) in enumerate(puzzle.clues)
        prefix = if bulletpoints
            "- "
        elseif numbers
            string(i) * ") "
        else
            ""
        end
        riddle_string *= prefix * phrase(c) * "\n"
    end

    if !isempty(puzzle.questions)
        riddle_string *= "\n"
        if length(puzzle.questions) > 1
            for (i, q) in enumerate(puzzle.questions)
                prefix = if bulletpoints
                    "- "
                elseif numbers
                    string(i) * ") "
                else
                    ""
                end
                riddle_string *= prefix * phrase(q) * "\n"
            end
        else
            riddle_string *= phrase(puzzle.questions[1])
        end
    end
    quiet || print(Markdown.parse(riddle_string))
    return riddle_string
end

"""
    answer(puzzle::ZebraPuzzle)
Give the phrases for the answers to the puzzle questions.

```julia-repl
julia> puz = ZP.EINSTEINS_ZEBRA |> deepcopy;

julia> add_question!(puz); puz.questions[1]
PositionQuestion{House}(House("ivory"))

julia> ZP.answer(puz)
"The ivory house is in the fourth position."
```
"""
function answer(puzzle::ZebraPuzzle)
    answers = phrase.(toclue(q, puzzle) for q in puzzle.questions)
    if length(answers) == 1
        return answers[1]
    else
        return join("- " .* answers, "\n")
    end
end

for func in (:(==), :isequal)
    @eval function Base.$func(
        tf1::A, tf2::B; kwargs...
    ) where {A<:ZebraPuzzle,B<:ZebraPuzzle}
        nameof(A) === nameof(B) || return false
        fields = fieldnames(A)
        fields === fieldnames(B) || return false

        for f in fields
            isdefined(tf1, f) && isdefined(tf2, f) || return false
            # perform equivalence check to support types that have no defined equality, such
            # as `missing`
            getfield(tf1, f) === getfield(tf2, f) ||
                $func(getfield(tf1, f), getfield(tf2, f); kwargs...) isa Missing ||
                $func(getfield(tf1, f), getfield(tf2, f); kwargs...) ||
                return false
        end

        return true
    end
end

"""
    nclue(puzzle)
Get the number of clues of the puzzle.
"""
nclue(zp::ZebraPuzzle) = length(zp.clues)

"""
    nquestion(puzzle)
Get the number of questions of the puzzle.
"""
nquestion(zp::ZebraPuzzle) = length(zp.questions)
