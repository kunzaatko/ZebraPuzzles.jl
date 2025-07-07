module ZebraPuzzles
using Reexport, DataFrames, PrettyTables, Satisfiability, Tables, Random, InterfaceFunctions
@reexport using InvertedIndices
import InvertedIndices: Not
using Mocking: @mock # NOTE: Used for `PrettyTables.pretty_table` to fix the available width <10-06-25> 
using Base: Pairs

include("attributes.jl")
include("clues.jl")
include("phrases.jl")

include("zebra-puzzle.jl")
include("solved-zebra-puzzles.jl")
include("unsolved-zebra-puzzles.jl")

include("random.jl")
include("puzzles.jl")

export SolvedZebraPuzzle, UnsolvedZebraPuzzle
export ZebraPuzzle, add_clues!, add_clue!, attributes, riddle, nclue, nattr
end
