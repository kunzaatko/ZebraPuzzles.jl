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

Spaces are dropped and non-ASCII characters are escaped to their hexadecimal code points (`uXXXX`)
so that puzzles with e.g. Unicode attribute variants keep valid SMT-LIB symbols.
"""
function id(a::Attribute)::String
    name = string(typeof(a)) * "_"
    for c in string(a)
        c == ' ' && continue
        name *= isascii(c) ? string(c) : "u" * string(UInt32(c); base=16, pad=4)
    end
    return name
end

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
include("attributes/job.jl")
include("attributes/hobby.jl")
include("attributes/food.jl")
include("attributes/favourite-colour.jl")
include("attributes/destination.jl")
include("attributes/age.jl")
include("attributes/month.jl")
include("attributes/car.jl")

"""
    Subject
The attribute types that can name the positioned entities of a puzzle: they drive the riddle
introduction ([`introductionstring`](@ref)), the verbs and nouns of positional clue phrases
([`position_verb`](@ref), [`position_noun`](@ref)) and can be the main attribute of randomly
generated puzzles.
"""
const Subject = Union{House,Person,Car}
pluralnoun(::Type{House}) = "houses"
pluralnoun(::Type{Person}) = "people"
pluralnoun(::Type{Car}) = "cars"

"""
    is_location(T::Type{<:Attribute})
Whether attributes of type `T` are _location-like_. In clue phrases a location-like attribute is
swapped into the predicate position (e.g. "The Spaniard owns the red car" instead of "The red car
is owned by the Spaniard"), because location-like attributes read as places that the other
attributes belong to.
"""
is_location(::Type{<:Attribute}) = false
is_location(::Type{House}) = true
is_location(::Type{Car}) = true

"""
    position_verb(T::Type{<:Attribute})
    position_verb(T::Type{<:Attribute}, story::Type{<:Subject})
The verb that an attribute of type `T` takes in positional clue phrases: subjects "live" at a
position in the classic house story, while the car story and story-neutral renderings use "is"
(see [`is_location`](@ref)).
"""
position_verb(::Type{<:Attribute}) = "lives"
position_verb(::Type{House}) = "is"
position_verb(::Type{Car}) = "is"
position_verb(T::Type{<:Attribute}, story::Type{<:Subject}) =
    story == House ? position_verb(T) : "is"

"""
    position_noun(T::Type{<:Attribute})
    position_noun(T::Type{<:Attribute}, story::Type{<:Subject})
The noun for the place that an attribute of type `T` occupies in positional clue phrases phrased
for the story `story`: the story-neutral "position", "house" in the classic house story (except
for `House` itself, which is at a "position") and "parking spot" in the car story.
"""
position_noun(::Type{<:Attribute}) = "house"
position_noun(::Type{House}) = "position"
position_noun(::Type{Car}) = "parking spot"
position_noun(T::Type{<:Attribute}, story::Type{<:Subject}) =
    story == Car ? "parking spot" : story == House ? position_noun(T) : "position"

"""
    person_centric(T::Type{<:Attribute})
Whether attributes of type `T` describe person-like subjects only: the random question generator
does not pair them with [`Subject`](@ref) subjects, whose questions would read nonsensically (e.g.
the job of a house).
"""
person_centric(::Type{<:Attribute}) = false
person_centric(::Type{Job}) = true
person_centric(::Type{Hobby}) = true
person_centric(::Type{Food}) = true
person_centric(::Type{FavouriteColour}) = true
person_centric(::Type{Destination}) = true
person_centric(::Type{Age}) = true
person_centric(::Type{Month}) = true
# TODO: `introductionstring` should have the word form of the number. <21-06-25> 
"""
    introductionstring(s::Type{<:Subject}, K::Int)
The introduction sentence of a riddle about `K` subjects of type `s`, e.g. `"There are 5 houses."`.
"""
introductionstring(s::Type{<:Subject}, K::Int) = "There are $K $(pluralnoun(s))."

export Position,
    Hat,
    House,
    Nationality,
    Drink,
    Pet,
    Smoke,
    Person,
    Drive,
    Job,
    Hobby,
    Food,
    FavouriteColour,
    Destination,
    Age,
    Month,
    Car
