export isequivalent

function isequivalent(c1::Clause, c2::Clause, replacements=Dict{Variable, Variable}())
    for literal1 in c1
        for literal2 in c2
            @debug String(literal1)
            @debug String(literal2)
            ie = isequivalent(Formula(literal1), Formula(literal2), deepcopy(replacements))
            @debug ie
            if ie
                isequivalent(Formula(literal1), Formula(literal2), replacements)
                delete!(c2, literal2)
                break
            end
        end
    end
    length(c2) == 0
end

function isequivalent(f1, f2, replacements=Dict{Variable, Variable}())
    if typeof(f1) == typeof(f2)
        @match f1 begin
        f1::Negation => isequivalent(f1.formula, f2.formula, replacements)
        f1::AtomicFormula || f1::Function => begin
            if f1.name != f2.name
                false
            else
                all(isequivalent.(f1.arguments, f2.arguments, replacements))
            end
        end
        f1::Variable => begin
            if !haskey(replacements, f1)
                replacements[f1] = f2
            end
            replacements[f1] == f2
        end
        end
    else
        false
    end
end
