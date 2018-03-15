using Base.Test

export @customtest,
    @customtest_throws

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