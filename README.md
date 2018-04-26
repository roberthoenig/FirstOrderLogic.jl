[FirstOrderLogic.jl](#firstorderlogicjl) | [Overview](#overview) | [Installation](#installation) | [Usage](#usage) | [Why not PROLOG?](#how-is-this-different-from-prolog) | [Roadmap](#roadmap)


# FirstOrderLogic.jl

This is a Julia package for parsing, manipulating and evaluating formulas in first-order logic.
It may prove useful to
* the mathematician who wants to quickly verify a formula and enter it in plain mathematical notation.
* the student studying first order logic and despairing over his homework.
* the programmer looking for a clean implementation of first-order logic algorithms.

For example, to check if `∀x(P(x) ∧ ¬P(f(x)))` is unsatisfiable, run
```
is_satisfiable("*{x}(P(x) & ~P(f(x)))")
```

## Overview

| **Linux** | **Windows** | **Coverage** |
|:-----------------:|:----------------:|:----------------:|
| [![][travis-img]][travis-url] | [![][appveyor-img]][appveyor-url] | [![][codecov-img]][codecov-url] |

`FirstOrderLogic.jl` follows the standard structure for Julia projects.
Currently, it provides the following:

* An intuitive type system for formulas in first-order logic.

* Various methods for converting formulas in special forms:
    * prenex normal form
    * skolem normal form
    * conjunctive normal form
    * ...

* A prover for formulas in first-order logic.

## Installation

1. Run
```
julia
```
2. In your Julia shell, run
```
Pkg.clone("git@github.com:roberthoenig/FirstOrderLogic.jl.git")
```

## Usage

### Quick walkthrough

Say we have a formula `∀x(P(x) ∧ ¬P(f(x)))`. We want to verify that this formula is unsatisfiable.
To do so, we do the following:
1. Type the formula in `FirstOrderLogic.jl` syntax: `*{x}(P(x) & P(f(x)))`.
2. Run
```
julia
```
3. Import `FirstOrderLogic.jl`:
```
using FirstOrderLogic
```
4. Run `is_satisfiable(<our formula>)`:
```
is_satisfiable("*{x}(P(x) & ~P(f(x)))")
```
If everything works correctly, the program should print "false" and terminate. This means that `∀x(P(x) ∧ ¬P(f(x)))`
is unsatisfiable. We have verified what we wanted to verify.

### Formula syntax

`FirstOrderLogic.jl` currently uses its own syntax for representing formulas
in first-order logic. A parser for latex symbols is in progress.

The following is a list of all currently supported syntactic elements.

| Mathematical syntax | `FirstOrderLogic.jl` syntax | Semantic |
| ------------------- |:------------------------:| --------:|
  x                   | x                        | variable
  f(x,y)              | f(x,y)                   | function
  f(x,y)              | f(x,y)                   | predicate
  ∃x                  | ?{x}                     | existential quantification
  ∀x                  | *{x}                     | universal quantification
  ¬x                  | ~x                       | negation
  x ∧ y               | x & y                    | conjunction
  x ∨ y               | x &#124; y               | disjunction
  x → y               | x > y                    | implication
  (x ∧ y) ∨ z         | (x & y) | z              | precedence grouping

#### Example

Formula in mathematical notation:
```
∀x∃yA(x,g(y,z)) ∧ (¬B() ∨ ∃dC(d))
```
The same formula in `FirstOrderLogic.jl` notation:
```
*{x}?{y}A(x,g(y,z)) & (~B() | ?{d}C(d))
```

### Some important functions

| Function | Purpose |
|:--------:|:-------:|
 `is_satisfiable(formula; maxsearchdepth)` | Checks if `formula` is satisfiable.
 `get_conjunctive_normal_form(formula)` | Returns `formula` in the conjunctive normal form, expressed as clauses.
 `get_prenex_normal_form(formula)` | Returns the prenex normal form of `formula`.
 `get_skolem_normal_form(formula)` | Returns the skolem normal form of `formula`.
 `Formula(str)` | Parse str to a `Formula` object and return that object.

Each available function comes with a concise docstring.

## How is this different from PROLOG?

The PROLOG programming language can be used to prove seemingly arbitrary statements in first-order logic. PROLOG differs from `FirstOrderLogic.jl` in two ways:
* Syntax: PROLOG code is written in facts. These facts represent horn clauses. In doing so,
  PROLOG hides the first-order logic syntax from the user. This proves convenient for real
  world applications, but it's not mathematically pure. `FirstOrderLogic.jl` uses a direct
  mathematical syntax for expressing formulas.
* Expressive power: PROLOG works on a limited set of all valid formulas in first-order logic, namely
  only formulas that can be expressed as a conjunction of [horn clauses](https://en.wikipedia.org/wiki/Horn_clause). This is sufficient for many real world applications,
  but it's not mathematically complete. PROLOG thereby trades completeness for computation time.
  `FirstOrderLogic.jl` does not make that trade. It is slow, but complete.

## Roadmap

The following features are work in progress:
* A highly optimized, parallelizable version of the satisfiability checker `is_satisfiable()`.
* A deadsimple webapp for the satisfiability checker `is_satisfiable()`.

Any and all external contributions are most welcome!

[codecov-img]: https://codecov.io/gh/roberthoenig/FirstOrderLogic.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/roberthoenig/FirstOrderLogic.jl
[travis-img]: https://travis-ci.org/roberthoenig/FirstOrderLogic.jl.svg?branch=master
[travis-url]: https://travis-ci.org/roberthoenig/FirstOrderLogic.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/rn8exp4696vo9co5/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/roberthoenig/firstorderlogic-jl/branch/master
