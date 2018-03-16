| **Linux** | **Windows** | **Coverage** |
|:-----------------:|:----------------:|:----------------:|
| [![][travis-img]][travis-url] | [![][appveyor-img]][appveyor-url] | [![][codecov-img]][codecov-url] |

# FirstOrderLogic.jl

This is a Julia package for parsing, manipulating and evaluating formulas in first-order logic.

## Overview

`FirstOrderLogic.jl` follows the standard structure for Julia projects.

### Functionality

`FirstOrderLogic.jl` currently provides the following:

* An intuitive type system for formulas in first-order logic.

* Various methods for converting formulas in special forms:
    * prenex normal form
    * skolem normal form
    * conjunctive normal form
    * ...

* A prover for formulas in first-order logic.

### Purpose

`FirstOrderLogic.jl` may prove useful for the following:

* Easily verifying the unsatisfiability of short formulas in first-order logic.
    * The `is_satisfiable()` function is made for this very purpose.

* Learning basic first-order logic concepts and algorithms.
    * The whole code base is well-designed and documented.

* *Coming soon!* Quickly verifying the unsatisfiability of long formulas in first-order logic.
    * A highly optimized, parallelizable version of `is_satisfiable()` is in progress.

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
* Syntax: PROLOG code is written in in facts. These facts represent horn clauses. In doing so,
  PROLOG hides the first-order logic syntax from the user. This proves convenient for real
  world applications, but it's not mathematically pure. `FirstOrderLogic.jl` uses a direct
  mathematical syntax for expressing formulas.
* Expressive power: PROLOG works on a limited set of all valid formulas in first-order logic, namely
  only formulas that can be expressed as a conjunction of [horn clauses](https://en.wikipedia.org/wiki/Horn_clause). This is sufficient for many real world applications,
  but it's not mathematically complete. PROLOG thereby trades completeness for computation time.
  `FirstOrderLogic.jl` does not make that trade. It is slow, but complete.

[codecov-img]: https://codecov.io/gh/roberthoenig/FirstOrderLogic.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/roberthoenig/FirstOrderLogic.jl
[travis-img]: https://travis-ci.org/roberthoenig/FirstOrderLogic.jl.svg?branch=master
[travis-url]: https://travis-ci.org/roberthoenig/FirstOrderLogic.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/rn8exp4696vo9co5/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/roberthoenig/firstorderlogic-jl/branch/master
