@testset "get_removed_quantifier_form" begin
    @customtest String(get_removed_quantifier_form(Formula("(Q(x) | ?{x}*{y}(P(f(x),z) & Q(a))) | *{z}R(x,z,g(x)))"))) ==
        "((Q(x) | (P(f(x), z) & Q(a))) | R(x, z, g(x)))"
    @customtest String(get_removed_quantifier_form(Formula("(?{x}*{y}Foo(bar, baz)) & *{abc}~B(abc)"))) ==
        "(Foo(bar, baz) & ~B(abc))"
end
