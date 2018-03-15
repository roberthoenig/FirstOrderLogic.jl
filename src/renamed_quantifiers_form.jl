export get_renamed_quantifiers_form

function get_renamed_quantifiers_form(formula, replacements=Dict{Variable, Variable}())
    @match formula begin
    f::Negation => Negation(
        get_renamed_quantifiers_form(f.formula, copy(replacements)),
    )
    f::Conjunction || f::Disjunction => typeof(f)(
        get_renamed_quantifiers_form(f.formula1, copy(replacements)),
        get_renamed_quantifiers_form(f.formula2, copy(replacements)),
    )
    f::AFormula || f::EFormula => begin
        replacements[f.variable] = Variable(getnextfreesymbol())
        # println("got next symbol, ", replacements[f.variable])
        typeof(f)(
            replacements[f.variable],
            get_renamed_quantifiers_form(f.formula, copy(replacements)),
        )
    end
    f::AtomicFormula || f::Function => begin
        typeof(f)(
            f.name,
            get_renamed_quantifiers_form.(f.arguments, copy(replacements)),
        )
    end
    f::Variable => f in keys(replacements) ? replacements[f] : f
    end
end
