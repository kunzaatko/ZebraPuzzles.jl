"""
    Job <: Attribute
The job of the subject.
"""
struct Job <: Attribute
    title::String
end
function attributed(d::Job)
    return [
        "the $(d.title)",
        [
            "the $character who is the $(d.title)" for
            character in ["man", "person", "individual"]
        ]...,
    ]
end
attribution(d::Job) = ["$a the $(d.title)" for a in ["is", "works as"]]
negation(d::Job) = ["$a the $(d.title)" for a in ["is not", "does not work as"]]
function question(::Type{Job}, who::String)
    return ["What is the occupation of $who?", "What does $who do for a living?"]
end

function variants(::Type{Job})
    return [
        "engineer",
        "teacher",
        "veterinarian",
        "architect",
        "dentist",
        "programmer",
        "biologist",
        "plumber",
        "nurse",
        "artist",
    ]
end
