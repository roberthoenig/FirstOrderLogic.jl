export get_conjunctive_normal_form

"""
    get_conjunctive_normal_form(formula)

Return `formula` in the conjunctive normal form, expressed as clauses.

`formula` must not contain quantifiers. The returned formula is logically
equivalent to `formula`.
"""
function get_conjunctive_normal_form(formula)
# Ideally, we would use a single @match clause to handle both
# negations and junctions. The negation case is tricky to implement
# in such a unified approach, however, so we generate the CNF in two
# steps.
    function collapse_negations(formula)
        @match formula begin
        f::Negation => begin
            @match f.formula begin
            ff::Negation => collapse_negations(ff.formula)
            ff::Conjunction || ff::Disjunction => begin
                opposite_type = typeof(ff) == Conjunction ? Disjunction : Conjunction
                opposite_type(
                    collapse_negations(Negation(ff.formula1)),
                    collapse_negations(Negation(ff.formula2)),
                    )
                end
            ff::AtomicFormula => f 
            end
        end
        f::Conjunction || f::Disjunction => typeof(f)(
            collapse_negations(f.formula1),
            collapse_negations(f.formula2),
        )
        f::AtomicFormula => f
        _ => throw(TypeError(:collapse_negations, "", Formula, typeof(formula)))
        end
    end
    function expand_disjunctions(formula)
        obj = @match formula begin
        f::Disjunction => begin
            cnf1 = expand_disjunctions(f.formula1)
            cnf2 = expand_disjunctions(f.formula2)
            # Concatenate the clauses in each pair of the cartesian product and
            # return the whole thing as a vector of clauses (that is, in CNF).
            resultcnf = CNF()
            for clause1 in cnf1
                for clause2 in cnf2
                    newclause = union(clause1, clause2)
                    push!(resultcnf, newclause)
                end
            end
            resultcnf
            end
        f::Conjunction => begin
            clauses = union(expand_disjunctions(f.formula1),
                            expand_disjunctions(f.formula2))
            CNF(clauses)
        end
        f::AtomicFormula => CNF([Clause([Literal(false, f)])])
        f::Negation => CNF([Clause([Literal(true, f.formula)])])
        end
        return obj
    end
    collapsed_formula = collapse_negations(formula)
    expand_disjunctions(collapsed_formula)
end
