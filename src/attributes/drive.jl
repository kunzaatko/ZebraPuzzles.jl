"""
    Drive <: Attribute
What does the subject drive.
"""
struct Drive <: Attribute
    what::String
end
attributed(d::Drive) = [
    "the driver of the $(string(d))",
    ["the $character who drives the $(string(d))" for character in ["man", "person", "individual"]]...
]
attribution(d::Drive) = ["$a the $(d.what)" for a in ["drives", "is the driver of"]]
negation(d::Drive) = ["$a the $(d.what)" for a in ["does not drive", "is not the driver of"]]

variants(::Type{Drive}) = ["car", "bus", "motorcycle", "bicycle", "train", "Ferrari", "scooter", "EV"]
