import LazySets: _leq, _geq, isapproxzero, _isapprox, ABSZTOL

# approximate <= and
@test _leq(2e-15, 1e-15) && _leq(1e-15, 2e-15)
@test _leq(1//100, 1//99) && _leq(1//100, 0.099)

# approximate <= with ztol
@test !_leq(2e-15, 1e-15, ztol=1e-15) && _leq(1e-15, 2e-15, ztol=1e-15)

# approximate >=
@test _geq(2e-15, 1e-15) && _geq(1e-15, 2e-15)

# approximate >= with ztol
@test _geq(2e-15, 1e-15, ztol=1e-15) && !_geq(1e-15, 2e-15, ztol=1e-15)

# default absolute zero tolerance for rational
x = 1/100; N = Rational{Int}
ABSZTOL(eltype(x)) == zero(N)

# default absolute zero tolerance for FP
x = 0.01; N = eltype(x)
ABSZTOL(eltype(x)) == sqrt(eps(Float64))

# approximately zero tests
@test isapproxzero(0//1)
@test isapproxzero(1e-8) && !isapproxzero(1e-8, ztol=1e-10)

# approximate numbers in FP
@test _isapprox(2e-15, 1e-15)
