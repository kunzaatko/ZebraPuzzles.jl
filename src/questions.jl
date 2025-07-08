"""
    Question
A question that can be asked about the solution of a `ZebraPuzzle`

Subtypes are `SubjectQuestion`, `AttributeQuestion`, `PositionQuestion`
"""
abstract type Question end 

"""
    SubjectQuestion{S,Attrs} <: Question
A question about a which attributes a subject, defined by either its attribute of type `S` or positions, where `S<:Int`.

The question that a `SubjectQuestion` asks can be loosely stated as "Who is the subject `s::S`?" An answer is any of the attributes of the type `A!=S in Attrs` which is linked to the subject `s::S`.
"""
struct SubjectQuestion{S, Attrs} <: Question 
    subject::S
    attrs::Attrs
end 

"""
    AttributeQuestion{A,S} <: Question
A question about a specific attribute of type `A` of the subject type `S`, or position if `S<:Int`.

The question that an `AttributeQuestion` asks can be loosely stated as "What is the attribute with type `A` linked to the subject `s::S`?" An answer is the attribute `a::A` which is linked to the subject `s::S`.
"""
struct AttributeQuestion{A,S} <: Question 
    subject::S
end 

"""
    PositionQuestion{A}
A question about the position of the subject with the attribute `a::A`.

The question that a `PositionQuestion` asks can be loosely stated as "What is the position of the subject with the attribute `a::A`?" An answer is the position of the subject with the attribute `a::A`.
"""
struct PositionQuestion{A} <:  Question 
    subject::A
end 

export Question
