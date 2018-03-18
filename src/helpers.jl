export @debug,
    powerset,
    getnextfreesymbol,
    resetfreesymbols

function bracketsplit(str)
    parts = []
    part_start = 1
    bracket_balance = 0
    for idx in eachindex(str)
        bracket_balance += @match str[idx] begin
        '(' => -1
        ')' => 1
        _ => 0
        end
        if bracket_balance == 0
            next_part = nextind(str, idx)
            push!(parts, str[part_start:next_part-1])
            part_start = next_part
        end 
    end
    parts
end

function argumentsplit(str)
    parts = strip.(bracketsplit(str))
    comma = findfirst(parts, ",")
    if comma == 0
        [str]
    else
        arguments = [join(parts[1:comma-1])]
        while comma != 0
            next_comma = findnext(parts, ",", comma+1)
            if next_comma == 0
                push!(arguments, join(parts[comma+1:end]))
            else
                push!(arguments, join(parts[comma+1:next_comma-1]))
            end
            comma = next_comma
        end
        arguments
    end
end

function strip_and_remove_surrounding_brackets(str)
    str = strip(str)
    while length(bracketsplit(str)) == 1 && str[1] == '('
        str = str[2:end-1]
    end
    str
end

"""
    powerset(x)

Returns the powerset of x (a set of all subsets of x).
"""
function powerset(x)
    result = [Set()]
    for element in collect(x), idx = 1:length(result)
        newsubset = union(result[idx], Set([element]))
        push!(result, newsubset)
    end
    Set(result)
end

# Currently, Julia's multiple dispatch system only dispatches on the expression type for
# macros (which is most of the times Expr or Symbol). To do multiple dispatch here, we
# therefore have to work around that limitation by using the hack below. This might change
# if https://github.com/JuliaLang/julia/issues/20929 gets addressed.
macro applyrecursively(functionexpr, objectexpr, objecttype)
    typemapping = Dict(
        :CNF => :collection,
        :Clause => :collection,
        :Conjunction => :monotone_fields,
        :Negation => :monotone_fields,
        )
        dispatch_applyrecursively(functionexpr, objectexpr, Val{typemapping[objecttype]})
    end
    
function dispatch_applyrecursively(functionexpr, objectexpr,
                                    objecttype::Type{Val{:collection}})
    fsymbol, fargs = functionexpr.args[1],
                     functionexpr.args[2:end]
    quote
        obj = $(esc(objectexpr))
        typeof(obj)(
            [$fsymbol([arg == :_ ? element : arg
                       for arg in [$(esc.(fargs)...)]]...)
             for element in obj]
        )
    end
end

"""
    @debug variable

Print the symbol `variable`, followed by its value, followed by an empty line.
"""
macro debug(variable)
    Expr(:call,
         :println,
         Expr(:call,
              :string,
              Expr(:quote, variable)),
         " ",
         esc(variable),
        "\n"
        )
end


"""
    getnextfreesymbol()

Returns a new, unique string that can be used
for naming objects.

This does not check if a user-entered formula
already contains the returned string.
"""
function getnextfreesymbol end

"""
    resetfreesymbols()

Resets the free symbol state.

Newly generated symbols will "start over".
"""
function resetfreesymbols end

let nextfreesymbol = 0
    global getnextfreesymbol
    global resetfreesymbols
    function getnextfreesymbol()
        nextfreesymbol += 1
        string("##", nextfreesymbol)
    end
    function resetfreesymbols()
        nextfreesymbol = 0
    end
end
