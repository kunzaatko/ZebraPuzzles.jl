using Random
import Base.string
"""
    Attribute
Represents a possible attribute of a subject of type `S`.

The type parameters determine the phrase that is used for the _clues_ and the _subject strings_ used in the puzzle. `S` is the type of the subject that the Attribute can describe (`Person`, `House`, etc.)
"""
abstract type Attribute end
Base.string(a::A) where {A<:Attribute} = getfield(a, 1)

"""
    id(a::Attribute)
`Satisfiability` variable name.
"""
id(a::Attribute)::String = string(typeof(a)) * "_" * replace(string(a), ' ' => "")

"""
    col(S::Type{<:Attribute})
    col(s::Attribute)
Get the name of the column of attribute `s` / of the type `S` in the solution table.

```jldoctest
julia> ZP.col(House("red"))
:House

julia> ZP.col(House)
:House
```
"""
col(s::Type{<:Attribute}) = nameof(s)
col(s::Attribute) = col(typeof(s))

# NOTE: Attributes are defined by their variant strings
parse(S::Type{<:Attribute}, s) = S(s)

"""
    variants(A::Type{<:Attribute})
Returns known variants of the attribute type `A`.

These are used for generating random puzzles.
"""
@interface variants(A::Type{<:Attribute})
function Random.rand(A::Type{<:Attribute}, N::Int)
    return A.(first(shuffle(variants(A::Type{<:Attribute})), N))
end

function attributed_position(a::Attribute)
    return ["the house where $(string(a)) lives" for a in attributed(a)]
end
include("attributes/smoke.jl")
include("attributes/nationality.jl")
include("attributes/house.jl")
include("attributes/person.jl")
include("attributes/hat.jl")
include("attributes/pet.jl")
include("attributes/drink.jl")
include("attributes/drive.jl")

const Subject = Union{House,Person}
pluralnoun(::Type{House}) = "houses"
pluralnoun(::Type{Person}) = "people"
# TODO: `introductionstring` should have the word form of the number. <21-06-25> 
introductionstring(s::Type{<:Subject}, K::Int) = "There are $K $(pluralnoun(s))."

export Position, Hat, House, Nationality, Drink, Pet, Smoke, Person, Drive
