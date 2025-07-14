# TODO: Questions about the attributes at a given position <09-07-25> 

"""
    Question
A question that can be asked about the solution of a `ZebraPuzzle`

Subtypes are [`AttributeQuestion`](@ref), [`PositionQuestion`](@ref)
"""
abstract type Question end

@interface phrase(q::Question)::String
# TODO: Documentation
@interface attributes(q::Question)::Vector{Attribute}
# TODO: Documentation
@interface attr_types(q::Question)::Vector{Attribute}

"""
    answer(q::Question, z::ZebraPuzzle)
Give the answer to the question `q` in the `ZebraPuzzle` `z`.

```jldoctest
julia> aq = AttributeQuestion{Smoke}(Nationality("Englishman"));

julia> ZP.answer(aq, ZP.EINSTEINS_ZEBRA)
Smoke("Old Gold")

julia> pq = PositionQuestion(Drink("water"));

julia> ZP.answer(pq, ZP.EINSTEINS_ZEBRA)
1
```
"""
@interface answer(q::Question, puz::ZebraPuzzle)

"""
    AttributeQuestion{A,S} <: Question
A question about a specific attribute of type `A` of the subject type `S`, or position if `S<:Int`.

The question that an `AttributeQuestion` asks can be loosely stated as "What is the attribute with type `A` linked to the subject `s::S`?" An answer is the attribute `a::A` which is linked to the subject `s::S`.
"""
struct AttributeQuestion{A,S} <: Question
    subject::S
end
AttributeQuestion{A}(s::Attribute) where {A} = AttributeQuestion{A,typeof(s)}(s)
attributes(aq::AttributeQuestion) = [aq.subject]
qattrtype(::AttributeQuestion{A}) where {A} = A
attr_types(::AttributeQuestion{A,S}) where {A,S} = [A, S]
function answer(aq::AttributeQuestion, z::ZebraPuzzle)
    return truthtable(z)[indexof(z, aq.subject)[1], col(qattrtype(aq))]
end

function Base.string(aq::AttributeQuestion{A}) where {A}
    return "$(A)[$(aq.subject)]?"
end

"""
    PositionQuestion{A}
A question about the position of the subject with the attribute `a::A`.

The question that a `PositionQuestion` asks can be loosely stated as "What is the position of the subject with the attribute `a::A`?" An answer is the position of the subject with the attribute `a::A`.
"""
struct PositionQuestion{A} <: Question
    subject::A
end
attributes(pq::PositionQuestion) = [pq.subject]
attr_types(::PositionQuestion{A}) where {A} = [A]
function answer(pq::PositionQuestion, z::ZebraPuzzle)
    return findfirst(==(pq.subject), truthtable(z)[!, col(pq.subject)])
end

Base.string(pq::PositionQuestion) = "Pos[$(pq.subject)]?"

export Question, AttributeQuestion, PositionQuestion
