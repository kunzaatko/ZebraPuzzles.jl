"""
    ZebraPuzzles
Defines logic puzzles of the _zebra_ kind. This module has the logic to define, generate and solve these puzzles as well
as phrase them in plain text and markdown.
"""
module ZebraPuzzles
using Reexport, DataFrames, PrettyTables, Satisfiability, Tables, Random, InterfaceFunctions
@reexport using InvertedIndices
import InvertedIndices: Not
using Mocking: @mock # NOTE: Used for `PrettyTables.pretty_table` to fix the available width <10-06-25> 
using Base: Pairs

"""
    ZebraPuzzle{K,N,Attrs}

Represents a Zebra Puzzle, a type of logic puzzle where one deduces relationships between different subjects and their
attributes based on a set of clues.

# Type Parameters
- `K`: number of puzzle subjects and therefore also the number of distinct values of every attribute type
- `N`: number of attributes of per subject
- `Attrs`: attribute types `Tuple{Attr1,Attr2,...}` where `Attri` can be e.g. [`Hat`](@ref), [`Nationality`](@ref), [`Person`](@ref) or [`House`](@ref). It has length `N`.
"""
abstract type ZebraPuzzle{K,N,Attrs} end

include("attributes.jl")
include("clues.jl")
include("questions.jl")

include("phrases.jl")

include("zebra-puzzle.jl")
include("solved-zebra-puzzles.jl")
include("unsolved-zebra-puzzles.jl")

include("random.jl")
include("puzzles.jl")

export SolvedZebraPuzzle, UnsolvedZebraPuzzle, ZebraPuzzle
export ZebraPuzzle, add_clues!, add_clue!, add_question!, attributes, riddle, nclue, nattr
end
