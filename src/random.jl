using Random, InteractiveUtils

struct Cell end
Random.rand(::Type{Cell}, z::SolvedZebraPuzzle) = rand(z.table[!, rand(names(z.table))])
Random.rand(::Type{Cell}, df::DataFrame) = rand(df[!, rand(names(df))])

function Random.rand(::Type{DirectClue}, z::ZebraPuzzle)
    T = rand([PositiveClue, NegativeClue])
    return rand(T, z)
end

function Random.rand(::Type{PositiveClue}, z::SolvedZebraPuzzle)
    a = rand(Cell, z)
    b = rand(attributes(z, a))
    return PositiveClue(a, b)
end
function Random.rand(::Type{PositiveClue}, z::UnsolvedZebraPuzzle)
    a = rand(attributes(z))
    b = rand(attributes(z, Not(typeof(a))))
    return PositiveClue(a, b)
end

function Random.rand(::Type{NegativeClue}, z::SolvedZebraPuzzle)
    a = rand(Cell, z)
    b = rand(filter(x -> typeof(x) != typeof(a), attributes(z, Not(a))))
    return NegativeClue(a, b)
end
function Random.rand(::Type{NegativeClue}, z::UnsolvedZebraPuzzle)
    a = rand(attributes(z))
    b = rand(attributes(z, Not(typeof(a))))
    return NegativeClue(a, b)
end

position(z::SolvedZebraPuzzle, a::Attribute) = findfirst(==(a), attributes(z, typeof(a)))
distance(z::SolvedZebraPuzzle, a::Attribute, b::Attribute) = position(z, b) - position(z, a)
function Random.rand(::Type{ExactRelativePosition}, z::SolvedZebraPuzzle)
    a = rand(Cell, z)
    b = rand(attributes(z, Not(a)))
    r = distance(z, b, a)
    return ExactRelativePosition(a, b, r)
end
function Random.rand(::Type{ExactRelativePosition}, z::UnsolvedZebraPuzzle{K}) where {K}
    a = rand(attributes(z))
    b = rand(filter(!=(a), attributes(z)))
    r = rand([((-(K - 1)):(-1))..., (1:(K - 1))...])
    return ExactRelativePosition(a, b, r)
end

function Random.rand(::Type{DirectionClue}, z::SolvedZebraPuzzle)
    a = rand(Cell, z)
    b = rand(attributes(z, Not(a)))
    r = distance(z, b, a)
    return DirectionClue(a, b, direction(r))
end
function Random.rand(::Type{DirectionClue}, z::UnsolvedZebraPuzzle)
    a = rand(attributes(z))
    b = rand(filter(!=(a), attributes(z)))
    d = rand([d_left, d_right])
    return DirectionClue(a, b, d)
end

function Random.rand(::Type{AbsolutePosition}, z::SolvedZebraPuzzle{K}) where {K}
    a = rand(Cell, z)
    p = position(z, a)
    return AbsolutePosition(a, p, K)
end
function Random.rand(::Type{AbsolutePosition}, z::UnsolvedZebraPuzzle{K}) where {K}
    a = rand(attributes(z))
    p = rand(1:K)
    return AbsolutePosition(a, p, K)
end

function Random.rand(::Type{AbsoluteDistance}, z::SolvedZebraPuzzle)
    a = rand(Cell, z)
    b = rand(attributes(z, Not(a)))
    r = distance(z, a, b)
    return AbsoluteDistance(a, b, abs(r))
end
function Random.rand(::Type{AbsoluteDistance}, z::UnsolvedZebraPuzzle{K}) where {K}
    a = rand(attributes(z))
    b = rand(filter(!=(a), attributes(z)))
    r = rand(1:(K - 1))
    return AbsoluteDistance(a, b, r)
end

function accumsubtypes!(T::Type, accum::Vector{Type}, left::Vector{Type})
    @assert isabstracttype(T) "The type passed to the accumulator `accumsubtypes!` must be an abstract type"
    T_sub = subtypes(T)
    concrete_T, abstract_T = filter(!isabstracttype, T_sub), filter(isabstracttype, T_sub)
    append!(accum, concrete_T)
    append!(left, abstract_T)
    if !isempty(left)
        accumsubtypes!(left[1], accum, left[2:end])
    else
        return accum
    end
end
accumsubtypes(T::Type) = accumsubtypes!(T, Type[], Type[])

"""
    Random.rand(UnsolvedZebraPuzzle{K,N}; clues=true)
Generate a random unsolved zebra puzzle with `K` subjects each of which has `N` attributes.

If `clues` is `true`, the puzzle is filled with a minimal set of random clues ensuring that it is solvable.
"""
function Random.rand(::Type{UnsolvedZebraPuzzle{K,N}}; clues=true) where {K,N}
    attrs = [rand([House, Person])] # main attribute
    append!(
        attrs, first(shuffle(filter(k -> !in(k, attrs), accumsubtypes(Attribute))), K - 1)
    )
    puzzle = ZebraPuzzle(collect(attr => Tuple(rand(attr, N)) for attr in attrs)...)
    @info """
    Generated attributes:
    $(join(
        [
            string(nameof(T)) * " -> " * join(map(string, attributes(puzzle, T)), ", ")
            for T in attrtypes(puzzle)
        ],
        "; ",
    ))
    """
    @info "Generating clues…"
    clues && fill_clues!(puzzle)
    return puzzle
end
function Random.rand(::Type{UnsolvedZebraPuzzle}, K::Int, N::Int; clues=true)
    return rand(UnsolvedZebraPuzzle{K,N}; clues)
end
