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
    # location-like attributes are swapped into the predicate position so that phrases such as
    # "The Spaniard lives in the red house" and "Martin owns the red car" are produced regardless
    # of the clue argument order.
    if is_location(typeof(a))
        b, a = a, b
    end
    return titlecase(rand(attributed(a))) * " " * rand(attribution(b)) * "."
end
function phrase(c::NegativeClue)
    a, b = attributes(c)
    if is_location(typeof(a))
        b, a = a, b
    end
    return titlecase(rand(attributed(a))) * " " * rand(negation(b)) * "."
end

# The green house | IS IMMEDIATELY TO THE RIGHT OF | the ivory house.
phrase(d::Direction) = d_left == d ? "to the left" : "to the right"
function phrase(c::ExactRelativePosition{<:Any,<:Any,D}, story::Type{<:Subject}) where {D}
    a, b = attributes(c)
    verb = position_verb(typeof(a), story)
    # NOTE: the `attributed_position` flavor is specific to the house story; other stories refer to
    # the other attribute directly <23-11-25>
    attributed_string =
        a isa House ? rand(attributed_position(b)) : rand(attributed(b))
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
phrase(c::ExactRelativePosition{<:Any,<:Any,D}) where {D} = phrase(c, House)

# Milk | IS DRUNK IN | the middle house.
# The Norwegian | LIVES IN | the first house.
function phrase(c::AbsolutePosition, story::Type{<:Subject})
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
    verb, noun = (
        position_verb(typeof(c.a), story),
        position_noun(typeof(c.a), story),
    )
    return titlecase(rand(attributed(c.a))) *
           " $verb in the " *
           position_phrase(c.p, c.K) *
           " $noun."
end
phrase(c::AbsolutePosition) = phrase(c, House)

# The man who smokes Chesterfields | LIVES IN THE HOUSE NEXT | to the man with the fox.
# Kools | ARE SMOKED IN THE HOUSE NEXT TO | the house where the horse is kept.
# The Norwegian | LIVES NEXT TO | the blue house.
function phrase(c::AbsoluteDistance, story::Type{<:Subject})
    verb = position_verb(typeof(c.a), story)
    position_phrase = c.d == 1 ? "immediately next to " : "$(c.d) places from "
    attributed_string =
        c.a isa House ? rand(attributed_position(c.b)) : rand(attributed(c.b))
    return titlecase(rand(attributed(c.a))) *
           " $verb $position_phrase" *
           attributed_string *
           "."
end
phrase(c::AbsoluteDistance) = phrase(c, House)

function phrase(c::DirectionClue{<:Any,<:Any,D}, story::Type{<:Subject}) where {D}
    verb = position_verb(typeof(c.a), story)
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
phrase(c::DirectionClue{<:Any,<:Any,D}) where {D} = phrase(c, House)

# NOTE: questions that pair subject-like attribute types with each other (e.g. asking for the name
# of a house) are avoided by the random question generator, but hand-constructed pairs remain the
# user's responsibility and can still read oddly <23-11-25>
function phrase(q::AttributeQuestion{A}) where {A}
    return titlecase(rand(question(A, rand(attributed(q.subject)))))
end

# At which position does | the Englishman | LIVE ?
function phrase(q::PositionQuestion, story::Type{<:Subject})
    who = rand(attributed(q.subject))
    return rand(position_questions(typeof(q.subject), who, story))
end
phrase(q::PositionQuestion) = phrase(q, House)

"""
    position_questions(T::Type{<:Attribute}, who::String)
    position_questions(T::Type{<:Attribute}, who::String, story::Type{<:Subject})
The question templates that ask for the position of `who`, an attribute of type `T`. Location-like
attribute types (see [`is_location`](@ref)) "are" at a position instead of "living" in it, and
every attribute type takes the story-neutral "is" wording outside of the house story.
"""
position_questions(::Type{<:Attribute}, who::String) =
    ("At which position is $who?", "What is the position of $(who)?")
position_questions(::Type{Person}, who::String) =
    ("At which position does $who live?", "What is the position of $(who)?")
position_questions(T::Type{<:Attribute}, who::String, story::Type{<:Subject}) =
    story == House ? position_questions(T, who) :
    ("At which position is $who?", "What is the position of $(who)?")

# Story-agnostic fallbacks for clue and question types whose phrasing does not depend on the story
phrase(c::Clue, ::Type{<:Subject}) = phrase(c)
phrase(q::Question, ::Type{<:Subject}) = phrase(q)
