using Base.Test
# import Base.Test: record, finish
# using Base.Test: AbstractTestSet, Result, Pass, Fail, Error
# using Base.Test: get_testset_depth, get_testset
# using Base.Test

# export FirstOrderLogicTest

# type FirstOrderLogicTest <: AbstractTestSet
#     description::AbstractString
#     executed_tests::Int
#     results::Vector
#     FirstOrderLogicTest(description::String, executed_tests=0) =
#         new(description, executed_tests, [])
# end

# record(ts::FirstOrderLogicTest, child::AbstractTestSet) = push!(ts.results, child)
# record(testset::FirstOrderLogicTest, result::Result) = begin
#     testset.executed_tests += 1
#     push!(testset.results, result)
#     println("$(testset.executed_tests): $(result.orig_expr)")
#     resetfreesymbols()
# end

# function finish(ts::FirstOrderLogicTest)
#     # just record if we're not the top-level parent
#     if get_testset_depth() > 0
#         record(get_testset(), ts)
#     end
#     ts
# end

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