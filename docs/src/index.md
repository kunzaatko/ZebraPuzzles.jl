# ZebraPuzzles.jl

Welcome to the documentation for [`ZebraPuzzles.jl`](https://github.com/kunzaatko/ZebraPuzzles.jl)!

`ZebraPuzzles` is a Julia package for the logical puzzles of the zebra type. It provides a framework for [defining
puzzles](@ref "Defining a Puzzle"), [adding clues](@ref "Adding Clues") about the puzzle, and [finding a solution](@ref
"Solving the Puzzle") which satisfies the clues.

## Getting Started

To get started, you'll need to define a puzzle. A puzzle is defined by a set of attributes and a set of clues.

### Defining a Puzzle

A puzzle can be created in two ways:

- **Unsolved Puzzle**: You can create an unsolved puzzle by specifying the categories and the possible values for each category.

```@example unsolved
using ZebraPuzzles # hide
puzzle = ZebraPuzzle(
    Drink => ("coffee", "milk", "orange juice", "tea", "water"),
    House => ("blue", "green", "ivory", "red", "yellow"),
    Nationality => ("Englishman", "Japanese", "Spaniard", "Ukrainian", "Norwegian"),
    Pet => ("dog", "horse", "snails", "zebra", "fox"),
    Smoke => ("Chesterfields", "Lucky Strike", "Old Gold", "Parliaments", "Kools"),
)
```

- **Solved Puzzle**: You can also create a puzzle with a known solution.

```@example
using ZebraPuzzles # hide
puzzle = ZebraPuzzle(
    (House("yellow"), Nationality("Norwegian"), Drink("water"), Smoke("Kools"), Pet("fox")),
    (House("blue"), Nationality("Ukrainian"), Drink("tea"), Smoke("Chesterfields"), Pet("horse")),
    (House("red"), Nationality("Englishman"), Drink("milk"), Smoke("Old Gold"), Pet("snails")),
    (House("ivory"), Nationality("Spaniard"), Drink("orange juice"), Smoke("Lucky Strike"), Pet("dog")),
    (House("green"), Nationality("Japanese"), Drink("coffee"), Smoke("Parliaments"), Pet("zebra")),
)
```

### Adding Clues

Once you have a puzzle, you can add clues to it. There are several types of clues:

*  **Direct Clue**: A direct association between two attributes.
*  **Position Clue**: A clue that specifies the position of an attribute.

```@example unsolved
add_clues!(
    puzzle,
    [
        Clue(Nationality("Englishman"), House("red")),
        Clue(Nationality("Spaniard"), Pet("dog")),
        Clue(Drink("coffee"), House("green")),
        Clue(Nationality("Ukrainian"), Drink("tea")),
        ExactRelativePosition(House("green"), House("ivory"), 1),
        Clue(Smoke("Old Gold"), Pet("snails")),
        Clue(Smoke("Kools"), House("yellow")),
        AbsolutePosition(Drink("milk"), 3, 5),
        AbsolutePosition(Nationality("Norwegian"), 1, 5),
        AbsoluteDistance(Smoke("Chesterfields"), Pet("fox"), 1),
        AbsoluteDistance(Smoke("Kools"), Pet("horse"), 1),
        Clue(Smoke("Lucky Strike"), Drink("orange juice")),
        Clue(Nationality("Japanese"), Smoke("Parliaments")),
        AbsoluteDistance(Nationality("Norwegian"), House("blue"), 1),
    ],
)
```

### Solving the Puzzle

To solve the puzzle, you can use the `solve` function.

```@example unsolved
solve!(puzzle);
nothing # hide
```

This will return a `SolvedZebraPuzzle` object containing the solution table and the solution can be shown with

```@example unsolved
puzzle |> ZebraPuzzles.show_solution
```
