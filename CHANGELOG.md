# Changelog

## [0.3.0] - 2026-10-15

### 🚀 Features

- *(docs)* Add favicon to the documentation page by @kunzaatko

- *(docs)* Collapse the docstrings by @kunzaatko

- *(check)* Add `throw_error` keyword argument by @kunzaatko

- *(release)* Automate versioned package registration


### 🐛 Bug Fixes

- *(CI)* Remove the unnecessary develop of the package by @kunzaatko

- *(docs)* Falsely documented `ZebraPuzzle` as a function instead of type by @kunzaatko

- *(test)* Avoid duplicate clues in test for MinimalityViolation by @kunzaatko

- Update PrettyTables and warn when solution given with `solve!` is not unique by @kunzaatko


### 💼 Other

- Support Julia 1.12 by @kunzaatko

- Add Just recipes for documentation generation by @kunzaatko

- *(docs)* Add recipe to build and open documentation by @kunzaatko

- Configure Julia workspace and support Julia 1.13 by @kunzaatko

- Add Just recipes for tests and Julia environments by @kunzaatko


### 🚜 Refactor

- Remove the `;` from doctestsetup by @kunzaatko


### 📚 Documentation

- *(README)* Add a demo and some basic information about the package by @kunzaatko

- Add more examples with failing `solve!` and `show_solution` without solution by @kunzaatko

- *(README)* Update the example with output by @kunzaatko

- Clarify README usage headings by @kunzaatko

- Add project changelog


### 🧪 Testing

- Update doctest platform skip condition by @kunzaatko

- Run doctests in CI only by @kunzaatko


### ⚙️ Miscellaneous Tasks

- *(deps)* Move Julia updates to Dependabot by @kunzaatko

- Drop architecture matrix and adjust doctest gating by @kunzaatko

- Set CI matrix architecture to x64 by @kunzaatko

- Simplify Julia test matrix configuration by @kunzaatko

- Test on x64 and aarch64 architectures by @kunzaatko


## [0.2.3] - 2025-08-06

### 🐛 Bug Fixes

- *(CI)* Update the action versions and fix the julia matrix versions by @kunzaatko

- *(docs)* Fix undefined variable in examples by @kunzaatko

- *(compat)* Add compat entries for compatible standard packages by @kunzaatko

- Compat with InterfaceFunctions by @kunzaatko

- *(CI)* Diagram generation by @kunzaatko


### 📚 Documentation

- *(README)* Add logo to README by @kunzaatko

- Add docstrings to Question methods by @kunzaatko


### ⚙️ Miscellaneous Tasks

- *(CI)* Add cliff.toml by @kunzaatko

- Update Project.toml sources section by @kunzaatko

- *(compat)* Add compat 1.10 for Random by @kunzaatko

- *(release)* Bump patch version by @kunzaatko


## [0.2.2] - 2025-07-15

### 🚀 Features

- *(puzzle)* Add question-to-clue conversion and puzzle answering by @kunzaatko


### 🐛 Bug Fixes

- *(questions)* Answer and added tests by @kunzaatko


### ⚙️ Miscellaneous Tasks

- *(release)* Bump patch version by @kunzaatko


## [0.2.1] - 2025-07-14

### 🐛 Bug Fixes

- *(question)* House attribute questions could be confused with position questions by @kunzaatko

- *(attributes)* "Lucky Strike" -> "Lucky Strikes" by @kunzaatko


### ⚙️ Miscellaneous Tasks

- Bump patch version by @kunzaatko


## [0.2.0] - 2025-07-14

### 🚀 Features

- Initial working version with all the necessary function and tests by @kunzaatko

- Add puzzle questioning framework and refine display logic by @kunzaatko

- *(docs)* Improve getting started guide and API reference by @kunzaatko

- Constructor for unsorted linked attributes in SolvedZebraPuzzle by @kunzaatko

- *(random)* Make random work for a specific `K`, `N` unsolved zebra puzzle by @kunzaatko

- Add questions for the puzzles by @kunzaatko

- Add `answer` method + allow construction with `questions` and `clues` by @kunzaatko


### 🐛 Bug Fixes

- *(compat)* Leaner SemVer compat by @kunzaatko

- `riddle` function needs `K` type parameter by @kunzaatko


### 🚜 Refactor

- Remove the `riddle_string` function and export the `ZebraPuzzle` subtypes by @kunzaatko


### 📚 Documentation

- Improve the "quick start" documentation by @kunzaatko

- Add emoji to the sections by @kunzaatko


### ⚙️ Miscellaneous Tasks

- Bump compat for `InterfaceFunctions` and minor version by @kunzaatko


## [0.1.0] - 2025-06-23


