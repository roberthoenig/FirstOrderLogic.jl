@testset "get_prenex_normal_form" begin
    @customtest String(get_prenex_normal_form(Formula("(~?{y}*{g}P(f(y))) & (?{x}P(x) | *{y}P(y))"))) ==
        "*{##5}?{##6}?{##9}*{##10}(~P(f(##5)) & (P(##9) | P(##10)))"
    @customtest String(get_prenex_normal_form(Formula("*{x}?{y}P(x, g(y, f(x))) | ~Q(z) | ~*{x}R(x,y)"))) ==
        "*{##1}?{##2}?{##7}(P(##1, g(##2, f(##1))) | (~Q(z) | ~R(##7, y)))"
end
