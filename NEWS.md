CHANGES in v0.7.2

* streamlined code for defaults for `init_options`. Defaults are shown through `?Roots.default_tolerances(M)`.

* fixed issue with `find_zeros` and some number types

CHANGES in v0.7.1

* took algorithm from Order0, and made it an alternative for find_zero allowing other non-bracketing methods to be more robust

* In FalsePosition there is a parameter to adjust when a bisection step should be used. This was changed in v0.7.0, the old value is restored. (This method is too sensitive to this parameter. It is recommended that either A42 or AlefeldPotraShi be used as alternatives.

