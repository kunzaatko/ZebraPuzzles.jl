einstein_clues = [
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
    ]

z = ZebraPuzzle(
    (House("yellow"), Nationality("Norwegian"), Drink("water"), Smoke("Kools"), Pet("fox")),
    (
        House("blue"),
        Nationality("Ukrainian"),
        Drink("tea"),
        Smoke("Chesterfields"),
        Pet("horse"),
    ),
    (
        House("red"),
        Nationality("Englishman"),
        Drink("milk"),
        Smoke("Old Gold"),
        Pet("snails"),
    ),
    (
        House("ivory"),
        Nationality("Spaniard"),
        Drink("orange juice"),
        Smoke("Lucky Strike"),
        Pet("dog"),
    ),
    (
        House("green"),
        Nationality("Japanese"),
        Drink("coffee"),
        Smoke("Parliaments"),
        Pet("zebra"),
    ),
)

add_clues!(
    z,
    einstein_clues,
    ischecked=true,
)

"""
    EINSTEINS_ZEBRA isa SolvedZebraPuzzle
This is the famous zebra puzzle that gave zebra puzzles their name. It is said to be created by Albert Einstein. You can learn more about it at the [Wikipedia Zebra Puzzle entry](https://en.wikipedia.org/wiki/Zebra_Puzzle).

```jldoctest
julia> ZP.EINSTEINS_ZEBRA
ZebraPuzzles.SolvedZebraPuzzle{5, 5, Tuple{House, Nationality, Drink, Smoke, Pet}} with 14 clues
┌──────────────────────────────────────────────────────────┐
│ House   Nationality      Smoke         Drink       Pet   │
├──────────────────────────────────────────────────────────┤
│ yellow   Norwegian       Kools         water       fox   │
├──────────────────────────────────────────────────────────┤
│  blue    Ukrainian   Chesterfields      tea       horse  │
├──────────────────────────────────────────────────────────┤
│  red    Englishman     Old Gold         milk      snails │
├──────────────────────────────────────────────────────────┤
│ ivory    Spaniard    Lucky Strike   orange juice   dog   │
├──────────────────────────────────────────────────────────┤
│ green    Japanese     Parliaments      coffee     zebra  │
└──────────────────────────────────────────────────────────┘

clues:
1) Nationality("Englishman") ⟹ House("red")
2) Nationality("Spaniard") ⟹ Pet("dog")
3) Drink("coffee") ⟹ House("green")
4) Nationality("Ukrainian") ⟹ Drink("tea")
5) Pos[House("green")] == Pos[House("ivory")] + 1
6) Smoke("Old Gold") ⟹ Pet("snails")
7) Smoke("Kools") ⟹ House("yellow")
8) Pos[Drink("milk")] == 3
9) Pos[Nationality("Norwegian")] == 1
10) abs(Pos[Smoke("Chesterfields")] - Pos[Pet("fox")]) == 1
11) abs(Pos[Smoke("Kools")] - Pos[Pet("horse")]) == 1
12) Smoke("Lucky Strike") ⟹ Drink("orange juice")
13) Nationality("Japanese") ⟹ Smoke("Parliaments")
14) abs(Pos[Nationality("Norwegian")] - Pos[House("blue")]) == 1
```
"""
const EINSTEINS_ZEBRA = z

z_unsolved = ZebraPuzzle(
    Drink => ("coffee", "milk", "orange juice", "tea", "water"),
    House => ("blue", "green", "ivory", "red", "yellow"),
    Nationality => ("Englishman", "Japanese", "Spaniard", "Ukrainian", "Norwegian"),
    Pet => ("dog", "horse", "snails", "zebra", "fox"),
    Smoke => ("Chesterfields", "Lucky Strike", "Old Gold", "Parliaments", "Kools"),
)

add_clues!(
    z_unsolved,
    einstein_clues,
    ischecked=true,
)

"""
    UNSOLVED_EINSTEINS_ZEBRA isa UnsolvedZebraPuzzle    
This is the famous zebra puzzle that gave zebra puzzles their name. It is said to be created by Albert Einstein. You can learn more about it at the [Wikipedia Zebra Puzzle entry](https://en.wikipedia.org/wiki/Zebra_Puzzle).

The difference between this constant and `EINSTEINS_ZEBRA` is that this instance is not solved (does not contain the solution table).

See also [`EINSTEINS_ZEBRA`](@ref)

```jldoctest
julia> ZP.UNSOLVED_EINSTEINS_ZEBRA
UnsolvedZebraPuzzle{5, 5, Tuple{Drink, House, Nationality, Pet, Smoke}} with 14 clues
┌────────────────────────────────────────────────────────────────────────┐
│    Drink              coffee, milk, orange juice, tea, water           │
├────────────────────────────────────────────────────────────────────────┤
│    House                  blue, green, ivory, red, yellow              │
├────────────────────────────────────────────────────────────────────────┤
│ Nationality    Englishman, Japanese, Spaniard, Ukrainian, Norwegian    │
├────────────────────────────────────────────────────────────────────────┤
│     Pet                   dog, horse, snails, zebra, fox               │
├────────────────────────────────────────────────────────────────────────┤
│    Smoke     Chesterfields, Lucky Strike, Old Gold, Parliaments, Kools │
└────────────────────────────────────────────────────────────────────────┘

clues:
1) Nationality("Englishman") ⟹ House("red")
2) Nationality("Spaniard") ⟹ Pet("dog")
3) Drink("coffee") ⟹ House("green")
4) Nationality("Ukrainian") ⟹ Drink("tea")
5) Pos[House("green")] == Pos[House("ivory")] + 1
6) Smoke("Old Gold") ⟹ Pet("snails")
7) Smoke("Kools") ⟹ House("yellow")
8) Pos[Drink("milk")] == 3
9) Pos[Nationality("Norwegian")] == 1
10) abs(Pos[Smoke("Chesterfields")] - Pos[Pet("fox")]) == 1
11) abs(Pos[Smoke("Kools")] - Pos[Pet("horse")]) == 1
12) Smoke("Lucky Strike") ⟹ Drink("orange juice")
13) Nationality("Japanese") ⟹ Smoke("Parliaments")
14) abs(Pos[Nationality("Norwegian")] - Pos[House("blue")]) == 1
```
"""
const UNSOLVED_EINSTEINS_ZEBRA = z_unsolved

const SIMPLE_ZEBRA = ZebraPuzzle(
    (House("red"), Nationality("Englishman"), Smoke("Old Gold"), Drink("tea")),
    (House("green"), Nationality("Japanese"), Smoke("Parliaments"), Drink("coffee")),
    (House("ivory"), Nationality("Spaniard"), Smoke("Lucky Strike"), Drink("orange juice")),
)
