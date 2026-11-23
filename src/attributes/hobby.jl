"""
    Hobby <: Attribute
The hobby that the subject practises.
"""
struct Hobby <: Attribute
    activity::String
end
function attributed(d::Hobby)
    return [
        "the $character whose hobby is $(string(d))" for
        character in ["man", "person", "individual"]
    ]
end
attribution(d::Hobby) = ["has $(d.activity) as their hobby"]
negation(d::Hobby) = ["does not have $(d.activity) as their hobby"]
function question(::Type{Hobby}, who::String)
    return ["What is the hobby of $who?"]
end

function variants(::Type{Hobby})
    return [
        "gardening",
        "painting",
        "reading",
        "cooking",
        "sewing",
        "drawing",
        "singing",
        "woodworking",
    ]
end
