```@meta
CurrentModule = ZebraPuzzles
CollapsedDocstrings = true
```

# API Reference

This page provides a reference for the modules, functions, and types in ZebraPuzzles.jl.

## Modules

- [`ZebraPuzzles`](@ref): The main module of the package.

## Functions

- [`add_clues!`](@ref): Add clues to a puzzle.
- [`add_clue!`](@ref): Add a single clue to a puzzle.
- [`attributes`](@ref): Get the attributes of a puzzle.
- [`riddle`](@ref): Get the clues of a puzzle.
- [`nclue`](@ref): Get the number of clues in a puzzle.
- [`nattr`](@ref): Get the number of attributes in a puzzle.
- [`solve!`](@ref): Solve a zebra puzzle.
- [`puzzle_record`](@ref): Export a puzzle as a validated, JSON-compatible record.

## Types

- [`ZebraPuzzle`](@ref): Abstract type for any zebra puzzle.
  - [`SolvedZebraPuzzle`](@ref): A solved zebra puzzle.
  - [`UnsolvedZebraPuzzle`](@ref): An unsolved zebra puzzle.
- [`Attribute`](@ref): Abstract type for all attributes.
- [`Clue`](@ref): Abstract type for all clues.
  - [`DirectClue`](@ref): A direct association between two attributes.
  - [`PositionClue`](@ref): A clue that specifies the position of an attribute.

## Puzzle export

[`puzzle_record`](@ref) exports an [`UnsolvedZebraPuzzle`](@ref) as a validated, detached and
JSON-compatible `Dict{String,Any}` with string keys, arrays, strings and integers.

The puzzle must hold exactly one supported question (an [`AttributeQuestion`](@ref) or a
[`PositionQuestion`](@ref)) and its rules and clues must determine a unique solution. The record is
always derived from a fresh solve of a copy of the puzzle, whether or not its internal truth table
was previously filled: a complete stored table may be stale after clue edits, and [`solve!`](@ref)
only warns about non-unique solutions. Unsatisfiable, non-unique and inconclusive solver outcomes
are rejected, as are puzzles with zero, multiple, invalid or unsupported questions. The input puzzle
is not mutated and nothing is printed.

### Record fields (schema version `1`)

| Field | Type | Content |
| --- | --- | --- |
| `schema_version` | `Int` | Always `1`. |
| `riddle` | `String` | The rendered riddle text including the one question. |
| `dimensions` | `Dict` | `subjects`, `attribute_types` and `clue_count` measured from the puzzle. |
| `question` | `Dict` | `kind` (`"attribute"` or `"position"`), the `subject` as an object with `attribute_type` and raw string `value` and, for attribute questions only, the `attribute_type` of the requested category. |
| `solution` | `Dict` | `columns` (the declared category names) and `rows` (arrays of raw attribute strings in that column order). Rows are in position order; the first row is position 1. |
| `answer` | `Dict` | `{"kind" => "attribute", "attribute_type" => ..., "value" => ...}` or `{"kind" => "position", "value" => <one-based position integer>}`. |

### JSON encoding

JSON encoding is deliberately kept out of the package: `puzzle_record` returns plain data that can
be serialized by a JSON library in the caller's environment, e.g. with JSON.jl v1

```julia
using JSON

record = puzzle_record(puzzle)
JSON.json(record) # one compact UTF-8 JSON object
```

A batch writer can emit one compact UTF-8 JSON object per line (JSON Lines) with a trailing newline
and no blank lines

```julia
open("puzzles.jsonl", "w") do io
    for puzzle in puzzles
        println(io, JSON.json(puzzle_record(puzzle)))
    end
end
```

!!! note "Phrasing is randomized"
    Clue and question phrasing uses `rand`, so the `riddle` text differs from call to call. Persist
    the returned record instead of trying to reproduce the text from a seed: the seed to phrase
    mapping is not guaranteed to be stable across Julia or package versions.

```@autodocs
Modules = [ZebraPuzzles]
```
