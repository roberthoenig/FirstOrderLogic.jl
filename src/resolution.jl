export is_satisfiable

"""
    get_most_general_unifier(unifiables::Set{<:Unifiable})

Returns the most general unifier of `unifiable1` and `unifiable2`.

This is a naive implementation of a unification algorithm. It is supposed to be comprehensible.
"""
function get_most_general_unifier(unifiables::Set{<:Unifiable})
    unifier = Substitution()
    unified = first(unifiables)
    for unifiable in collect(unifiables)[2:end]
        most_general_unifier!(unifier, unified, unifiable)
        substitute(unified, unifier)
    end
    unifier
end

"""
    most_general_unifier!(unifier!::Substitution, unifiable1::Unifiable, unifiable2::Unifiable)

Computes the most general unifier of `unifiable1` and `unifiable2` and stores it in `unifier!`.

This is a naive implementation of a unification algorithm. It is supposed to be comprehensible.
"""
function most_general_unifier!(unifier!::Substitution, unifiable1::Unifiable, unifiable2::Unifiable)
    substituted_unifiable1 = substitute(unifiable1, unifier!)
    substituted_unifiable2 = substitute(unifiable2, unifier!)
    @match substituted_unifiable1 begin
    u1::Literal => begin
        # Two clauses A and B can only be unified if the
        # literals selected for unification in A and B are
        # of opposite negation. This must be verified prior
        # to calling most_general_unifier!(). No validation
        # checks are done here.
        @match substituted_unifiable2 begin
        u2::Literal => begin
            if u1.formula.name == u2.formula.name &&
                length(u2.formula.arguments) == length(u2.formula.arguments)
                most_general_unifier!.([unifier!],
                    u1.formula.arguments, u2.formula.arguments)
            else
                throw(NotUnifiableError())
            end
        end
        end
    end
    u1::Function => begin
        @match substituted_unifiable2 begin
        u2::Function => begin
            if u1.name == u2.name && length(u1.arguments) == length(u2.arguments)
                most_general_unifier!.([unifier!], u1.arguments, u2.arguments)
            else
                throw(NotUnifiableError())
            end
        end
        u2::Variable => begin
            if u2 in get_unbound_variables(u1)
                throw(NotUnifiableError())
            else
                push!(unifier!, u2 => u1)
            end
        end
        end
    end
    u1::Variable => begin
        @match substituted_unifiable2 begin
        u2::Variable => push!(unifier!, u1 => u2)
        u2::Function => begin
            if u1 in get_unbound_variables(u1)
                throw(NotUnifiableError())
            else
                push!(unifier!, u1 => u2)
            end
        end
        end
    end
    end
end

"""
    substitute(formula::Union{Term, Formula, Literal, Clause}, substitution::Substitution)

Return `formula` with all entries in `substitution` applied in order.

A `substitution` entry consists of a variable and a term. An entry is applied by replacing all
occurrences of the variable with the term.
"""
function substitute end

function substitute(formula::Union{Term, Formula, Literal, Clause}, substitution::Substitution)
    substituted_formula = formula
    for (substitutee, substituter) in substitution
        substituted_formula = substitute(substituted_formula, substitutee, substituter)
    end
    substituted_formula
end

function substitute(formula::Union{Term, Formula, Literal, Clause}, substitutee, substituter)
    @match formula begin
    f::CNF => @applyrecursively substitute(:_, substitutee, substituter) f CNF
    f::Clause => @applyrecursively substitute(:_, substitutee, substituter) f Clause
    f::Literal => begin
        Literal(
            f.negative,
            substitute(f.formula, substitutee, substituter)
        )
    end
    f::Negation => Negation(
        substitute(f.formula, substitutee, substituter),
    )
    f::Conjunction || f::Disjunction => typeof(f)(
        substitute(f.formula1, substitutee, substituter),
        substitute(f.formula2, substitutee, substituter),
    )
    f::AtomicFormula || f::Function => begin
        typeof(f)(
            f.name,
            substitute.(f.arguments, substitutee, substituter),
        )
    end
    f::Variable => begin
        f == substitutee ? substituter : f
    end
    end
end

"""
    rename_all_variables(formula, replacements=Dict{Variable, Variable}())

Return `formula` with all variables replace by new, unique names. The returned
formula is logically equivalent to `formula`.

The `replacements` dictionary is for internal use only.
"""
function rename_all_variables(formula, replacements=Dict{Variable, Variable}())
    @match formula begin
    f::Clause => @applyrecursively rename_all_variables(:_, replacements) f Clause
    f::Literal => begin
        Literal(
            f.negative,
            rename_all_variables(f.formula, replacements)
        )
    end
    f::Negation => Negation(
        rename_all_variables(f.formula, replacements),
    )
    f::Conjunction || f::Disjunction => typeof(f)(
        rename_all_variables(f.formula1, replacements),
        rename_all_variables(f.formula2, replacements),
    )
    f::AtomicFormula || f::Function => begin
        typeof(f)(
            f.name,
            rename_all_variables.(f.arguments, replacements),
        )
    end
    f::Variable => begin
        if !(f in keys(replacements))
            replacements[f] = Variable(getnextfreesymbol())
        end
        replacements[f]
    end
    end
end

"""
    get_maybe_unifiable_literals(clause1::Clause, clause2::Clause)

Return a set of clauses that might be unifiable.

Each returned clause consists of literals in `clause1` and literals in
`clause2`. To be considered unifiable, the selected literals in `clause1`
must have the opposite negation of the literals in `clause2`. This function
is used to reduce the search space for literals for the unification algorithm.
"""
function get_maybe_unifiable_literals(clause1::Clause, clause2::Clause)
    maybe_unifiable_literals = Set{Set{Literal}}()
    all_literals = union(clause1, clause2)
    literal_names = Set(map(l -> l.formula.name, all_literals))
    for literal_name in literal_names
        for (c1, c2) in ((clause1, clause2), (clause2, clause1))
            positive_literals_in_c1 =
                filter(l -> l.formula.name == literal_name && !l.negative, c1)
            negative_literals_in_c2 =
                filter(l -> l.formula.name == literal_name && l.negative, c2)
            positive_literals_combinations = powerset(positive_literals_in_c1)
            negative_literals_combinations = powerset(negative_literals_in_c2)
            for positive_literals in positive_literals_combinations
                for negative_literals in negative_literals_combinations
                    if length(positive_literals) > 0 && length(negative_literals) > 0
                        push!(maybe_unifiable_literals,
                              union(positive_literals, negative_literals))
                    end
                end
            end
        end
    end
    maybe_unifiable_literals
end

"""
    is_satisfiable(formula; maxsearchdepth)

Check if `formula` is satisfiable.

If `formula` is unsatisfiable, this function will return `false` in finite time.
If `formula` is satisfiable, this function may run forever. This behavior stems
from the fundamental limit that the satisfiability problem for first-order logic
is semidecidable. The `maxsearchdepth` parameter allows you to work around this
limitation by specifying the maximum expansion depth of the resolution algorithm
search tree. If the algorithm exceeds that limit, it throws an OverMaxSearchDepthError
exception.
"""
function is_satisfiable end

function is_satisfiable(clauses::CNF; maxsearchdepth=Inf)
    if maxsearchdepth == 0
        throw(OverMaxSearchDepthError())
    end
    renamed = rename_all_variables.(collect(clauses))
    clauses = CNF(renamed)
    newclauses = CNF()
    for clause1 in clauses
        for clause2 in clauses
            groups_of_maybe_unifiable_literals = get_maybe_unifiable_literals(clause1, clause2)
            for maybe_unifiable_literals in groups_of_maybe_unifiable_literals
                try
                    unifier = get_most_general_unifier(maybe_unifiable_literals)
                    newclause = setdiff(union(clause1, clause2), maybe_unifiable_literals)
                    substituted_newclause = substitute(newclause, unifier)
                    push!(newclauses, substituted_newclause)
                catch
                    continue
                end
            end
        end
    end
    union!(clauses, newclauses)
    if Clause([]) in clauses
        false
    else
        is_satisfiable(clauses, maxsearchdepth=maxsearchdepth-1)
    end
end

function is_satisfiable(formula::Formula; maxsearchdepth=Inf)
    is_satisfiable(
        get_conjunctive_normal_form(
            get_removed_quantifier_form(
                get_skolem_normal_form(
                    get_prenex_normal_form(
                        get_quantified_variables_form(
                            get_renamed_quantifiers_form(
                                formula)))))),
        maxsearchdepth=maxsearchdepth
    )
end

is_satisfiable(formula::String; maxsearchdepth=Inf) =
    is_satisfiable(Formula(formula), maxsearchdepth=maxsearchdepth)
