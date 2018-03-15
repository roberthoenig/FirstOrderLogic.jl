@testset "get_quantified_variables_form" begin
    @customtest String(get_quantified_variables_form(Formula("*{foo}P(foo(foo), foo, bar) & E(baz, bar)"))) ==
        "?{baz}?{bar}(*{foo}P(foo(foo), foo, bar) & E(baz, bar))"
    @customtest String(get_quantified_variables_form(Formula("*{x}?{y}*{z}?{w}(~P(a, w) | Q(f(x), y))"))) ==
        "?{a}*{x}?{y}*{z}?{w}(~P(a, w) | Q(f(x), y))"
end
