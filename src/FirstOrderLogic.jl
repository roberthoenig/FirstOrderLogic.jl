__precompile__()
module FirstOrderLogic

using AutoHashEquals
using Match

# Declarative and supportive code.
include("types.jl")
include("helpers.jl")
include("testing_helpers.jl")

# Workhorse code.
include("parser.jl")
include("renamed_quantifiers_form.jl")
include("quantified_variables_form.jl")
include("prenex_normal_form.jl")
include("skolem_normal_form.jl")
include("conjunctive_normal_form.jl")
include("removed_quantifier_form.jl")
include("resolution.jl")

end
