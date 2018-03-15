@testset "parser" begin
    function test_str_to_formula_to_str(formula::String)
        @customtest String(Formula(formula)) == formula
    end
    test_str_to_formula_to_str("(P(f(x), g(y)) & G(f(x)))")
    test_str_to_formula_to_str("~*{x}Foo(x)")
    test_str_to_formula_to_str("~~(*{y}Foo(x) | Bar(f(x), g(f(y), f(h, u))))")
    test_str_to_formula_to_str("(~?{y}*{g}P(f(y)) & (?{x}P(x) | *{y}P(y)))")
end
