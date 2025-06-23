using Satisfiability

"""
    AttributeExprs{K,N,P}
The [`IntExpr`](@extref `Satisfiability.IntExpr`)s about the [`Attribute`](@ref)s of a `ZebraPuzzle` that are used to solve the puzzle.
"""
struct AttributeExprs{K,N,P}
    puzzle::Ref{P}
    exprs::Matrix{IntExpr}
end

function Base.show(io::IO, m::MIME"text/plain", a::AttributeExprs)
    Base.showarg(io, a, true)
    Base.print(io, "\n")
    return Base.show(io, m, a.exprs)
end

Satisfiability.value(a::AttributeExprs) = value(a.exprs)

function AttributeExprs(p::P) where {K,N,P<:ZebraPuzzle{K,N}}
    attrs = reshape(
        IntExpr.(id.(sort(attributes(p); by=a -> reverse(indexof(p, a))))), (K, N)
    )
    return AttributeExprs{K,N,P}(Ref(p), attrs)
end
puzzle(exprs::AttributeExprs) = exprs.puzzle[]

function Base.getindex(exprs::AttributeExprs, a::Attribute)
    return exprs.exprs[indexof(puzzle(exprs), a)...]
end

function Base.getindex(exprs::AttributeExprs, a::Type{<:Attribute})
    return exprs.exprs[:, indexof(puzzle(exprs), a)]
end

"""
    rules(exprs::AttributeExprs)::BoolExpr
    rules(puzzle::ZebraPuzzle)::Tuple{AttributeExprs, BoolExpr}
Generate the zebra puzzle [`Satisfiability.jl`](@extref Satisfiability :std:doc:`index`) rules for the attributes return the rule assertion `BoolExpr`. If a `ZebraPuzzle` is passed, it first generates the `AttributeExprs` and then returns the `(exprs, rules)` tuple.

```jldoctest
julia> z = ZebraPuzzle(Drink => ("coffee", "tea"), House => ("green", "red"))
UnsolvedZebraPuzzle{2, 2, Tuple{Drink, House}} with no clues
┌────────────────────┐
│ Drink  coffee, tea │
├────────────────────┤
│ House  green, red  │
└────────────────────┘


julia> exprs, rules = ZP.rules(z);

julia> rules
4-element Vector{Satisfiability.BoolExpr}:
 and_4a3b8ce4f0c5932b
 | leq_13a07d362557ecbd
 |  | const_1 = 1
 |  | Drink_tea
 | leq_5f49e791afe246a5
 |  | const_1 = 1
 |  | House_green
 | leq_a27b1741a1f9008e
 |  | const_1 = 1
 |  | House_red
 | leq_e94b7d8032d90182
 |  | const_1 = 1
 |  | Drink_coffee

 and_9b58b2ca1f5f8553
 | leq_20b3312716ae8085
 |  | House_red
 |  | const_2 = 2
 | leq_2349e5270bfc6484
 |  | Drink_tea
 |  | const_2 = 2
 | leq_4674d87e645a7ee8
 |  | Drink_coffee
 |  | const_2 = 2
 | leq_e343fa1b3fccf18b
 |  | House_green
 |  | const_2 = 2

 distinct_f63a38a3190ef4f4
 | Drink_coffee
 | Drink_tea

 distinct_7f6fa8abcc538373
 | House_green
 | House_red
```
"""
function rules(exprs::AttributeExprs{K}) where {K}
    rule_assertions = [and(1 .<= exprs.exprs), and(exprs.exprs .<= K)]
    append!(rule_assertions, [distinct(exprs[a]) for a in attrtypes(puzzle(exprs))])
    return rule_assertions
end
function rules(z::ZebraPuzzle)
    exprs = AttributeExprs(z)
    return (exprs, rules(exprs))
end

@interface expr(c::Clue, ::AttributeExprs)
expr(c::PositiveClue, exprs::AttributeExprs) = exprs[c.a] == exprs[c.b]
expr(c::NegativeClue, exprs::AttributeExprs) = exprs[c.a] != exprs[c.b]
expr(c::AbsolutePosition, exprs::AttributeExprs) = exprs[c.a] == c.p
function expr(c::AbsoluteDistance, exprs::AttributeExprs)
    return ((exprs[c.a] - c.d) == exprs[c.b]) ∨ (exprs[c.a] == (exprs[c.b] - c.d))
end
expr(c::DirectionClue{<:Any,<:Any,d_left}, exprs::AttributeExprs) = exprs[c.a] < exprs[c.b]
expr(c::DirectionClue{<:Any,<:Any,d_right}, exprs::AttributeExprs) = exprs[c.a] > exprs[c.b]
function expr(c::ExactRelativePosition{<:Any,<:Any,d_left}, exprs::AttributeExprs)
    return exprs[c.a] + c.r == exprs[c.b]
end
function expr(c::ExactRelativePosition{<:Any,<:Any,d_right}, exprs::AttributeExprs)
    return exprs[c.a] == exprs[c.b] + c.r
end

assertions(puzzle::ZebraPuzzle) = assertions(puzzle, AttributeExprs(puzzle))
function assertions(puzzle::ZebraPuzzle, exprs::AttributeExprs)
    return append!(rules(exprs), [expr(c, exprs) for c in puzzle.clues])
end
