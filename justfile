set shell := ["bash", "-cu"]
set dotenv-load

[doc("Default recipe shows available commands")]
[private]
default:
    @just --list

set script-interpreter := ["julia", "--color", "yes", "--project"]

root-dir := justfile_directory()

# hint := BLUE + "" + NORMAL
progress := CYAN + "●" + NORMAL
ok := GREEN + "✓" + NORMAL
# warn := YELLOW + "⚠" + NORMAL
fail := RED + "✗" + NORMAL

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

[doc("Generate and open the package documenation")]
[group("docs")]
[script("fish")]
[working-directory(root-dir)]
docs:
    echo "{{ progress }} Generating documentation..."
    julia --project=docs --color=yes docs/make.jl
    echo "{{ ok }} Documentation generated."
    xdg-open docs/build/index.html

[doc("Run unittests for the package")]
[group("test")]
[script("fish")]
[working-directory(root-dir)]
test:
    julia --project -e "using Pkg; Pkg.test()"

[doc("Launch the Julia project REPL")]
[group("dev")]
[script("fish")]
[working-directory(root-dir)]
repl:
    julia --project

[doc("Instantiate the package environments")]
[group("dev")]
[script("fish")]
[working-directory(root-dir)]
pkg-instantiate:
    echo "{{ progress }} Instantiating project packages..."
    julia --project -e 'try; using Pkg; Pkg.instantiate(); println("{{ ok }} Instantiated."); catch e; println(stderr, "{{ fail }} Instantiation failed."); exit(1); end'
    echo "{{ progress }} Instantiating documentation packages..."
    julia --project=docs -e 'try; using Pkg; Pkg.instantiate(); println("{{ ok }} Instantiated."); catch e; println(stderr, "{{ fail }} Instantiation failed."); exit(1); end'
    echo "{{ progress }} Instantiating test packages..."
    julia --project=test -e 'try; using Pkg; Pkg.instantiate(); println("{{ ok }} Instantiated."); catch e; println(stderr, "{{ fail }} Instantiation failed."); exit(1); end'

[doc("Update the package environments")]
[group("dev")]
[script("fish")]
[working-directory(root-dir)]
pkg-update:
    echo "{{ progress }} Updating project packages..."
    julia --project -e 'try; using Pkg; Pkg.update(); println("{{ ok }} Updated."); catch e; println(stderr, "{{ fail }} Update failed."); exit(1); end'
    echo "{{ progress }} Updating documentation packages..."
    julia --project=docs -e 'try; using Pkg; Pkg.update(); println("{{ ok }} Updated."); catch e; println(stderr, "{{ fail }} Update failed."); exit(1); end'
    echo "{{ progress }} Updating test packages..."
    julia --project=test -e 'try; using Pkg; Pkg.update(); println("{{ ok }} Updated."); catch e; println(stderr, "{{ fail }} Update failed."); exit(1); end'

[doc("Resolve the package environments")]
[group("dev")]
[script("fish")]
[working-directory(root-dir)]
pkg-resolve:
    echo "{{ progress }} Resolving project packages..."
    julia --project -e 'try; using Pkg; Pkg.resolve(); println("{{ ok }} Resolved."); catch e; println(stderr, "{{ fail }} Resolving failed."); exit(1); end'
    echo "{{ progress }} Resolving documentation packages..."
    julia --project=docs -e 'try; using Pkg; Pkg.resolve(); println("{{ ok }} Resolved."); catch e; println(stderr, "{{ fail }} Resolving failed."); exit(1); end'
    echo "{{ progress }} Resolving test packages..."
    julia --project=test -e 'try; using Pkg; Pkg.resolve(); println("{{ ok }} Resolved."); catch e; println(stderr, "{{ fail }} Resolving failed."); exit(1); end'
