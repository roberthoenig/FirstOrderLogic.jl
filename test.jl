using FirstOrderLogic
formula = "∀x(P(x) ∧ ¬P(x))"
cnf = get_conjunctive_normal_form(
                          get_removed_quantifier_form(
                              get_skolem_normal_form(
                                  get_prenex_normal_form(
                                      get_quantified_variables_form(
                                          get_renamed_quantifiers_form(
                                              Formula(formula)))))))
proof = is_satisfiable("∀x(P(x) ∧ ¬P(x))", getproof=true)
displayproof(cnf, proof)

