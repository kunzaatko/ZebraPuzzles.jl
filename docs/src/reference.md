```@meta
CurrentModule = ZebraPuzzles
```

# API Reference

This page provides a reference for the modules, functions, and types in ZebraPuzzles.jl.

## Modules

- [`ZebraPuzzles`](@ref): The main module of the package.

## Functions

- [`ZebraPuzzle`](@ref): Constructor for creating a new zebra puzzle.
- [`add_clues!`](@ref): Add clues to a puzzle.
- [`add_clue!`](@ref): Add a single clue to a puzzle.
- [`attributes`](@ref): Get the attributes of a puzzle.
- [`riddle`](@ref): Get the clues of a puzzle.
- [`nclue`](@ref): Get the number of clues in a puzzle.
- [`nattr`](@ref): Get the number of attributes in a puzzle.
- [`solve!`](@ref): Solve a zebra puzzle.

## Types

- [`Attribute`](@ref): Abstract type for all attributes.
- [`Clue`](@ref): Abstract type for all clues.
- [`DirectClue`](@ref): A direct association between two attributes.
- [`PositionClue`](@ref): A clue that specifies the position of an attribute.
- [`SolvedZebraPuzzle`](@ref): A solved zebra puzzle.
- [`UnsolvedZebraPuzzle`](@ref): An unsolved zebra puzzle.

```@autodocs
Modules = [ZebraPuzzles]
```
