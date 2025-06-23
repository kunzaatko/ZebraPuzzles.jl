@enum ClueType::Bool ct_negative ct_possitive 
"""
    DirectClue <: Clue
A direct relationship of two attributes. I.e. [`PossitiveClue`](@ref) if they belong together or [`NegativeClue`](@ref) if they dont.
"""
struct DirectClue{S,A<:Attribute,B<:Attribute} <: Clue
    a::A
    b::B
    function DirectClue{S,A,B}(a, b) where {S,A,B}
        a !== b || throw(ArgumentError("a and b must be different"))
        A !== B || throw(ArgumentError("a and b must have a different type"))
        return new{S,A,B}(a, b)
    end
end
DirectClue{S}(a, b) where {S} = DirectClue{S,typeof(a),typeof(b)}(a, b)
attributes(c::DirectClue) = (c.a, c.b)

"""
    const PositiveClue = DirectClue{ct_possitive::ClueType}
"""
const PositiveClue = DirectClue{ct_possitive::ClueType}

"""
    const NegativeClue = DirectClue{ct_negative::ClueType}
"""
const NegativeClue = DirectClue{ct_negative::ClueType}

Clue(a::Attribute, b::Attribute) = PositiveClue(a, b)
Clue(a::Attribute, b::Not{<:Attribute}) = NegativeClue(a, b.skip)

Base.repr(c::PositiveClue) = repr(Clue) * "($(repr(c.a)), $(repr(c.b)))"
Base.repr(c::NegativeClue) = repr(Clue) * "($(repr(c.a)), Not($(repr(c.b))))"
Base.string(c::PositiveClue) = "$(c.a) ⟹ $(c.b)"
Base.string(c::NegativeClue) = "$(c.a) ⟹ ¬$(c.b)"
