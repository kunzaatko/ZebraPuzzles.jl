"""
    Food <: Attribute
The food that the subject eats.
"""
struct Food <: Attribute
    dish::String
end
function attributed(d::Food)
    return [
        "the eater of $(string(d))",
        [
            "the $character who eats $(string(d))" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Food) = ["$a $(d.dish)" for a in ["eats", "is an eater of"]]
negation(d::Food) = ["$a $(d.dish)" for a in ["does not eat", "is not an eater of"]]
function question(::Type{Food}, who::String)
    return [
        ("$a food does $who eat?" for a in ["Which", "What"])...,
        "What does $who eat?",
    ]
end

function variants(::Type{Food})
    return ["pizza", "sushi", "pasta", "salad", "steak", "tacos", "burgers", "soup"]
end
