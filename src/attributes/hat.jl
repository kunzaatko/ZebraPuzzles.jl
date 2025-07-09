"""
    Hat <: Attribute
Hat that the subject wears.
"""
struct Hat <: Attribute
    type::String
end
function attributed(d::Hat)
    return [
        "the wearer of the $(string(d))",
        [
            "the $character who wears the $(string(d))" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Hat) = ["$a the $(d.type)" for a in ["wears", "is the wearer of"]]
negation(d::Hat) = ["$a the $(d.type)" for a in ["does not wear", "is not the wearer of"]]

function question(::Type{Hat}, who::String)
    return [
        ("$a hat does $who wear?" for a in ["which", "what"])..., "What does $who wear?"
    ]
end

function variants(::Type{Hat})
    return [
        "sombrero",
        "trapper hat",
        "cowboy hat",
        "baseball cap",
        "fedora",
        "beret",
        "beanie",
        "top hat",
    ]
end
