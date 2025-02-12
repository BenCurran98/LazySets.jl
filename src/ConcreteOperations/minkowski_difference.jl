export minkowski_difference, pontryagin_difference

"""
    minkowski_difference(P::LazySet, Q::LazySet)

Concrete Minkowski difference (geometric difference) of a polytopic set and a
compact convex set.

### Input

- `P` -- polytopic set
- `Q` -- compact convex set that is subtracted from `P`

### Output

An `HPolytope` that corresponds to the Minkowski difference of `P` minus `Q` if
`P` is bounded, and an `HPolyhedron` if `P` is unbounded.

### Notes

This implementation requires that the set `P` is polyhedral and that the set `Q`
is bounded.

### Algorithm

This method implements Theorem 2.3 in [1]:

Suppose ``P`` is a polyhedron
```math
P = \\{z ∈ ℝ^n: sᵢᵀz ≤ rᵢ,~i = 1, …, N\\}.
```
where ``sᵢ ∈ ℝ^n, sᵢ ≠ 0``, and ``rᵢ ∈ ℝ``.
Assume ``ρ(sᵢ,Q)`` is defined for ``i = 1, …, N``.
Then the Minkowski difference is

```math
\\{z ∈ ℝ^n: sᵢᵀz ≤ rᵢ - ρ(sᵢ,Q),~i = 1, …, N\\}.
```

[1] Ilya Kolmanovsky and Elmer G. Gilbert (1997). *Theory and computation
of disturbance invariant sets for discrete-time linear systems.*
[Mathematical Problems in Engineering Volume 4, Issue 4, Pages
317-367.](http://dx.doi.org/10.1155/S1024123X98000866)
"""
function minkowski_difference(P::LazySet, Q::LazySet)

    @assert is_polyhedral(P)  "this implementation requires that the first" *
        "argument is polyhedral; try overapproximating with an `HPolyhedron`"
    @assert isbounded(Q) "this implementation requires that the second " *
        "argument is bounded, but it is not"

    A, b = tosimplehrep(P)
    g_PminusQ = [b[i] - ρ(A[i, :], Q) for i in eachindex(b)]
    if isbounded(P)
        return HPolytope(A, g_PminusQ)
    else
        return HPolyhedron(A, g_PminusQ)
    end
end

"""
    pontryagin_difference(X::LazySet, Y::LazySet)

An alias for the function `minkowski_difference`.

### Notes

There is some inconsistency in the literature regarding the naming conventions.
In this library, both the names *Minkowski difference* and
*Pontryagin difference* refer to the geometric difference of two sets.
Mathematically:

```math
    X ⊖ Y = \\{z ∈ ℝ^n: z + v ∈ X  ~∀~v ∈ Y\\}
```
"""
const pontryagin_difference = minkowski_difference

for ST in [:LazySet, :AbstractZonotope]
    # Minkowski difference with singleton is a translation
    @eval minkowski_difference(X::($ST), S::AbstractSingleton) =
        translate(X, -element(S))

    # Minkowski difference with ZeroSet is the identity
    @eval minkowski_difference(X::($ST), ::ZeroSet) = X
end

"""
    minkowski_difference(Z1::AbstractZonotope, Z2::AbstractZonotope)

Compute the Minkowski difference of two zonotopic sets.

### Input

- `Z1` -- zonotopic set
- `Z2` -- zonotopic set

### Output

An `HPolytope` that corresponds to the Minkowski difference of `Z1` minus `Z2`.

### Algorithm

This method implements Theorem 3 in [1].

[1] M. Althoff: *On computing the Minkowski difference of zonotopes*. 2016.
"""
function minkowski_difference(Z1::AbstractZonotope, Z2::AbstractZonotope)
    Gm = genmat(Z1)
    n, p = size(Gm)
    @assert dim(Z2) == n "the Minkowski difference only applies to sets of " *
        "the same dimension, but the arguments have dimension $n and $(dim(Z2))"

    N = promote_type(eltype(Z1), eltype(Z2))
    cm, Gmᵀ = center(Z1), transpose(Gm)
    cs, Gsᵀ = center(Z2), transpose(genmat(Z2))
    Δc = cm - cs

    m = binomial(p, n - 1)
    constraints = Vector{HalfSpace{N, Vector{N}}}()
    for columns in StrictlyIncreasingIndices(p, n-1)
        c⁺ = cross_product(view(Gm, :, columns))
        iszero(c⁺) && continue
        normalize!(c⁺, 2)

        Δd = sum(abs, Gmᵀ * c⁺)
        Δdtrans = sum(abs, Gsᵀ * c⁺)

        c⁺Δc = dot(c⁺, Δc)
        ΔΔd = Δd - Δdtrans
        d⁺ = c⁺Δc + ΔΔd
        c⁻ = -c⁺
        d⁻ = -c⁺Δc + ΔΔd

        push!(constraints, HalfSpace(c⁺, d⁺))
        push!(constraints, HalfSpace(c⁻, d⁻))
    end

    return HPolytope(constraints)
end
