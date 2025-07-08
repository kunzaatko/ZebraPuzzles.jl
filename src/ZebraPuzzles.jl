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
export ZebraPuzzle, add_clues!, add_clue!, attributes, riddle, nclue, nattr
end
