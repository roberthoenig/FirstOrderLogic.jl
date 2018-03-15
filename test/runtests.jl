using FirstOrderLogic
using Base.Test

include("test_parser.jl")
include("test_renamed_quantifiers_form.jl")
include("test_quantified_variables_form.jl")
include("test_prenex_normal_form.jl")
include("test_skolem_normal_form.jl")
include("test_removed_quantifier_form.jl")
include("test_conjunctive_normal_form.jl")
include("test_resolution.jl")
