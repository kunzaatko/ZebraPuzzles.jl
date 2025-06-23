# TODO: Add a print styled function that discerns the subject and the attribute with colours and leaves the fillers
# non-colourful <30-05-25> 

abstract type Clue end

"""
    attributes(c::Clue) 
Retrieve the attributes that are involved in a clue.

This is mainly for checking for the correctness of the clue.

```jldoctest
julia> ZP.EINSTEINS_ZEBRA.clues[1] |> string |> print
Nationality("Englishman") ⟹ House("red")

julia> attributes(ZP.EINSTEINS_ZEBRA.clues[1])
(Nationality("Englishman"), House("red"))
```
"""
@interface attributes(c::Clue)
@interface phrase(c::Clue)

include("clues/position-clue.jl")
include("clues/direct-clue.jl")

const PairClue = Union{<:DirectClue,<:RelativePosition}
Base.Pair(c::PairClue) = c.a => c.b

export PositiveClue, NegativeClue, ExactRelativePosition, AbsolutePosition, AbsoluteDistance, DirectionClue, Clue
