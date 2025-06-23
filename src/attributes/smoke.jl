"""
    Smoke <: Attribute
Brand of cigarettes that the subject smokes.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct Smoke <: Attribute
    brand::String
end

attributed(d::Smoke) = [
    "the smoker of $(string(d))",
    ["the $character who smokes $(string(d))" for character in ["man", "person", "individual"]]...
]
attribution(d::Smoke) = ["$a $(d.brand)" for a in ["smokes", "is a smoker of"]]
negation(d::Smoke) = ["$a $(d.brand)" for a in ["does not smoke", "is not a smoker of"]]

function variants(::Type{Smoke})
    return [
        "Kools",
        "Chesterfields",
        "Old Gold",
        "Lucky Strike",
        "Parliaments",
        "Marlboro",
        "Golden Virginia",
        "Pueblo",
    ]
end
