export is_satisfiable

function get_most_general_unifier(unifiables::Set{<:Unifiable})
    unifier = Substitution()
    unified = first(unifiables)
    for unifiable in collect(unifiables)[2:end]
        most_general_unifier!(unifier, unified, unifiable)
        substitute(unified, unifier)
    end
    unifier
end

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

# Apply substitution in order.
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