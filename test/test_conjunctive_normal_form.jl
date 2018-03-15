@testset "get_conjunctive_normal_form" begin
    @test String(get_conjunctive_normal_form(Formula("(P(x) & G(x)) | ~F(y)"))) ==
        "{{G(x), ~F(y)}, {P(x), ~F(y)}}"
    @test String(get_conjunctive_normal_form(Formula("((A() | B()) & ((~(A() & ~C()) | B()) & ((A() & ~C()) | ~B())))"))) ==
        "{{A(), B()}, {C(), B(), ~A()}, {A(), ~B()}, {~C(), ~B()}}"
    @test String(get_conjunctive_normal_form(Formula("((~(~S(8, p) | L(8)) | G(p)) & (~S(1(8), p) | G(p)))"))) ==
        "{{G(p), ~L(8)}, {G(p), ~S(1(8), p)}, {G(p), S(8, p)}}"
end
