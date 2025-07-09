"""
    Smoke <: Attribute
Brand of cigarettes that the subject smokes.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct Smoke <: Attribute
    brand::String
end

function attributed(d::Smoke)
    return [
        "the smoker of $(string(d))",
        [
            "the $character who smokes $(string(d))" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Smoke) = ["$a $(d.brand)" for a in ["smokes", "is a smoker of"]]
negation(d::Smoke) = ["$a $(d.brand)" for a in ["does not smoke", "is not a smoker of"]]

function question(::Type{Smoke}, who::String)
    return [
        ("$a cigarette brand does $who prefer?" for a in ["which", "what"])...,
        "what does $who smoke?",
    ]
end

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
