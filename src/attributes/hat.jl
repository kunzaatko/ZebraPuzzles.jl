"""
    Hat <: Attribute
Hat that the subject wears.
"""
struct Hat <: Attribute
    type::String
end
attributed(d::Hat) = [
    "the wearer of the $(string(d))",
    ["the $character who wears the $(string(d))" for character in ["man", "person", "individual"]]...
]
attribution(d::Hat) = ["$a the $(d.type)" for a in ["wears", "is the wearer of"]]
negation(d::Hat) = ["$a the $(d.type)" for a in ["does not wear", "is not the wearer of"]]

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

