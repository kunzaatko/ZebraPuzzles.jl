- `partial_solve!`: Partially solve the puzzle
    - for all the positions, check whether the position is stable i.e. satisfiability with the added negation of the
      position assertion. Some of the positions will end up valid and some would be non-stable and allow multiple
      solutions.
    - Issue with the possible permutations that are not stable but some attributes still belong together.
- [`InteractiveSolver`](@extref Satisfiability :std:label:`Interactive-solving`): Optimizations that are 
    - Store the `InteractiveSolver` in the puzzle and avoid constructing the satisfiability problem from the beginning
      each time.
- `IncompletePuzzle <: PuzzleError` <-> `check_complete`:  Check whether the puzzle clues contain all the attributes
- `abstract type Question end`: Stating the question of the puzzle 
    - could be the `PositionQuestion`, `AttributionQuestion`, `CompleteQuestion`
    - based on these, it would be determined whether the puzzle is solvable instead of requiring the complete solution
      (`CompleteQuestion` solution) by default
- `@clue_str`: A better stating of clues
    - An example would be `clue"Hat[Sombrero] -> Pos[1]"`, `clue"Hat[Sombrero] <=> House[red]"`, `clue"House[red] + 1 ->
      House[blue]"` etc.
