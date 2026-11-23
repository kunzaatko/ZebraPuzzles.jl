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

function Random.rand(::Type{Clue}, z::ZebraPuzzle)
    # NOTE: Impossible to to choose randomly using subtypes because we want to include type constants such as
    # `PositiveClue` and `NegativeClue` <05-06-25> 
    type = rand((
        PositiveClue,
        NegativeClue,
        ExactRelativePosition,
        DirectionClue,
        AbsolutePosition,
        AbsoluteDistance,
    ))
    return rand(type, z::ZebraPuzzle)
end

function Random.rand(::Type{AttributeQuestion{A,S}}, z::ZebraPuzzle) where {S,A}
    subject = rand(attributes(z, S))
    return AttributeQuestion{A,typeof(subject)}(subject)
end
function Random.rand(::Type{AttributeQuestion{A}}, z::ZebraPuzzle) where {A}
    # avoid pairing subject-like attribute types with each other (questions such as "who is the
    # green house?" are nonsensical) and person-centric attribute types (see `person_centric`) with
    # location-like subjects (e.g. the job of a house)
    candidates = filter(
        t ->
            t != A &&
            !(A <: Subject && t <: Subject) &&
            !(person_centric(A) && is_location(t)),
        attrtypes(z),
    )
    isempty(candidates) && throw(ArgumentError(
        "The attribute type `$A` cannot make a sensible attribute question about any of the other " *
            "attribute types `$(filter(!=(A), attrtypes(z)))`.",
    ))
    return rand(AttributeQuestion{A,rand(candidates)}, z)
end
function Random.rand(::Type{AttributeQuestion}, z::ZebraPuzzle)
    # select a (requested type, subject type) pair whose question reads sensibly instead of
    # falling back to an incoherent one
    pairs = [
        (A, S) for A in attrtypes(z) for S in attrtypes(z) if
        S != A && !(A <: Subject && S <: Subject) && !(person_centric(A) && is_location(S))
    ]
    isempty(pairs) && throw(ArgumentError(
        "The puzzle has no pair of attribute types that makes a sensible attribute question."
    ))
    A, S = rand(pairs)
    return rand(AttributeQuestion{A,S}, z)
end

function Random.rand(::Type{PositionQuestion{A}}, z::ZebraPuzzle) where {A}
    return PositionQuestion{A}(rand(attributes(z, A)))
end
function Random.rand(::Type{PositionQuestion}, z::ZebraPuzzle)
    return rand(PositionQuestion{rand(attrtypes(z))}, z)
end
function Random.rand(::Type{Question}, z::ZebraPuzzle)
    type = rand((PositionQuestion, AttributeQuestion))
    try
        return rand(type, z)
    catch e
        # a puzzle whose attribute types make no sensible attribute question (e.g. only subject-like
        # and person-centric types) still gets a position question
        e isa ArgumentError || rethrow()
        return rand(PositionQuestion, z)
    end
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

If `clues` is `true`, the puzzle is filled with random clues until its rules and clues determine a
unique solution, i.e. until adding any further clue would be unnecessary for finding the solution.
This is _not_ a guarantee that none of the clues could be removed while keeping the solution.
If `question` is `true`, the puzzle is accompanied with a random question about the puzzle.
"""
function Random.rand(::Type{UnsolvedZebraPuzzle{K,N}}; clues=true, question=true) where {K,N}
    main = rand([House, Person, Car])
    # `House` and `Car` are both location-like (see `is_location`) but tell different stories, so a
    # generated puzzle contains at most one of them and the positional clue phrases stay coherent
    excluded = if main == House
        [Car]
    elseif main == Car
        [House]
    else
        location = rand([House, Car, nothing])
        location isa Type ? [location == House ? Car : House] : [House, Car]
    end
    attrs = [main]
    candidates =
        shuffle(filter(k -> !in(k, attrs) && !in(k, excluded), accumsubtypes(Attribute)))
    append!(attrs, first(candidates, N - 1))
    puzzle = ZebraPuzzle(collect(attr => Tuple(rand(attr, K)) for attr in attrs)...)
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
if clues
    @info "Generating clues…"
    fill_clues!(puzzle)
end
if question
    @info "Generating question…"
    add_question!(puzzle)
end

    return puzzle
end
function Random.rand(::Type{UnsolvedZebraPuzzle}, K::Int, N::Int; clues=true, question=true)
    return rand(UnsolvedZebraPuzzle{K,N}; clues, question)
end
