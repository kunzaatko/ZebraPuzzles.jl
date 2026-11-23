"""
    Car <: Attribute
The car that the subject owns. A line-up of cars can also be the positioned [`Subject`](@ref) of a
puzzle (like a row of parked cars), see [`position_verb`](@ref) and [`position_noun`](@ref).
"""
struct Car <: Attribute
    description::String
end
attributed(d::Car) = ["the $(string(d)) car"]
attribution(d::Car) = ["owns the $(string(d)) car"]
negation(d::Car) = ["does not own the $(string(d)) car"]
function question(::Type{Car}, who::String)
    return ["Which car does $who own?", "What car does $who own?"]
end

function variants(::Type{Car})
    return ["red", "blue", "green", "black", "white", "silver", "yellow", "grey"]
end
