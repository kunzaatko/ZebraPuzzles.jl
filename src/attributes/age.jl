"""
    Age <: Attribute
The age of the subject in years.

!!! warning
    Only categorical (equality) clues are supported. There are no order-aware clue types yet: a
    positional clue about e.g. "the 40-year-old" constrains the line-up position of the subject, not
    age comparisons between subjects.
"""
struct Age <: Attribute
    years::String
end
function attributed(d::Age)
    return [
        "the $(d.years)-year-old person",
        [
            "the $character who is $(d.years) years old" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Age) = ["is $(d.years) years old"]
negation(d::Age) = ["is not $(d.years) years old"]
function question(::Type{Age}, who::String)
    return ["How old is $who?"]
end

function variants(::Type{Age})
    return ["25", "30", "35", "40", "45", "50", "55", "60"]
end
