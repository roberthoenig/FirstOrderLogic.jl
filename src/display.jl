export displayproof,
    prove

function displayproof(clauses::CNF, proof::Vector{ResolutionStep})
    facts = collect(clauses)
    println("\nFacts:")
    for (index, fact) in enumerate(facts)
        println("$(index): $(String(Formula(fact)))")
    end
    println("\nResolution:")
    for (index, step) in enumerate(proof)
        @debug String(step.resolver1)
        @debug String(step.resolver2)
        r1 = Dict()
        r2 = Dict()
        pos1 = findfirst((item)->isequivalent(item, step.resolver1, r1), facts)
        pos2 = findfirst((item)->isequivalent(item, step.resolver2, r2), facts)
        r1 = Dict(zip(values(r1), keys(r1)))
        r2 = Dict(zip(values(r2), keys(r2)))
        @debug r1
        @debug r2
        unifier = Substitution(map((u)->get(r1, u.first, u.first)=>get(r2, u.second, u.second), step.unifier))
        @debug pos1
        @debug pos2
        resolvent = step.resolvent
        println("$(index+length(facts)): Resolve $(pos1) and $(pos2) with the unifier $(String(unifier)) to $(String(resolvent)).")
        push!(facts, resolvent)
    end
    println("\nProof complete.")
end

function prove(formula::Formula)

end

prove(formula::String) = prove(Formula(formula))
