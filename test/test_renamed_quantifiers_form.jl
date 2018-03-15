@testset "get_prenex_normal_form" begin
    @customtest String(get_renamed_quantifiers_form(Formula("(~?{y}*{g}P(f(y, n))) & (?{x}P(x) | *{y}P(y))"))) ==
        "(~?{##1}*{##2}P(f(##1, n)) & (?{##3}P(##3) | *{##4}P(##4)))"
    @customtest String(get_renamed_quantifiers_form(Formula("*{x}?{y}P(x, g(y, f(x))) | ~Q(z) | ~*{x}R(x,y)"))) ==
        "(*{##1}?{##2}P(##1, g(##2, f(##1))) | (~Q(z) | ~*{##3}R(##3, y)))"
end
