# VARIABLES
Base.show(io::IO, v::AbstractVariable) = print_var(io, MIME"text/plain"(), v)
Base.show(io::IO, mime::MIME"text/plain", v::AbstractVariable) = print_var(io, mime, v)
Base.show(io::IO, mime::MIME"text/latex", v::AbstractVariable) = print_var(io, mime, v)

function print_var(io::IO, mime::MIME, var::AbstractVariable)
    base, indices = name_base_indices(var)
    if isempty(indices)
        print(io, base)
    else
        print(io, base)
        print_subscript(io, mime, indices)
    end
end
function print_subscript(io::IO, ::MIME"text/latex", index)
    print(io, "_{", join(index, ","), "}")
end
function print_subscript(io::IO, mime, indices)
    if length(indices) == 1
        print(io, unicode_subscript(indices[1]))
    else
        print(io, join(unicode_subscript.(indices), "\u208B"))
    end
end

const unicode_subscripts = ("₀","₁","₂","₃","₄","₅","₆","₇","₈","₉")
unicode_subscript(i) = unicode_subscripts[i+1]

# MONOMIALS

Base.show(io::IO, mime::MIME"text/latex", m::AbstractMonomial) = print_monomial(io, mime, m)
Base.show(io::IO, mime::MIME"text/plain", m::AbstractMonomial) = print_monomial(io, mime, m)
Base.show(io::IO, m::AbstractMonomial) = print_monomial(io, MIME"text/plain"(), m)

function print_monomial(io::IO, mime, m::AbstractMonomial)
    if isconstant(m)
        print(io, '1')
    else
        for (var, exp) in zip(variables(m), exponents(m))
            if !iszero(exp)
                print_var(io, mime, var)
                if !isone(exp)
                    print_exponent(io, mime, exp)
                end
            end
        end
    end
end
#
print_exponent(io::IO, ::MIME"text/latex", exp) = print(io, "^{", exp, "}")
function print_exponent(io::IO, mime, exp)
    print(io, join(unicode_superscript.(reverse(digits(exp)))))
end

const unicode_superscripts = ("⁰","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹")
unicode_superscript(i) = unicode_superscripts[i+1]

# TERM

Base.show(io::IO, t::AbstractTerm) = print_term(io, MIME"text/plain"(), t)
Base.show(io::IO, mime::MIME"text/latex", t::AbstractTerm) = print_term(io, mime, t)
Base.show(io::IO, mime::MIME"text/plain", t::AbstractTerm) = print_term(io, mime, t)

function print_term(io::IO, mime, t::AbstractTerm)
    if isconstant(t)
        print_coefficient(io, coefficient(t))
    else
        if should_print_coefficient(coefficient(t))
            if !should_print_coefficient(-coefficient(t))
                print(io, '-')
            else
                print_coefficient(io, coefficient(t))
            end
        end
        if !iszero(t)
            show(io, mime, monomial(t))
        end
    end
end

should_print_coefficient(x) = true  # By default, just print all coefficients
should_print_coefficient(x::Number) = !isone(x) # For numbers, we omit any "one" coefficients
print_coefficient(io::IO, coeff::Real) = print(io, coeff)
print_coefficient(io::IO, coeff) = print(io, "(", coeff, ")")

# POLYNOMIAL

Base.show(io::IO, t::AbstractPolynomial) = print_poly(io, MIME"text/plain"(), t)
Base.show(io::IO, mime::MIME"text/plain", t::AbstractPolynomial) = print_poly(io, mime, t)
Base.show(io::IO, mime::MIME"text/latex", t::AbstractPolynomial) = print_poly(io, mime, t)

function print_poly(io::IO, mime, p::AbstractPolynomial{T}) where T
    ts = terms(p)
    if isempty(ts)
        print(io, zero(T))
    else
        print_term(io, mime, first(ts))
        for t in Iterators.drop(ts, 1)
            if isnegative(coefficient(t))
                print(io, " - ")
                show(io, mime, abs(coefficient(t)) * monomial(t))
            else
                print(io, " + ")
                show(io, mime, t)
            end
        end
    end
end

isnegative(x::Real) = x < 0
isnegative(x) = false

# RATIONAL POLY

Base.show(io::IO, t::RationalPoly) = print_ratpoly(io, MIME"text/plain"(), t)
Base.show(io::IO, mime::MIME"text/plain", t::RationalPoly) = print_ratpoly(io, mime, t)
Base.show(io::IO, mime::MIME"text/latex", t::RationalPoly) = print_ratpoly(io, mime, t)

function print_ratpoly(io::IO, mime, p::RationalPoly)
    print(io, "(")
    show(io, mime, p.num)
    print(io, ") / (")
    show(io, mime, p.den)
    print(io, ")")
end
