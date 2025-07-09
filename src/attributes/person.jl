"""
    Person <: Attribute
The name of the subject.

See also [`EINSTEINS_ZEBRA`](@ref)
"""
struct Person <: Attribute
    name::String
end
isproper(::Type{Person}) = true

attributed(d::Person) = ["$(string(d))"]
attribution(d::Person) = ["is named $(d.name)"]
negation(d::Person) = ["is not named $(d.name)"]

function question(::Type{Person}, who::String)
    return ["who is $(who)?", "what is the name of $(who)?"]
end

function variants(::Type{Person})
    return [
        "Alice",
        "Bob",
        "Charlie",
        "Dan",
        "Eve",
        "Frank",
        "Grace",
        "Henry",
        "Martin",
        "David",
        "Luke",
    ]
end
