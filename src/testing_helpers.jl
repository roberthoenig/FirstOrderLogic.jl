using Base.Test

export @customtest,
    @customtest_throws

#=
customtest and customtest_throws are wrappers around the normal
@test and @test_throws macros. They ensure that the test execution
is independent of the test order by resetting the interal package state.
Currently, the internal package state consists only of the next free
symbol.
=#

macro customtest(test)
    quote
    resetfreesymbols()
    @test $(esc(test))
    resetfreesymbols()
    end
end

macro customtest_throws(exception, test)
    quote
    resetfreesymbols()
    @test_throws $(esc(exception)) $(esc(test))
    resetfreesymbols()
    end
end