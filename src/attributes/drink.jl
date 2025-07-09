"""
    Drink <: Attribute
Preferred drink of the subject.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct Drink <: Attribute
    type::String
end
function attributed(d::Drink)
    return [
        "the drinker of $(string(d))",
        [
            "the $character who drinks $(string(d))" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Drink) = ["$a $(d.type)" for a in ["drinks", "is a drinker of"]]
negation(d::Drink) = ["$a $(d.type)" for a in ["does not drink", "is not a drinker of"]]
function question(::Type{Drink}, who::String)
    return [
        ("$a drink does $who prefer?" for a in ["which", "what"])...,
        "What does $who drink?",
    ]
end

variants(::Type{Drink}) = ["coffee", "tea", "water", "orange juice", "milk", "beer"]
