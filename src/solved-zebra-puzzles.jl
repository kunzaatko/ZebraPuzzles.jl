"""
    SolvedZebraPuzzle{K,N,Attrs} <: ZebraPuzzle{K,N,Attrs}
A [`ZebraPuzzle`](@ref) that is created with a known solution table.
"""
mutable struct SolvedZebraPuzzle{K,N,Attrs} <: ZebraPuzzle{K,N,Attrs}
    table::DataFrame
    clues::Vector{Clue}
end

function indexof(z::SolvedZebraPuzzle, a::Type{<:Attribute})
    return findfirst(==(string(col(a))), names(z.table))
end
function indexof(z::SolvedZebraPuzzle, a::Attribute)
    return (findfirst(==(a), z.table[!, col(a)]), indexof(z, typeof(a)))
end

# NOTE: Construction of Tuple{A,Vararg{A}} is used for assuring bounded function argument types. See `Test.detect_unbound_args` <10-06-25> 
const Attributes = Tuple{Attribute,Vararg{Attribute}}

"""
    ZebraPuzzle(subject_attrs...)::SolvedZebraPuzzle
Construct a solved zebra puzzle with the solution table `zpairs` with no clues. Clues can be later added by
[`add_clues!`](@ref).

```jldoctest
julia> ZebraPuzzle(
           (Person("Martin"), Hat("fedora"), Nationality("czech")),
           (Person("David"), Hat("beanie"), Nationality("spanish")),
           (Person("Lucas"), Hat("cap"), Nationality("german")),
           (Person("Lucy"), Hat("baret"), Nationality("american"))
       )
ZebraPuzzles.SolvedZebraPuzzle{4, 3, Tuple{Person, Hat, Nationality}} with no clues
┌─────────────────────────────┐
│ Nationality   Hat    Person │
├─────────────────────────────┤
│    czech     fedora  Martin │
├─────────────────────────────┤
│   spanish    beanie  David  │
├─────────────────────────────┤
│   german      cap    Lucas  │
├─────────────────────────────┤
│  american    baret    Lucy  │
└─────────────────────────────┘
```
"""
function ZebraPuzzle(z1::Attrs, zns::Vararg{Attrs}) where {Attrs<:Attributes}
    zebra = (z1, zns...)
    K = length(zebra)
    N = length(z1)
    cols = [Dict(col(a) => a for a in z) for z in zebra]
    df = DataFrame(Tables.dictcolumntable(cols))
    @assert all(allunique(string(a) for a in attrs) for attrs in eachcol(df)) "All attributes of a single type must be unique"
    return SolvedZebraPuzzle{K,N,Attrs}(df, Clue[])
end

function ZebraPuzzle(solution_table::DataFrame, clues::Vector{Clue})
    K, N = nrow(solution_table), ncol(solution_table)
    @assert all(allunique(string(a) for a in attrs) for attrs in eachcol(solution_table)) "All attributes of a single type must be unique"
    Attrs = Tuple{(eltype(a) for a in eachcol(solution_table))...}
    return SolvedZebraPuzzle{K,N,Attrs}(solution_table, clues)
end

function attributes(z::SolvedZebraPuzzle)
    return vcat(eachcol(z.table)...)
end
function attributes(z::SolvedZebraPuzzle, s::Type{<:Attribute})
    check_attrtype(z, s)
    return z.table[!, col(s)]
end

"""
    attributes(puzzle, s::Attribute)
    attributes(puzzle, s::Not{Attribute})
Get the _other_ attributes of the puzzle that are linked to the attribute `s`

```jldoctest
julia> attributes(ZP.EINSTEINS_ZEBRA, Smoke("Old Gold"))
4-element Vector{ZebraPuzzles.Attribute}:
 House("red")
 Nationality("Englishman")
 Drink("milk")
 Pet("snails")

julia> attributes(ZP.EINSTEINS_ZEBRA, Not(House("red")))
20-element Vector{ZebraPuzzles.Attribute}:
 House("yellow")
 House("blue")
 House("ivory")
 House("green")
 Nationality("Norwegian")
 Nationality("Ukrainian")
 Nationality("Spaniard")
 Nationality("Japanese")
 Smoke("Kools")
 Smoke("Chesterfields")
 Smoke("Lucky Strike")
 Smoke("Parliaments")
 Drink("water")
 Drink("tea")
 Drink("orange juice")
 Drink("coffee")
 Pet("fox")
 Pet("horse")
 Pet("dog")
 Pet("zebra")
```
"""
function attributes(z::SolvedZebraPuzzle, s::Attribute)
    check_attrtype(z, s)
    check_attrvariant(z, s)
    subject = filter(col(s) => ==(s), z.table)
    return [first(attr) for attr in eachcol(subject) if first(attr) != s]
end
function attributes(z::SolvedZebraPuzzle, s::Not{<:Attribute})
    check_attrtype(z, s.skip)
    subject = filter(col(s.skip) => !=(s.skip), z.table)
    nrow(subject) >= 1 || throw(
        ArgumentError(
            "No attributes matching Not($s) found in the puzzle. . Puzzle attributes are `$(map(string, attributes(z, typeof(s))))`",
        ),
    )
    return stack(eachcol(subject))[:]
end

function Base.show(io::IO, ::MIME"text/plain", z::SolvedZebraPuzzle)
    Base.showarg(io, z, true)
    if isempty(z.clues)
        print(io, " with no clues\n")
    else
        print(io, " with $(length(z.clues)) clues\n")
    end
    @mock pretty_table(
        io,
        z.table;
        alignment=:c,
        hlines=:all,
        vlines=[0, :end],
        header_crayon=crayon"yellow bold",
        show_subheader=false,
        formatters=(attr, _, _) -> string(attr),
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
    InvalidClue <: ClueError
Thrown when a rule is in conflict with the puzzle solution table of the `SolvedZebraPuzzle`
"""
struct InvalidClue <: ClueError
    c::Clue
    puzzle::Ref{<:SolvedZebraPuzzle}
end
function Base.showerror(io::IO, e::InvalidClue)
    print(
        io,
        "InvalidClue: `$(nameof(typeof(e.c)))` clue $(string(e.c)) is not satisfied in the puzzle.",
    )
    if e.c isa DirectClue
        print(io, " ", cluehelp(e.puzzle[], e.c), ".")
    end
end

function cluehelp(::SolvedZebraPuzzle, c::DirectClue)
    return "Truth value of the clue is `$(c isa PositiveClue)` which is in conflict with the puzzle"
end
function cluehelp(z::SolvedZebraPuzzle, c::AbsolutePosition)
    return "True position of attribute $(c.a) is $(position(z,c.a))"
end
function cluehelp(z::SolvedZebraPuzzle, c::AbsoluteDistance)
    return "True distance of attribute $(c.a) and $(c.b) is $(distance(z,c.a, c.b))"
end
function cluehelp(z::SolvedZebraPuzzle, c::DirectionClue{<:Any,<:Any,D}) where {D}
    pa, pb = position(z, c.a), position(z, c.b)
    return "$(pa != pb ? (D == d_right ? "$(c.a) is to the left of $(c.b)" : "$(c.a) is to the left of $(c.b)") : "$(c.a) and $(c.b) have the same position") which in conflict with the clue"
end
function cluehelp(z::SolvedZebraPuzzle, c::ExactRelativePosition)
    pa, pb = position(z, c.a), position(z, c.b)
    return "$(pa - pb) == $(c.r) which in conflict with the clue"
end

"""
    check_valid(z::SolvedZebraPuzzle, c::Clue)
Validate the truth of the clue against the solution table of the puzzle.

!!! warning
    It does not checked against the clues included in the puzzle.
"""
function check_valid(z::SolvedZebraPuzzle, c::DirectClue)
    return (c.b in attributes(z, c.a)) == (c isa PositiveClue) ||
           throw(InvalidClue(c, Ref(z)))
end
function check_valid(z::SolvedZebraPuzzle, c::AbsolutePosition)
    return (z.table[c.p, col(c.a)] == c.a) || throw(InvalidClue(c, Ref(z)))
end
function check_valid(z::SolvedZebraPuzzle, c::AbsoluteDistance)
    return abs(distance(z, c.a, c.b)) == c.d || throw(InvalidClue(c, Ref(z)))
end
function check_valid(z::SolvedZebraPuzzle, c::DirectionClue{<:Any,<:Any,D}) where {D}
    pa, pb = position(z, c.a), position(z, c.b)
    return (pa > pb) == (D == d_right) && pa != pb || throw(InvalidClue(c, Ref(z)))
end
function check_valid(
    z::SolvedZebraPuzzle, c::ExactRelativePosition{<:Any,<:Any,D}
) where {D}
    pa, pb = position(z, c.a), position(z, c.b)
    return (pa - pb) == (D == d_right ? c.r : -c.r) || throw(InvalidClue(c, Ref(z)))
end

"""
    check(puzzle::SolvedZebraPuzzle, c::Clue; <kwargs>)
Implementation of the `check` interface for `ZebraPuzzle` that includes a clue validity check against the solution table.

See also [`check_valid`](@ref)

# Keyword Arguments
Keyword arguments control which of the checks are controlled for the clue.
- `duplicates=true` -- clue is not already included in the puzzle?
- `valid=true` --  clue is valid under the solution table?
- `types=true` --  clue has valid attribute types for the puzzle?
- `variants=true` -- clue has valid attribute variants ("names") for the puzzle?
- `implied=true` -- clue is not implied by the clues in the puzzle?
- `minimal=true` -- clue is needed for the solution? I.e. current clues do not suffice for getting the full solution.
"""
function check(
    z::SolvedZebraPuzzle,
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
    valid && check_valid(z, c)
    duplicates && check_duplicate(z, c)
    minimal && check_minimal(z, c, exprs)
    implied && check_implied(z, c, exprs)

    return true
end
