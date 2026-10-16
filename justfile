set shell := ["bash", "-cu"]
set dotenv-load

[doc("Default recipe shows available commands")]
[private]
default:
    @just --list

set script-interpreter := ["julia", "--color", "yes", "--project"]

root-dir := justfile_directory()

hint := BLUE + "" + NORMAL
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

[doc("""
Internal: ensure a GitHub token is available for remote metadata.
Priority:
1. GITHUB_TOKEN environment variable
2. gh CLI (via `gh auth token`)
""")]
[group("release")]
[private]
[script("fish")]
_gh-authenticated:
    if not type -q gh
        echo "{{ fail }} GITHUB_TOKEN is not set and gh CLI is not installed." >&2
        echo "{{ hint }} Install gh and run: gh auth login" >&2
        exit 1
    end
    if not gh auth status &>/dev/null
        echo "{{ fail }} gh CLI is not authenticated. Run: gh auth login" >&2
        exit 1
    end

[doc("Regenerate CHANGELOG.md with enriched GitHub metadata.")]
[group("release")]
[script("fish")]
changelog: _gh-authenticated
    if not set -q GITHUB_TOKEN
        set -gx GITHUB_TOKEN (gh auth token)
    end
    git-cliff -o CHANGELOG.md
    if test $status -eq 0
        echo "{{ ok }} CHANGELOG.md generated." >&2
        echo "{{ hint }} Review the changes, then stage and commit if needed." >&2
    else
        echo "{{ fail }} CHANGELOG.md generation failed." >&2
    end

[arg("semantic-bump", pattern="patch|minor|major")]
[doc("Bump version, update changelog, tag, and open a Registrator.jl issue")]
[group("release")]
[script("fish")]
[working-directory(root-dir)]
register semantic-bump="patch": _gh-authenticated
    if not set -q GITHUB_TOKEN
        set -gx GITHUB_TOKEN (gh auth token)
    end

    set tag_version (git-cliff --bumped-version --bump {{ semantic-bump }})
    set pkg_version (string replace -r '^v' '' -- $tag_version)
    set branch (git branch --show-current)

    echo "{{ progress }} Bumping Project.toml version to $version ($tag_version)..."
    sed -i -E "s/^version = \".*\"/version = \"$pkg_version\"/" Project.toml
    echo "{{ ok }} Project.toml updated to $pkg_version."

    echo "{{ progress }} Generating CHANGELOG.md..."
    git-cliff --bump {{ semantic-bump }} -o CHANGELOG.md
    echo "{{ ok }} CHANGELOG.md updated."

    set release_notes (git-cliff --bump {{ semantic-bump }} --unreleased | string collect)

    echo "{{ progress }} Committing and tagging $tag_version..."
    git add Project.toml CHANGELOG.md
    git commit -m "chore(release): prepare for $tag_version"
    git tag -a $tag_version -m "Release $tag_version"
    git push origin $branch --follow-tags
    echo "{{ ok }} Pushed commit and tag $tag_version to $branch."

    echo "{{ progress }} Creating GitHub registration issue..."
    set issue_body (printf "@JuliaRegistrator register branch=%s\n\nRelease notes:\n\n%s\n" "$branch" "$release_notes" | string collect)
    gh issue create --title "Register $tag_version" --body "$issue_body"
    echo "{{ ok }} Registration issue created for $tag_version."
