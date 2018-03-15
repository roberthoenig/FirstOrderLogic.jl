export get_skolem_normal_form

function get_skolem_normal_form(formula, replacements=Dict{Variable, Function}(), all_quantifiers=Vector{Variable}())
    @match formula begin
    f::AFormula => begin
        push!(all_quantifiers, f.variable)
        AFormula(f.variable, get_skolem_normal_form(f.formula, replacements, all_quantifiers))
    end
    f::EFormula => begin
        replacements[f.variable] = Function(FunctionSymbol(getnextfreesymbol()), all_quantifiers)
        get_skolem_normal_form(f.formula, replacements, all_quantifiers)
    end
    f::Conjunction || f::Disjunction => typeof(f)(get_skolem_normal_form(f.formula1, replacements), get_skolem_normal_form(f.formula2, replacements))
    f::Negation => Negation(get_skolem_normal_form(f.formula, replacements))
    f::AtomicFormula || f::Function => typeof(f)(f.name, get_skolem_normal_form.(f.arguments, (replacements,)))
    f::Variable => begin
        if f in keys(replacements)
            replacements[f]
        else f end
    end
    end
end
