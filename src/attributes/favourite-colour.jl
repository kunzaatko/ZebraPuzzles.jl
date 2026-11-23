"""
    FavouriteColour <: Attribute
The favourite colour of the subject.

This is a distinct relation from the [`House`](@ref) colour: a puzzle can contain both.
"""
struct FavouriteColour <: Attribute
    colour::String
end
function attributed(d::FavouriteColour)
    return [
        "the $character whose favourite colour is $(string(d))" for
        character in ["man", "person", "individual"]
    ]
end
attribution(d::FavouriteColour) = ["has $(d.colour) as their favourite colour"]
negation(d::FavouriteColour) = ["does not have $(d.colour) as their favourite colour"]
function question(::Type{FavouriteColour}, who::String)
    return [
        "What is the favourite colour of $who?",
        "Which colour does $who like the most?",
    ]
end

function variants(::Type{FavouriteColour})
    return ["red", "blue", "green", "pink", "purple", "lilac", "white", "yellow"]
end
