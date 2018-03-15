@testset "get_skolem_normal_form" begin
    @customtest String(get_skolem_normal_form(Formula("*{5}*{1}?{2}?{3}*{4}(~P(f(1)) & (P(3) | P(4, f(2, 3))))"))) ==
        "*{5}*{1}*{4}(~P(f(1)) & (P(##2(5, 1)) | P(4, f(##1(5, 1), ##2(5, 1)))))"
    @customtest String(get_skolem_normal_form(Formula("*{x}?{y}*{z}?{w}(~P(a, w) | Q(f(x), y))"))) ==
        "*{x}*{z}(~P(a, ##2(x, z)) | Q(f(x), ##1(x)))"
end
