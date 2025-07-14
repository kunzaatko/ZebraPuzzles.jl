"""
    House <: Attribute
The house description that the subject lives in.

In most puzzles given by colour.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct House <: Attribute
    description::String
end
attributed(d::House) = ["the $(string(d)) house"]
attributed_position(d::House) = attributed(d)
attribution(h::House) = ["lives in the $(h.description) house"]
negation(h::House) = ["does not live in the $(h.description) house"]

function question(::Type{House}, who::String)
    return [("$a colour does house of $who have?" for a in ["which", "what"])...]
end

variants(::Type{House}) = ["red", "green", "blue", "yellow", "white", "black", "ivory"]
