function testsatisfiability(formula, issatisfiable; maxsearchdepth=5)
    if issatisfiable == false
        @customtest is_satisfiable(formula, maxsearchdepth=maxsearchdepth) == false
    else
        @customtest_throws OverMaxSearchDepthError is_satisfiable(formula, maxsearchdepth=maxsearchdepth)
    end
end

@testset "is_satisfiable" begin
    # Basic tests, easy to verify by hand.
    testsatisfiability("P(x) ∧ ¬P(x)", false)
    testsatisfiability("P(x) & ~P(y)", true)
    testsatisfiability("(P(x) & ~P(y)) & (~P(x) & P(y))", false)
    testsatisfiability("(P(x) & ~P(y)) ∨ (C(y) & ~C(y))", true)
    testsatisfiability("A() & (B() | ~C()) & ~B() & C()", false)
    testsatisfiability("*{x}(P(x) & ~P(f(x)))", false)
    testsatisfiability("(S(x,p) | G(p)) & (~L(x) | G(p)) & (~S(x,p)) & (~G(p))", false)
    testsatisfiability("(S(x,p) | G(p)) & (~L(x) | G(p))", true)

    # Test based on "Logik für Informatiker", exercise 76.
    testsatisfiability(CNF([
        Clause([Literal(false, Formula("S(x,p)")), Literal(false, Formula("G(p)"))]),
        Clause([Literal(true, Formula("L(x)")), Literal(false, Formula("G(p)"))]),
        Clause([Literal(true, Formula("S(x,p)"))]),
        Clause([Literal(true, Formula("G(p)"))]),
        ]), false)

    # Test based on "Logik für Informatiker", exercise 76.
    testsatisfiability("(*{x}(S(x, p) > L(x)) > G(p)) & ((~?{x}S(x,p)) & (~G(p)))", false)

    # Test based on "Logik für Informatiker", exercise 76.
    testsatisfiability("(*{x}(S(x, p) > L(x)) > G(p)) & ((~?{x}S(x,p)) & (G(p)))", true)

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
