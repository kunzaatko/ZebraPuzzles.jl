# ZebraPuzzles.jl
Welcome to the documentation for [`ZebraPuzzles.jl`](https://github.com/kunzaatko/ZebraPuzzles.jl)! 🦓

`ZebraPuzzles` is a Julia package for the [logical puzzles of the zebra type](https://en.wikipedia.org/wiki/Zebra_Puzzle). It provides a framework for [defining
puzzles](@ref "Defining a Puzzle"), [adding clues](@ref "Adding Clues") about the puzzle, and [finding a solution](@ref
"Solving the Puzzle") which satisfies the clues.

## Getting Started
To get started, you'll need to define a puzzle. A puzzle is defined by a set of attributes and a set of clues.

### Defining a Puzzle
A zebra puzzle is characterized by a number of subjects and a number of attribute types of which every subject has
a unique variant.
```@docs; canonical=false
ZebraPuzzle
```

There are two forms of a puzzle that you may want to create.

If you would like to have a puzzle that is not yet solved (for example with the intention of solving it later), you can
define it by stating the variants of attributes that can be associated with a subject.

- **Unsolved Puzzle**: A puzzle which has a set of variants for each attribute type, but they are not yet grouped as belonging to a single subject. ([`UnsolvedZebraPuzzle`](@ref))
```@example unsolved
using ZebraPuzzles # hide
using ZebraPuzzles: ZebraPuzzles as ZP # hide
puz_unsolved = ZebraPuzzle(
    Drink => ("coffee", "milk", "orange juice", "tea", "water"),
    House => ("blue", "green", "ivory", "red", "yellow"),
    Nationality => ("Englishman", "Japanese", "Spaniard", "Ukrainian", "Norwegian"),
    Pet => ("dog", "horse", "snails", "zebra", "fox"),
    Smoke => ("Chesterfields", "Lucky Strike", "Old Gold", "Parliaments", "Kools"),
)
```

- **Solved Puzzle**: A puzzle which is defined by a truth table, which specifies which attributes belong together. ([`SolvedZebraPuzzle`](@ref))
```@example solved
using ZebraPuzzles # hide
puz_solved = ZebraPuzzle(
    (House("yellow"), Nationality("Norwegian"), Drink("water"), Smoke("Kools"), Pet("fox")),
    (House("blue"), Nationality("Ukrainian"), Drink("tea"), Smoke("Chesterfields"), Pet("horse")),
    (House("red"), Nationality("Englishman"), Drink("milk"), Smoke("Old Gold"), Pet("snails")),
    (House("ivory"), Nationality("Spaniard"), Drink("orange juice"), Smoke("Lucky Strike"), Pet("dog")),
    (House("green"), Nationality("Japanese"), Drink("coffee"), Smoke("Parliaments"), Pet("zebra")),
)
```
Both of these puzzle types can contain clues which can lead the solver to a solution and in order to define a puzzle
that is solvable, you need to add these to enable a solver to infer it.

### Adding Clues
There are various types of clues that can help solve a zebra puzzle. They may hint towards the position of the subject
in relation to other subjects (direction, distance, etc.) or relation of the attributes (belong together,
do not belong together, etc.).
Clues may be added to the puzzle by directly specifying them and adding them with [`add_clue!`](@ref)
```@example unsolved
add_clue!(
    puz_unsolved,
    Clue(Drink("coffee"), Pet("snails")) # attributes "coffee" and "snails" belong together
)
nothing # hide
```
and they are checked for consistency with the puzzle in the process so that they do not contradict the previous clues.
Checking the clues may also be done separately by the [`check`](@ref ZebraPuzzles.check) function
```@repl unsolved
ZP.check(
    puz_unsolved,
    Clue(Drink("coffee"), Not(Pet("snails")))
) # ❌ inconsistent clue (contradiction)
```
It does not only control the consistency of the clues but also checks that the clue is not implied by the previous ones
to assure the _minimality_ property of the puzzle clue set.
```@repl unsolved
add_clue!(puz_unsolved, Clue(House("ivory"), Pet("snails")));
ZP.check(puz_unsolved, Clue(Drink("coffee"), House("ivory"))) # ❌ clue implied by the previous ones
```
You can also add multiple clues at once with [`add_clues!`](@ref)
```@example unsolved
add_clues!(puz_unsolved, 
    [
         ExactRelativePosition(House("green"), House("ivory"), 1),
         Clue(Smoke("Old Gold"), Pet("snails")),
         Clue(Smoke("Kools"), House("yellow")),
         AbsolutePosition(Drink("milk"), 3),
         AbsolutePosition(Nationality("Norwegian"), 1),
         AbsoluteDistance(Smoke("Chesterfields"), Pet("fox"), 1),
         AbsoluteDistance(Smoke("Kools"), Pet("horse"), 1),
         Clue(Smoke("Lucky Strike"), Drink("orange juice")),
    ]
)
nothing # hide
```
It is also possible to fill clues so that the puzzle is solvable (uniquely) using [`fill_clues!`](@ref)
```@example unsolved
using Random # hide
Random.seed!(42) # hide
fill_clues!(puz_unsolved)
nothing # hide
```
We end up with a uniquely solvable puzzle with a minimal number of clues (i.e. any clue removal leads to
non-uniqueness/insolubility).
```@repl unsolved
puz_unsolved
```

All of the above methods can also be used for the solved puzzle and additionally the correctness of the clues against
the solution is checked
```@repl solved
add_clue!(puz_solved, Clue(Drink("milk"), House("green")))
```
Clues are filled so that they are in accordance with the puzzles truth table
```@repl solved
using Random # hide
Random.seed!(42) # hide
fill_clues!(puz_solved)
```

### Solving the Puzzle
Even if the puzzle has the clues to ensure a unique solution, it is still unsolved.
```@example unsolved
@assert ZP.issolved(puz_unsolved) == false
```
To solve an unsolved puzzle, you can call the [`solve!`](@ref) function.
```@example unsolved
solve!(puz_unsolved);
nothing # hide
```
This will add the truth table to the `puz_unsolved`. You can check that it now contains the solution with
[`issolved`](@ref ZebraPuzzles.issolved)
```@example unsolved
@assert ZP.issolved(puz_unsolved) == true
```
and you can inspect the solution using [`show_solution`](@ref ZebraPuzzles.show_solution)
```@example unsolved
puz_unsolved |> ZebraPuzzles.show_solution
```

### Natural Language
If you would like to give the puzzle to someone (person 🤦 or an [AI agent](https://www.github.com/kunzaatko/PromptBench.jl) 🤖), you probably want to have it in natural language phrasing. You can get this
using the function [`riddle`](@ref)
```@example unsolved
Random.seed!(42) # hide
riddle(puz_unsolved)
nothing # hide
```
