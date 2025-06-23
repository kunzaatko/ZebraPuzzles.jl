abstract type PositionClue <: Clue end

@enum Position p_first p_middle p_last
function Base.string(p::Position)
    if p === p_first::Position
        return "first"
    elseif p === p_last::Position
        return "last"
    else
        return "middle"
    end
end

struct AbsolutePosition{A,P} <: PositionClue
    a::A
    p::P
    K::Union{Missing,Int}
end
AbsolutePosition(a, p) = AbsolutePosition(a, p, missing)
attributes(p::AbsolutePosition) = (p.a,)
Base.string(c::AbsolutePosition) = "Pos[$(c.a)] == $(c.p)"
function Base.repr(c::AbsolutePosition)
    return repr(AbsolutePosition) *
           "($(repr(c.a)), $(repr(c.p))$(c.K === missing ? ", $(c.K)" : ""))"
end

abstract type RelativePosition{A,B} <: PositionClue end

@enum Direction d_left d_right
Base.string(d::Direction) = d === d_left::Direction ? "left" : "right"
direction(r::Int) = sign(r) == 1 ? d_right : d_left

struct ExactRelativePosition{A,B,D} <: RelativePosition{A,B}
    a::A
    b::B
    r::Int
    function ExactRelativePosition{A,B,D}(a::A, b::B, r::Int) where {A,B,D}
        @assert r > 0 "Sign is encoded by direction and only positive integers are allowed in struct"
        return new{A,B,D}(a, b, r)
    end
end
function ExactRelativePosition(a::A, b::B, r::Int) where {A,B}
    return ExactRelativePosition{A,B,direction(r)}(a, b, abs(r))
end
function Base.repr(c::ExactRelativePosition{<:Any,<:Any,D}) where {D}
    return repr(ExactRelativePosition) *
           "($(repr(c.a)), $(repr(c.b)), $(D == d_left ? "-" : "")$(repr(c.r)))"
end
attributes(p::ExactRelativePosition) = (p.a, p.b)
function Base.string(c::ExactRelativePosition{<:Any,<:Any,d_left})
    return "Pos[$(c.a)] + $(c.r) == Pos[$(c.b)]"
end
function Base.string(c::ExactRelativePosition{<:Any,<:Any,d_right})
    return "Pos[$(c.a)] == Pos[$(c.b)] + $(c.r)"
end

"""
    DirectionClue{A,B,D} <: RelativePosition{A,B}
A clue that states "`a::A` is `d::D` of `b::B`".

```jldoctest
julia> DirectionClue(House("red"), Drink("coffee"), ZP.d_left) |> string |> print
Pos[House("red")] < Pos[Drink("coffee")]
julia> ZP.check(ZP.EINSTEINS_ZEBRA, DirectionClue(House("red"), Drink("coffee"), ZP.d_left); implied=false, duplicates=false, minimal=false)
true
```
"""
struct DirectionClue{A,B,D} <: RelativePosition{A,B}
    a::A
    b::B
    d::Direction
end
DirectionClue(a::A, b::B, d::Direction) where {A,B} = DirectionClue{A,B,d}(a, b, d)
attributes(c::DirectionClue) = (c.a, c.b)
function Base.repr(c::DirectionClue)
    return repr(DirectionClue) * "($(repr(c.a)), $(repr(c.b)), $(repr(c.d)))"
end
Base.string(c::DirectionClue{<:Any,<:Any,d_left}) = "Pos[$(c.a)] < Pos[$(c.b)]"
Base.string(c::DirectionClue{<:Any,<:Any,d_right}) = "Pos[$(c.a)] > Pos[$(c.b)]"

"""
    AbsoluteDistance{A,B} <: RelativePosition{A,B}
A clue that states "`a::A` is `d` places from `b::B`"

```jldoctest
julia> AbsoluteDistance(House("red"), Drink("coffee"), 2) |> string |> print
abs(Pos[House("red")] - Pos[Drink("coffee")]) == 2
julia> ZP.check(ZP.EINSTEINS_ZEBRA, AbsoluteDistance(House("red"), Drink("coffee"), 2); implied=false, duplicates=false, minimal=false)
true

```
"""
struct AbsoluteDistance{A,B} <: RelativePosition{A,B}
    a::A
    b::B
    d::Int
end
attributes(d::AbsoluteDistance) = (d.a, d.b)
Base.string(c::AbsoluteDistance) = "abs(Pos[$(c.a)] - Pos[$(c.b)]) == $(c.d)"
function Base.repr(c::AbsoluteDistance)
    return repr(AbsoluteDistance) * "($(repr(c.a)), $(repr(c.b)), $(repr(c.d)))"
end
