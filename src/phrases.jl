"""
    titlecase(s::String)
Upper-case the first letter of the string

```jldoctest
julia> ZP.titlecase("red house")
"Red house"

julia> ZP.titlecase("apple")
"Apple"
```
"""
function titlecase(s::String)
    return uppercase(s[1]) * s[2:end]
end

# The Englishman | LIVES IN | the red house.
# The Spaniard | OWNS | the dog.
# Coffee | IS DRUNK IN | the green house.
# The Ukrainian | DRINKS | tea.
# The Old Gold smoker | OWNS | snails.
# Kools | ARE SMOKED IN | the yellow house.
# The Lucky Strike smoker | DRINKS | orange juice.
# The Japanese | SMOKES | Parliaments.
function phrase(c::PositiveClue)
    a, b = attributes(c)
    if a isa House
        b, a = a, b
    end
    return titlecase(rand(attributed(a))) * " " * rand(attribution(b)) * "."
end
function phrase(c::NegativeClue)
    a, b = attributes(c)
    if a isa House
        b, a = a, b
    end
    return titlecase(rand(attributed(a))) * " " * rand(negation(b)) * "."
end

# The green house | IS IMMEDIATELY TO THE RIGHT OF | the ivory house.
phrase(d::Direction) = d_left == d ? "to the left" : "to the right"
function phrase(c::ExactRelativePosition{<:Any,<:Any,D}) where {D}
    a, b = attributes(c)
    verb = a isa House ? "is" : "lives"
    attributed_string = a isa House ? rand(attributed_position(b)) : rand(attributed(b))
    position_phrase = if c.r == 1
        "$verb immediately $(phrase(D)) of"
    else
        "$verb $(abs(c.r)) places $(phrase(D)) from"
    end
    return titlecase(rand(attributed(a))) *
           " " *
           position_phrase *
           " " *
           attributed_string *
           "."
end

# Milk | IS DRUNK IN | the middle house.
# The Norwegian | LIVES IN | the first house.
function phrase(c::AbsolutePosition)
    position_phrase(p, K) = begin
        if !ismissing(K)
            2 * (p - 1) == (K - 1) && return "middle"
            p == K && return "last"
        end
        p == 1 && return "first"
        p == 2 && return "second"
        p == 3 && return "third"
        p == 4 && return "fourth"
        p == 5 && return "fifth"
        p >= 6 && return "$(p)th"
    end
    verb, noun = c.a isa House ? ("is", "position") : ("lives", "house")
    return titlecase(rand(attributed(c.a))) *
           " $verb in the " *
           position_phrase(c.p, c.K) *
           " $noun."
end

# The man who smokes Chesterfields | LIVES IN THE HOUSE NEXT | to the man with the fox.
# Kools | ARE SMOKED IN THE HOUSE NEXT TO | the house where the horse is kept.
# The Norwegian | LIVES NEXT TO | the blue house.
function phrase(c::AbsoluteDistance)
    verb = c.a isa House ? "is" : "lives"
    position_phrase = c.d == 1 ? "immediately next to " : "$(c.d) places from "
    attributed_string =
        c.a isa House ? rand(attributed_position(c.b)) : rand(attributed(c.b))
    return titlecase(rand(attributed(c.a))) *
           " $verb $position_phrase" *
           attributed_string *
           "."
end

function phrase(c::DirectionClue{<:Any,<:Any,D}) where {D}
    verb = c.a isa House ? "is" : "lives"
    attributed_phrase =
        c.a isa House ? rand(attributed_position(c.b)) : rand(attributed(c.b))
    return titlecase(rand(attributed(c.a))) *
           " " *
           verb *
           " " *
           phrase(D) *
           " of " *
           attributed_phrase *
           "."
end

function phrase(q::AttributeQuestion{A}) where {A}
    return titlecase(rand(question(A, rand(attributed(q.subject)))))
end

# At which position does | the Englishman | LIVE ?
function phrase(q::PositionQuestion)
    who = rand(attributed(q.subject))
    return rand(("At which position does $who live?", "What is the position of $(who)?"))
end
