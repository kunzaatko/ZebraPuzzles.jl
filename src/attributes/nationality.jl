"""
    Nationality <: Attribute
Nationality of the subject.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct Nationality <: Attribute
    name::String
end

attributed(d::Nationality) = [
    "the $(string(d))",
]
attribution(d::Nationality) = ["is a $(d.name)"]
negation(d::Nationality) = ["is not a $(d.name)"]

function variants(::Type{Nationality})
    return [
        "Norwegian",
        "Ukrainian",
        "Englishman",
        "Spaniard",
        "Japanese",
        "Czech",
        "Russian",
        "American",
        "German",
        "Frenchman",
        "Italian",
        "Pole",
        "Scot",
        "Irishman",
        "Dutchman",
    ]
end
