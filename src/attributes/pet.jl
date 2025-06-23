"""
    Pet <: Attribute
Which pet does the subject own.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct Pet <: Attribute
    animal::String
end

attributed(d::Pet) = [
    "the owner of the $(string(d))",
    ["the $character who owns the $(string(d))" for character in ["man", "person", "individual"]]...
]
attribution(d::Pet) = ["$a the $(d.animal)" for a in ["owns", "is the owner of"]]
negation(d::Pet) = ["$a the $(d.animal)" for a in ["does not own", "is not the owner of"]]

function variants(::Type{Pet})
    return [
        "dog",
        "cat",
        "bird",
        "fish",
        "hamster",
        "horse",
        "rabbit",
        "turtle",
        "snake",
        "lizard",
        "ferret",
        "guinea pig",
        "parrot",
        "gecko",
        "fox",
        "zebra",
        "snails",
        "hedgehog",
        "chinchilla",
    ]
end
