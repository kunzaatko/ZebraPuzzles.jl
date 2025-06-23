using PrettyTables.Crayons

"""
    UnsolvedZebraPuzzle{K,N,Attrs} <: ZebraPuzzle{K,N,Attrs}
A [`ZebraPuzzle`](@ref) that is created without a solution table. It has a known set of attributes and possibly a list
of clues.

See also [`fill_clues!`](@ref), [`solve!`](@ref)
"""
mutable struct UnsolvedZebraPuzzle{K,N,Attrs} <: ZebraPuzzle{K,N,Attrs}
    table::DataFrame
    attr_variants::Dict
    clues::Vector{Clue}
end

# interface implementations
function indexof(z::UnsolvedZebraPuzzle, a::Type{<:Attribute})
    return findfirst(==(string(col(a))), names(z.table))
end
function indexof(z::UnsolvedZebraPuzzle, a::Attribute)
    return (findfirst(==(a), z.attr_variants[typeof(a)]), indexof(z, typeof(a)))
end

const AttributeVariants = Pair{<:Type,<:Tuple{Attribute,Vararg{Attribute}}}

"""
    ZebraPuzzle(attr_variants...)
Construct an unsolved zebra puzzle. The puzzle holds the variants of the attributes and a solution table with missing
values. Clues can be later added by [`add_clues!`](@ref).

```jldoctests
julia> ZebraPuzzle(
               House => ("red", "blue", "green"), 
               Person => ("Martin", "David", "Lucas"), 
               Pet => ("Weasel", "Cow", "Mammoth")
           )
UnsolvedZebraPuzzle{3, 3, Tuple{House, Person, Pet}} with no clues
┌──────────────────────────────┐
│ House     red, blue, green   │
├──────────────────────────────┤
│ Person  Martin, David, Lucas │
├──────────────────────────────┤
│  Pet    Weasel, Cow, Mammoth │
└──────────────────────────────┘
```
"""
function ZebraPuzzle(z1::AttributeVariants, zns::Vararg{AttributeVariants})
    zebra = (z1, zns...)
    K = length(z1.second)
    N = length(zebra)
    @assert all(allunique(string(a.second) for a in zebra)) "All attributes of a single type must be unique"
    df_mat = Matrix{Union{Missing,Attribute}}(undef, K, N)
    df = DataFrame(fill!(df_mat, missing), [col(a.first) for a in zebra])
    Attrs = Tuple{(a.first for a in zebra)...}
    return UnsolvedZebraPuzzle{K,N,Attrs}(
        df, Dict(a.first => [a.second...] for a in zebra), Clue[]
    )
end

const AttributeVariantNames = Pair{<:Type,<:Tuple{AbstractString,Vararg{AbstractString}}}
function parse_attrvars(z::AttrVar) where {AttrVar<:AttributeVariantNames}
    return z.first => parse.(fill(z.first), z.second)
end
function ZebraPuzzle(
    z1::AttrVars, zns::Vararg{AttrVars}
) where {AttrVars<:AttributeVariantNames}
    return ZebraPuzzle(parse_attrvars(z1), parse_attrvars.(zns)...)
end

# interface implementations
function attributes(z::UnsolvedZebraPuzzle)
    return vcat(values(z.attr_variants)...)
end
function attributes(z::UnsolvedZebraPuzzle, s::Type{<:Attribute})
    check_attrtype(z, s)
    return z.attr_variants[s]
end

function Base.show(io::IO, ::MIME"text/plain", z::UnsolvedZebraPuzzle)
    Base.showarg(io, z, true)
    if isempty(z.clues)
        print(io, " with no clues\n")
    else
        print(io, " with $(length(z.clues)) clues\n")
    end
    @mock pretty_table(
        io,
        DataFrame(
            string(k) => v for (k, v) in ((k, z.attr_variants[k]) for k in attrtypes(z))
        );
        alignment=:c,
        hlines=:all,
        vlines=[0, :end],
        show_header=false,
        show_subheader=false,
        formatters=(v, _, j) -> j == 2 ? join(map(string, v), ", ") : v,
        highlighters=Highlighter((_, _, j) -> j == 1, Crayons.crayon"yellow bold"),
    )
    if !isempty(z.clues)
        printstyled(io, "\nclues:\n"; bold=true, underline=true)
        for (i, clue) in enumerate(z.clues)
            printstyled(io, i, ") "; bold=true)
            printstyled(io, string(clue); italic=true)
            print(io, "\n")
        end
    end
end

"""
    ConflictingClue <: ClueError
Thrown when trying to add a clue that is in conflict with the clues that are already in the puzzle.
"""
struct ConflictingClue <: ClueError
    c::Clue
    puzzle::Ref{<:UnsolvedZebraPuzzle}
end
function Base.showerror(io::IO, e::ConflictingClue)
    return print(
        io,
        "ConflictingClue: clue $(string(e.c)) is in conflict with the current rules/clues in the puzzle.",
    )
end

"""
    check_valid(z::UnsolvedZebraPuzzle, c::Clue, exprs=AttributeExprs(z))
Validate the truth of the clue under the assertion of puzzle rules and the current puzzle clues.

```jldoctest
julia> puzzle = ZP.UNSOLVED_EINSTEINS_ZEBRA |> deepcopy;

julia> empty!(puzzle.clues)
Clue[]

julia> add_clue!(puzzle, Clue(House("blue"), Pet("horse")))
UnsolvedZebraPuzzle{5, 5, Tuple{Drink, House, Nationality, Pet, Smoke}} with 1 clues
┌────────────────────────────────────────────────────────────────────────┐
│    Drink              coffee, milk, orange juice, tea, water           │
├────────────────────────────────────────────────────────────────────────┤
│    House                  blue, green, ivory, red, yellow              │
├────────────────────────────────────────────────────────────────────────┤
│ Nationality    Englishman, Japanese, Spaniard, Ukrainian, Norwegian    │
├────────────────────────────────────────────────────────────────────────┤
│     Pet                   dog, horse, snails, zebra, fox               │
├────────────────────────────────────────────────────────────────────────┤
│    Smoke     Chesterfields, Lucky Strike, Old Gold, Parliaments, Kools │
└────────────────────────────────────────────────────────────────────────┘

clues:
1) House("blue") ⟹ Pet("horse")

julia> ZP.check_valid(puzzle, Clue(House("red"), Pet("horse")))
ERROR: ConflictingClue: clue House("red") ⟹ Pet("horse") is in conflict with the current rules/clues in the puzzle.
[...]
```
"""
function check_valid(
    z::UnsolvedZebraPuzzle, c::Clue, exprs::AttributeExprs=AttributeExprs(z)
)
    return sat!(and(expr(c, exprs), and(assertions(z, exprs)))) == :SAT ||
           throw(ConflictingClue(c, Ref(z)))
end

"""
    check(puzzle::SolvedZebraPuzzle, c::Clue; <kwargs>)
Implementation of the `check` interface for `ZebraPuzzle` that includes a clue validity check against the solution table.

See also [`check_valid`](@ref)

# Keyword Arguments
Keyword arguments control which of the checks are controlled for the clue.
- `duplicates=true` -- clue is not already included in the puzzle?
- `valid=true` --  clue is not in contradiction with the puzzle clues?
- `types=true` --  clue has valid attribute types for the puzzle?
- `variants=true` -- clue has valid attribute variants ("names") for the puzzle?
- `implied=true` -- clue is not implied by the clues in the puzzle?
- `minimal=true` -- clue is needed for the solution? I.e. current clues do not suffice for getting the full solution.
"""
function check(
    z::UnsolvedZebraPuzzle,
    c::Clue;
    duplicates=true,
    valid=true,
    types=true,
    variants=true,
    implied=true,
    minimal=true,
)
    attrs = attributes(c)
    exprs = AttributeExprs(z)
    types && foreach(p -> check_attrtype(z, p), attrs)
    variants && foreach(p -> check_attrvariant(z, p), attrs)
    valid && check_valid(z, c, exprs)
    duplicates && check_duplicate(z, c)
    minimal && check_minimal(z, c, exprs)
    implied && check_implied(z, c, exprs)

    return true
end

"""
    issolved(puzzle::UnsolvedZebraPuzzle) 
Check whether the puzzle was solved by `solve!` and has a solution without missing keys.

```jldoctest
julia> z = ZP.UNSOLVED_EINSTEINS_ZEBRA |> deepcopy;

julia> ZP.issolved(z)
false

julia> solve!(z);
ZebraPuzzles.SolvedZebraPuzzle{5, 5, NTuple{5, Union{Missing, ZebraPuzzles.Attribute}}} with 14 clues
┌──────────────────────────────────────────────────────────┐
│    Drink      House   Nationality   Pet        Smoke     │
├──────────────────────────────────────────────────────────┤
│    water      yellow   Norwegian    fox        Kools     │
├──────────────────────────────────────────────────────────┤
│     tea        blue    Ukrainian   horse   Chesterfields │
├──────────────────────────────────────────────────────────┤
│     milk       red    Englishman   snails    Old Gold    │
├──────────────────────────────────────────────────────────┤
│ orange juice  ivory    Spaniard     dog    Lucky Strike  │
├──────────────────────────────────────────────────────────┤
│    coffee     green    Japanese    zebra    Parliaments  │
└──────────────────────────────────────────────────────────┘

clues:
1) Nationality("Englishman") ⟹ House("red")
2) Nationality("Spaniard") ⟹ Pet("dog")
3) Drink("coffee") ⟹ House("green")
4) Nationality("Ukrainian") ⟹ Drink("tea")
5) Pos[House("green")] == Pos[House("ivory")] + 1
6) Smoke("Old Gold") ⟹ Pet("snails")
7) Smoke("Kools") ⟹ House("yellow")
8) Pos[Drink("milk")] == 3
9) Pos[Nationality("Norwegian")] == 1
10) abs(Pos[Smoke("Chesterfields")] - Pos[Pet("fox")]) == 1
11) abs(Pos[Smoke("Kools")] - Pos[Pet("horse")]) == 1
12) Smoke("Lucky Strike") ⟹ Drink("orange juice")
13) Nationality("Japanese") ⟹ Smoke("Parliaments")
14) abs(Pos[Nationality("Norwegian")] - Pos[House("blue")]) == 1

julia> ZP.issolved(z)
true
```
"""
function issolved(puzzle::UnsolvedZebraPuzzle)
    return all(all(ismissing.(col) .== false) for col in eachcol(puzzle.table))
end

"""
    UnsolvedPuzzle <: PuzzleError
Thrown when [`show_solution`](@ref) is called on an unsolved puzzle.
"""
struct UnsolvedPuzzle <: PuzzleError
    puzzle::Ref{<:UnsolvedPuzzle}
end
function Base.showerror(io::IO, e::UnsolvedPuzzle)
    return print(io, "UnsolvedPuzzle: puzzle $(e.puzzle[]) is not solved")
end

"""
    show_solution(puzzle::UnsolvedZebraPuzzle)
If the puzzle was solved by `solve!`, converts the puzzle to a [`SolvedZebraPuzzle`](@ref) shows it.
"""
function show_solution(puzzle::UnsolvedZebraPuzzle)
    if issolved(puzzle)
        show(stdout, MIME("text/plain"), ZebraPuzzle(puzzle.table, puzzle.clues))
    else
        throw(UnsolvedPuzzle(Ref(puzzle)))
    end
end

"""
    solve!(puzzle::UnsolvedZebraPuzzle)
Solve the zebra puzzle and fill in the solution table.

See also [`show_solution`](@ref)

```jldoctest
julia> puz = ZP.UNSOLVED_EINSTEINS_ZEBRA |> deepcopy;

julia> solve!(puz);
ZebraPuzzles.SolvedZebraPuzzle{5, 5, NTuple{5, Union{Missing, ZebraPuzzles.Attribute}}} with 14 clues
┌──────────────────────────────────────────────────────────┐
│    Drink      House   Nationality   Pet        Smoke     │
├──────────────────────────────────────────────────────────┤
│    water      yellow   Norwegian    fox        Kools     │
├──────────────────────────────────────────────────────────┤
│     tea        blue    Ukrainian   horse   Chesterfields │
├──────────────────────────────────────────────────────────┤
│     milk       red    Englishman   snails    Old Gold    │
├──────────────────────────────────────────────────────────┤
│ orange juice  ivory    Spaniard     dog    Lucky Strike  │
├──────────────────────────────────────────────────────────┤
│    coffee     green    Japanese    zebra    Parliaments  │
└──────────────────────────────────────────────────────────┘

clues:
1) Nationality("Englishman") ⟹ House("red")
2) Nationality("Spaniard") ⟹ Pet("dog")
3) Drink("coffee") ⟹ House("green")
4) Nationality("Ukrainian") ⟹ Drink("tea")
5) Pos[House("green")] == Pos[House("ivory")] + 1
6) Smoke("Old Gold") ⟹ Pet("snails")
7) Smoke("Kools") ⟹ House("yellow")
8) Pos[Drink("milk")] == 3
9) Pos[Nationality("Norwegian")] == 1
10) abs(Pos[Smoke("Chesterfields")] - Pos[Pet("fox")]) == 1
11) abs(Pos[Smoke("Kools")] - Pos[Pet("horse")]) == 1
12) Smoke("Lucky Strike") ⟹ Drink("orange juice")
13) Nationality("Japanese") ⟹ Smoke("Parliaments")
14) abs(Pos[Nationality("Norwegian")] - Pos[House("blue")]) == 1
```
"""
function solve!(puzzle::UnsolvedZebraPuzzle)
    exprs = AttributeExprs(puzzle)
    status = sat!(assertions(puzzle, exprs))
    if status != :SAT
        error(lazy"Failed to find the solution. Got `$status` from the solver.")
    end
    foreach(attributes(puzzle)) do a
        puzzle.table[value(exprs[a]), col(a)] = a
    end
    show_solution(puzzle)
    return puzzle
end

"""
    fill_clues!(puzzle::ZebraPuzzle)
Add random clues until the puzzle has a minimal set and ensures a unique solution.

```julia-repl
julia> z = ZebraPuzzle(
           Drink => ("coffee", "tea"),
           Smoke => ("Old Gold", "Chesterfields"), 
           House => ("green", "red")
       );

julia> ZP.fill_clues!(z)
UnsolvedZebraPuzzle{2, 3, Tuple{Drink, Smoke, House}} with 3 clues
┌────────────────────────────────┐
│ Drink        coffee, tea       │
├────────────────────────────────┤
│ Smoke  Old Gold, Chesterfields │
├────────────────────────────────┤
│ House        green, red        │
└────────────────────────────────┘

clues:
1) Pos[Drink("coffee")] > Pos[Drink("tea")]
2) Pos[House("green")] == 2
3) Drink("tea") ⟹ ¬Smoke("Chesterfields")
```
"""
function fill_clues!(puzzle::ZebraPuzzle)
    while true
        try
            add_clue!(puzzle)
        catch e
            if e isa MinimalityViolation
                return puzzle
                break
            end
        end
    end
end

export solve!, fill_clues!
