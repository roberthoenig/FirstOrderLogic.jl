export get_prenex_normal_form

function handle_negation(formula)
    result = @match formula begin
    f::AFormula => EFormula(f.variable, handle_negation(f.formula))
    f::EFormula => AFormula(f.variable, handle_negation(f.formula))
    _ => Negation(formula)
    end
    return result
end

function handle_junction(formula1, formula2, junction)
    if typeof(formula1) in (AFormula, EFormula)
        return typeof(formula1)(
            formula1.variable,
            handle_junction(formula1.formula, formula2, junction),
        )
    elseif typeof(formula2) in (AFormula, EFormula)
        return typeof(formula2)(
            formula2.variable,
            handle_junction(formula1, formula2.formula, junction),
        )
    else
        return junction(formula1, formula2)
    end
end

"""
    get_prenex_normal_form(formula)

Return the prenex normal form of `formula`.

The returned formula is logically equivalent to `formula`.
"""
function get_prenex_normal_form(formula)
    prepared_formula = get_renamed_quantifiers_form(formula)
    @match prepared_formula begin
    f::Negation => handle_negation(
        get_prenex_normal_form(f.formula),
    )
    f::Conjunction || f::Disjunction => handle_junction(
        get_prenex_normal_form(f.formula1),
        get_prenex_normal_form(f.formula2), 
        typeof(f),
    )
    _ => return formula
    end
end
