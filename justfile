set shell := ["bash", "-cu"]
set dotenv-load

[doc("Default recipe shows available commands")]
[private]
default:
    @just --list

set script-interpreter := ["julia", "--color", "yes", "--project"]

puzzle := """
puzzle = ZebraPuzzle(
    Drink => ("coffee", "milk", "orange juice", "tea", "water"),
    House => ("blue", "green", "ivory", "red", "yellow"),
    Nationality => ("Englishman", "Japanese", "Spaniard", "Ukrainian", "Norwegian"),
    Pet => ("dog", "horse", "snails", "zebra", "fox"),
    Smoke => ("Chesterfields", "Lucky Strike", "Old Gold", "Parliaments", "Kools"),
)
"""

puzzle-clues := """
add_clues!(
    puzzle,
    [
        Clue(Nationality("Englishman"), House("red")),                  # The Englishman lives in the red house.
        Clue(Nationality("Spaniard"), Pet("dog")),                      # The Spaniard owns the dog.
        Clue(Drink("coffee"), House("green")),                          # Coffee is drunk in the green house.
        Clue(Nationality("Ukrainian"), Drink("tea")),                   # The Ukrainian drinks tea.
        ExactRelativePosition(House("green"), House("ivory"), 1),       # The green house is immediately to the right of the ivory house.
        Clue(Smoke("Old Gold"), Pet("snails")),                         # The Old Gold smoker owns snails.
        Clue(Smoke("Kools"), House("yellow")),                          # Kools are smoked in the yellow house.
        AbsolutePosition(Drink("milk"), 3, 5),                          # Milk is drunk in the middle house.
        AbsolutePosition(Nationality("Norwegian"), 1, 5),               # The Norwegian lives in the first house.
        AbsoluteDistance(Smoke("Chesterfields"), Pet("fox"), 1),        # The man who smokes Chesterfields lives in the house next to the man with the fox.
        AbsoluteDistance(Smoke("Kools"), Pet("horse"), 1),              # Kools are smoked in the house next to the house where the horse is kept.
        Clue(Smoke("Lucky Strike"), Drink("orange juice")),             # The Lucky Strike smoker drinks orange juice.
        Clue(Nationality("Japanese"), Smoke("Parliaments")),            # The Japanese smokes Parliaments.
        AbsoluteDistance(Nationality("Norwegian"), House("blue"), 1),   # The Norwegian lives next to the blue house.
    ],
)
"""

[doc("Generate README puzzle")]
[group("docs")]
[script]
readme-puzzle:
    using ZebraPuzzles
    {{ puzzle }}
    show(stdout, MIME("text/plain"), puzzle)

[doc("Generate README puzzle riddle")]
[group("docs")]
[script]
readme-puzzle-riddle:
    using ZebraPuzzles
    {{ puzzle }}
    {{ puzzle-clues }}
    riddle(puzzle)

[doc("Generate README puzzle HTML")]
[group("docs")]
readme-puzzle-html:
    to-html "just readme-puzzle" --no-prompt
