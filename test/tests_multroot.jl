using Roots
using Polynomials
using Base.Test
using Primes

## can use functions
f = x -> (x-1)*(x-2)^2*(x-3)^3
U = multroot(f)
@test length(U) == 3
@test reduce(&, sort(collect(values(U))) .== [1,2,3])


x = poly([0.0])

p = (x-1)*(x-2)^2*(x-3)^3
U = multroot(p)
@test reduce(&, sort(collect(values(U))) .== [1,2,3])

p = (x-1)^2*(x-2)^2*(x-3)^4
U = multroot(p)
@test reduce(&, sort(collect(values(U))) .== [2,2,4])

p = (x-1)^2
U = multroot(p^14)
@test collect(values(U))[1] == 28

## test for roots of polynomial functions
U = roots(x -> x^5 - x + 1)
@test length(U) == 5

## test for real roots of polynomial functions
U = fzeros(x -> x^5 - 1.5x + 1)
@test length(U) == 1


## for polynomials in Z[x], Q[x] can use algorithm to be accurate for higher degree

@test fzeros(x -> x - 1)[1] == 1.0 # linear
f = x -> (x-1)*(x-2)*(x-3)^3*(x^2+1)
rts = fzeros(f)
rts = Float64[r for r in rts]
@test maximum(abs(sort(rts) - [1.0, 2.0, 3.0])) <= 1e-12
x = poly([big(0)])
p = prod([x - i for i in 1:20])
Roots.real_roots(p) ## can find this
f = x -> (x-20)^5 - (x-20) + 1
a = fzeros(f)[1]
@assert abs(f(a)) <= 1e-14

x = poly([0.0])
@test abs(fzeros((x-20)^5 - (x-20) + 1)[1] - (20 + fzeros(x^5 - x + 1)[1])) <= 1/2

fzeros(x -> x^5 - 2x^4 + x^3)

## factor
factor(x -> (x-2)^4*(x-3)^9)
factor(x -> (x-1)^3 * (x-2)^3 * (x^5 - x + 1))
factor(x -> x*(x-1)*(x-2)*(x^2 + x + 1))


## Test conversion of polynomials to Int
f = x -> 3x^3 - 2x
convert(Polynomials.Poly{Int}, f)
f = x -> (3x^3 - 2x)/3
convert(Polynomials.Poly{Int}, f)
f = x ->  x^2 / x # rational functions fails
@test_throws MethodError convert(Polynomials.Poly{Int64}, f)
f = x ->  (x^2 + x)^2
convert(Polynomials.Poly{Int}, f)
f = x ->  (x^2 + x)^(1/2)
@test_throws MethodError convert(Polynomials.Poly{Int64}, f)


## polynomial conversions from functions in practice
fzeros(x -> 265 - 0.65x)
fzeros(x -> -16x^2 + 200x)
