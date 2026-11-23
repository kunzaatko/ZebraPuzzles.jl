"""
    Destination <: Attribute
The travel destination that the subject plans to visit.

This is a distinct relation from the [`Nationality`](@ref) of a subject.
"""
struct Destination <: Attribute
    country::String
end
function attributed(d::Destination)
    return [
        "the $character who plans to visit $(string(d))" for
        character in ["man", "person", "individual"]
    ]
end
attribution(d::Destination) = ["plans to visit $(d.country)"]
negation(d::Destination) = ["does not plan to visit $(d.country)"]
function question(::Type{Destination}, who::String)
    return ["Where does $who plan to travel?", "Which country does $who plan to visit?"]
end

function variants(::Type{Destination})
    return ["Italy", "Egypt", "Mexico", "Peru", "China", "Australia", "Canada", "Maldives"]
end
