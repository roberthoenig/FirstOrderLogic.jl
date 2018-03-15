export get_quantified_variables_form,
    get_unbound_variables

"""
    get_quantified_variables_form(formula)

Return `formula` with all unbound variables bound to existential quantifiers.

The returned formula is equisatisfiable with `formula`.
"""
function get_quantified_variables_form(formula)
    variables = get_unbound_variables(formula)
    quantified_variables_form = formula
    for variable in variables
        quantified_variables_form = EFormula(variable, quantified_variables_form)
    end
    quantified_variables_form
end

function get_unbound_variables(formula, boundvars=Set{Variable}())
    @match formula begin
    f::Conjunction || f::Disjunction => begin
        unboundvars = get_unbound_variables.([f.formula1, f.formula2], boundvars)
        union(unboundvars...)
    end
    f::Negation => get_unbound_variables(f.formula, boundvars)
    f::AFormula || f::EFormula => begin
        push!(boundvars, f.variable)
        unboundvars = get_unbound_variables(f.formula, boundvars)
        pop!(boundvars, f.variable)
        unboundvars
    end
    f::AtomicFormula || f::Function => union(get_unbound_variables.(f.arguments, boundvars)...)
    f::Variable => f in boundvars ? Set() : Set([f]) 
    end
end
