"""
    Month <: Attribute
The month of the subject's birthday.

!!! warning
    Only categorical (equality) clues are supported. There are no order-aware clue types yet: the
    order of the months of the year does not imply an age order between subjects, and a
    December-January wrap-around has no defined semantics.
"""
struct Month <: Attribute
    name::String
end
function attributed(d::Month)
    return [
        "the $character born in $(string(d))" for
        character in ["man", "person", "individual"]
    ]
end
attribution(d::Month) = ["was born in $(d.name)"]
negation(d::Month) = ["was not born in $(d.name)"]
function question(::Type{Month}, who::String)
    return ["In which month was $who born?", "When was $who born?"]
end

function variants(::Type{Month})
    return [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ]
end
