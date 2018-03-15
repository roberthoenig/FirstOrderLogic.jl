function get_normalized_form(formula::String)
    get_conjunctive_normal_form(
        get_removed_quantifier_form(
            get_skolem_normal_form(
                get_prenex_normal_form(
                    get_quantified_variables_form(
                        get_renamed_quantifiers_form(
                            Formula(formula)))))))
end

function testsatisfiability(formula, issatisfiable; maxsearchdepth=5)
    if issatisfiable == false
        @customtest is_satisfiable(formula, maxsearchdepth=maxsearchdepth) == false
    else
        @customtest_throws OverMaxSearchDepthError is_satisfiable(formula, maxsearchdepth=maxsearchdepth)
    end
end

@testset "is_satisfiable" begin
    # Basic tests, easy to verify by hand.
    testsatisfiability(get_normalized_form("P(x) & ~P(x)"), false)
    testsatisfiability(get_normalized_form("P(x) & ~P(y)"), true)
    testsatisfiability(get_normalized_form("(P(x) & ~P(y)) & (~P(x) & P(y))"), false)
    testsatisfiability(get_normalized_form("(P(x) & ~P(y)) | (C(y) & ~C(y))"), true)
    testsatisfiability(get_normalized_form("A() & (B() | ~C()) & ~B() & C()"), false)
    testsatisfiability(get_normalized_form("*{x}(P(x) & ~P(f(x)))"), false)
    testsatisfiability(get_normalized_form("(S(x,p) | G(p)) & (~L(x) | G(p)) & (~S(x,p)) & (~G(p))"), false)
    testsatisfiability(get_normalized_form("(S(x,p) | G(p)) & (~L(x) | G(p))"), true)

    # Test based on "Logik für Informatiker", exercise 76.
    testsatisfiability(CNF([
        Clause([Literal(false, Formula("S(x,p)")), Literal(false, Formula("G(p)"))]),
        Clause([Literal(true, Formula("L(x)")), Literal(false, Formula("G(p)"))]),
        Clause([Literal(true, Formula("S(x,p)"))]),
        Clause([Literal(true, Formula("G(p)"))]),
        ]), false)

    # Test based on "Logik für Informatiker", exercise 76.
    testsatisfiability(get_normalized_form("((~*{x}(~S(x, p) | L(x))) | G(p)) & ((~?{x}S(x,p)) & (~G(p)))"), false)

    # Test based on "Logik für Informatiker", exercise 76.
    testsatisfiability(get_normalized_form("((~*{x}(~S(x, p) | L(x))) | G(p)) & ((~?{x}S(x,p)) & (G(p)))"), true)

    # Test based on "Logik für Informatiker", exercise 80.
    testsatisfiability(CNF([
        Clause([Literal(false, Formula("P(u,u)"))]),
        Clause([Literal(true, Formula("P(f(x), x)"))])]), true)

    # Test based on "Logik für Informatiker", exercise 85.
    testsatisfiability(CNF([
        Clause([Literal(true, Formula("B(x)")), Literal(false, Formula("R(y,y)")), Literal(false, Formula("R(x,y)"))]),
        Clause([Literal(true, Formula("B(z)")), Literal(true, Formula("R(u,u)")), Literal(true, Formula("R(z,u)"))]),
        Clause([Literal(false, Formula("B(a)"))]),
        ]), false)

    # Test based on "Logik für Informatiker", exercise 85.
    testsatisfiability(CNF([
        Clause([Literal(true, Formula("B(x)")), Literal(false, Formula("R(y,y)")), Literal(false, Formula("R(x,y)"))]),
        Clause([Literal(true, Formula("B(z)")), Literal(true, Formula("R(u,u)")), Literal(true, Formula("R(z,u)"))]),
        Clause([Literal(true, Formula("B(a)"))]),
    ]), true, maxsearchdepth=3)
end
