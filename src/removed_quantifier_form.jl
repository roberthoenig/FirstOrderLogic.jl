export get_removed_quantifier_form

# In "Logik für Informatiker", the removed quantifier form
# is called the "Matrix" of a formula. This has nothing to
# do with the general notion of matrices in mathematics.
function get_removed_quantifier_form(formula::Union{Formula, Term})
    @match formula begin
        f::AFormula || f::EFormula => get_removed_quantifier_form(f.formula)
        f::Conjunction || f::Disjunction => typeof(f)(
            get_removed_quantifier_form(f.formula1),
            get_removed_quantifier_form(f.formula2)
        )
        f::Negation => Negation(
            get_removed_quantifier_form(f.formula)
        )
        f::AtomicFormula || f::Function => typeof(f)(
            f.name,
            get_removed_quantifier_form.(f.arguments)
        )
        f::Variable => f
    end
end
