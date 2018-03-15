export Term,
    Formula,
    PredicateSymbol,
    FunctionSymbol,
    Variable,
    Function,
    AtomicFormula,
    Negation,
    EFormula,
    AFormula,
    Conjunction,
    Disjunction,
    Literal,
    Clause,
    CNF,
    Substitution,
    Unifiable,
    OverMaxSearchDepthError

abstract type Term end
abstract type Formula end

@auto_hash_equals struct PredicateSymbol
    symbol::String
end

@auto_hash_equals struct FunctionSymbol
    symbol::String
end

@auto_hash_equals struct Variable <: Term
    variable::String
end

@auto_hash_equals struct Function <: Term
    name::FunctionSymbol
    arguments::Vector{Term}
end

@auto_hash_equals struct AtomicFormula <: Formula
    name::PredicateSymbol
    arguments::Vector{Term}
end

@auto_hash_equals struct Negation <: Formula
    formula::Formula
end

@auto_hash_equals struct EFormula <: Formula
    variable::Variable
    formula::Formula
end

@auto_hash_equals struct AFormula <: Formula
    variable::Variable
    formula::Formula
end

@auto_hash_equals struct Conjunction <: Formula
    formula1::Formula
    formula2::Formula
end

@auto_hash_equals struct Disjunction <: Formula 
    formula1::Formula
    formula2::Formula
end

@auto_hash_equals struct Literal
    negative::Bool
    formula::AtomicFormula
end

const Clause = Set{Literal}
const CNF = Set{Clause}  # Conjunctive normal form
const Substitution = Vector{Pair{Variable, Term}}
const Unifiable = Union{Literal, Term}

String(x::PredicateSymbol) = x.symbol
String(x::FunctionSymbol) = x.symbol
String(x::Variable) = x.variable
String(x::Function) = "$(String(x.name))($(join(String.(x.arguments), ", ")))"
String(x::AtomicFormula) = "$(String(x.name))($(join(String.(x.arguments), ", ")))"
String(x::Negation) = "~$(String(x.formula))"
String(x::EFormula) = "?{$(String(x.variable))}$(String(x.formula))"
String(x::AFormula) = "*{$(String(x.variable))}$(String(x.formula))"
String(x::Conjunction) = "($(String(x.formula1)) & $(String(x.formula2)))"
String(x::Disjunction) = "($(String(x.formula1)) | $(String(x.formula2)))"
String(x::Literal) = "$(x.negative ? "~" : "")$(String(x.formula))"
String(x::Clause) = "{$(join(String.(collect(x)), ", "))}"
String(x::CNF) = "{$(join(String.(collect(x)), ", "))}"

Formula(literal::Literal) = begin
    literal.negative ? Negative(literal.formula) : literal.formula
end

Base.convert(::Type{Formula}, cnf::Set{Set{Literal}}) = begin
    if length(cnf) == 1
        Formula(first(cnf))
    else
        head, tail = headtail(cnf)
        @match cnf begin
        x::CNF => Conjunction(Formula(head), Formula(tail))
        x::Clause => Disjunction(Formula(head), Formula(tail))
        end
    end
end

type OverMaxSearchDepthError <: Exception
end

type NotUnifiableError <: Exception
end
