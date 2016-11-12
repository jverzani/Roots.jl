[![Roots](http://pkg.julialang.org/badges/Roots_0.4.svg)](http://pkg.julialang.org/?pkg=Roots&ver=0.4)
[![Roots](http://pkg.julialang.org/badges/Roots_0.5.svg)](http://pkg.julialang.org/?pkg=Roots&ver=0.5)  
Linux: [![Build Status](https://travis-ci.org/JuliaMath/Roots.jl.svg?branch=master)](https://travis-ci.org/JuliaMath/Roots.jl)
Windows: [![Build status](https://ci.appveyor.com/api/projects/status/goteuptn5kypafyl?svg=true)](https://ci.appveyor.com/project/ChrisRackauckas/roots-jl)

# Root finding functions for Julia

This package contains simple routines for finding roots of continuous
scalar functions of a single real variable. The basic interface is
through the function `fzero` which dispatches to an appropriate
algorithm based on its argument(s):

* `fzero(f, a::Real, b::Real)` and `fzero(f,
  bracket::Vector)` call the `find_zero` algorithm to find a root
  within the bracket `[a,b]`.  When a bracket is used with `Float64`
  arguments, the algorithm is guaranteed to converge to a value `x`
  with either `f(x) == 0` or at least one of `f(prevfloat(x))*f(x) < 0`
  or `f(x)*f(nextfloat(x)) < 0`. (The function need not be continuous
  to apply the algorithm, as the last condition can still hold.)

* `fzero(f, x0::Real; order::Int=0)` calls a
  derivative-free method. The default method is a bit plodding but
  more robust to the quality of the initial guess than some others.
  For faster convergence and fewer function calls, an order can be
  specified. Possible values are 1, 2, 5, 8, and 16. The order 2
  Steffensen method can be the fastest, but is in need of a good
  initial guess. The order 8 method is more robust and often as
  fast. The higher-order methods may be faster when using `Big` values.

* `fzero(f, x0::Real, bracket::Vector)` calls
  a derivative-free algorithm with initial guess `x0` with steps constrained
  to remain in the specified bracket.

* `fzeros(f, a::Real, b::Real; no_pts::Int=200)` will split
  the interval `[a,b]` into many subintervals and search for zeros in
  each using a bracketing method if possible. This naive algorithm
  will miss double zeros that lie within the same subinterval.


For polynomials either of class `Poly` (from the `Polynomials`
package) or from functions which are of polynomial type there are
specializations:

* The `roots` function will dispatch to the `roots` function of the
  `Polynomials` package to return all roots (including 
  complex ones) of the polynomial.


* `fzeros(f::Function)` calls `real_roots` to find the real roots of
  the polynomial. For polynomials with integer coefficients, the
  rational roots are found first, and then numeric approximations to
  the remaining real roots are returned.

* For polynomial functions over the integers or rational numbers, the
`factor` function will return a dictionary of factors (as
`Polynomials`) and their multiplicities.

* For polynomials over the real numbers, the `multroot` function will
  return the roots and their multiplicities through a dictionary. The
  `roots` function from the `Polynomials` package will find all the
  roots of a polynomial. Its performance degrades when the polynomial
  has high multiplicities. The `multroot` function is provided to
  handle this case a bit better.  The function follows algorithms due
  to Zeng,
  ["Computing multiple roots of inexact polynomials", Math. Comp. 74 (2005), 869-903](http://www.ams.org/journals/mcom/2005-74-250/S0025-5718-04-01692-8/home.html).




For historical purposes, there are implementations of Newton's method
(`newton`), Halley's method (`halley`), and the secant method
(`secant_method`). For the first two, if derivatives are not
specified, they will be computed using the `ForwardDiff` package.


## Usage examples

```
f(x) = exp(x) - x^4
## bracketing
fzero(f, [8, 9])		# 8.613169456441398
fzero(f, -10, 0)		# -0.8155534188089606
fzeros(f, -10, 10)		# -0.815553, 1.42961  and 8.61317 

## use a derivative free method
fzero(f, 3)			# 1.4296118247255558

## use a different order
fzero(sin, 3, order=16)		# 3.141592653589793

## BigFloat values yield more precision
fzero(sin, BigFloat(3.0))	# 3.1415926535897932384...with 256 bits of precision
```

The `fzero` function, `newton` and `halley` functions can be used with `FastAnonyous` functions:

```
using FastAnonymous
fa = @anon x -> cos(x) - 10x
fap = @anon x -> -sin(x) - 10
fzero(fa, 1)           # 0.09950534268738782
fzero(fa, 1, order=8)  # 0.09950534268738784
newton(fa, fap, 1)     # 0.09950534268738784
```

(The polynomials methods do not work with `FastAnonymous` functions.)



All real roots of a polynomial can be found at once:

```
f(x) = x^5 - x - 1
fzeros(f)
```

Or using an explicit polynomial:

```
using Polynomials
x = poly([0])
fzeros(x^5 -x - 1)
fzeros(x*(x-1)*(x-2)*(x^2 + x + 1))
```


Polynomial root finding is a bit better when multiple roots are present.

```
x = poly([0.0])
p = (x-1)^2 * (x-3)
U = multroot(p)	
collect(keys(U)) # compare to roots(p)
```

Again, a polynomial function may be passed in

```
f(x) = (x-1)*(x-2)^2*(x-3)^3
multroot(f)
```

The `factor` function will factor polynomials with rational and integer coefficients over the integers:

```
factor(f)
```


The well-known methods can be used with or without supplied
derivatives. If not specified, the `ForwardDiff` package is used for
automatic differentiation.

```
f(x) = exp(x) - x^4
fp(x) = exp(x) - 4x^3
fpp(x) = exp(x) - 12x^2
newton(f, fp, 8)		# 8.613169456441398
newton(f, 8)	
halley(f, fp, fpp, 8)
halley(f, 8)
secant_method(f, 8, 8.5)
```

The automatic derivatives allow for easy solutions to finding critical
points of a function.

```
## mean
as = rand(5)
function M(x) 
  sum([(x-a)^2 for a in as])
end
fzero(D(M), .5) - mean(as)	# 0.0

## median
function m(x) 
  sum([abs(x-a) for a in as])
end
fzero(D(m), 0, 1)  - median(as)	# 0.0
```

Some additional documentation can be read [here](http://nbviewer.ipython.org/url/github.com/JuliaLang/Roots.jl/blob/master/doc/roots.ipynb?create=1).
