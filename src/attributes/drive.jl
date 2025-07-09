"""
    Drive <: Attribute
What does the subject drive.
"""
struct Drive <: Attribute
    what::String
end
function attributed(d::Drive)
    return [
        "the driver of the $(string(d))",
        [
            "the $character who drives the $(string(d))" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Drive) = ["$a the $(d.what)" for a in ["drives", "is the driver of"]]
function negation(d::Drive)
    return ["$a the $(d.what)" for a in ["does not drive", "is not the driver of"]]
end
function question(::Type{Drive}, who::String)
    return [
        ("$a vehicle does $who drive?" for a in ["which", "what"])...,
        "What does $who drive?",
    ]
end

function variants(::Type{Drive})
    return ["car", "bus", "motorcycle", "bicycle", "train", "Ferrari", "scooter", "EV"]
end
