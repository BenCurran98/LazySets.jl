import Base.∈

export AbstractSingleton,
       element,
       an_element

"""
    AbstractSingleton{N} <: AbstractHyperrectangle{N}

Abstract type for sets with a single value.

### Notes

Every concrete `AbstractSingleton` must define the following function:

- `element(::AbstractSingleton)` -- return the single element

```jldoctest; setup = :(using LazySets: subtypes)
julia> subtypes(AbstractSingleton)
2-element Vector{Any}:
 Singleton
 ZeroSet
```
"""
abstract type AbstractSingleton{N} <: AbstractHyperrectangle{N} end

isconvextype(::Type{<:AbstractSingleton}) = true

"""
    element(S::AbstractSingleton, i::Int)

Return the i-th entry of the element of a set with a single value.

### Input

- `S` -- set with a single value
- `i` -- dimension of interest

### Output

The i-th entry of the element.
"""
function element(S::AbstractSingleton, i::Int)
    @boundscheck _check_bounds(S, i)
    return element(S)[i]
end

"""
    radius_hyperrectangle(S::AbstractSingleton{N}, i::Int) where {N}

Return the box radius of a set with a single value in a given dimension.

### Input

- `S` -- set with a single value
- `i` -- dimension of interest

### Output

Zero.
"""
function radius_hyperrectangle(S::AbstractSingleton{N}, i::Int) where {N}
    @boundscheck _check_bounds(S, i)
    return zero(N)
end

"""
    radius_hyperrectangle(S::AbstractSingleton{N}) where {N}

Return the box radius of a set with a single value in every dimension.

### Input

- `S` -- set with a single value

### Output

The zero vector.
"""
function radius_hyperrectangle(S::AbstractSingleton{N}) where {N}
    return zeros(N, dim(S))
end

"""
    high(S::AbstractSingleton)

Return the higher coordinates of a set with a single value.

### Input

- `S` -- set with a single value

### Output

A vector with the higher coordinates.
"""
function high(S::AbstractSingleton)
    return element(S)
end

"""
    high(S::AbstractSingleton, i::Int)

Return the higher coordinate of a set with a single value in the given
dimension.

### Input

- `S` -- set with a single value
- `i` -- dimension of interest

### Output

The higher coordinate in the given dimension.
"""
function high(S::AbstractSingleton, i::Int)
    @boundscheck _check_bounds(S, i)
    return element(S)[i]
end

"""
    low(S::AbstractSingleton)

Return the lower coordinates of a set with a single value.

### Input

- `S` -- set with a single value

### Output

A vector with the lower coordinates.
"""
function low(S::AbstractSingleton)
    return element(S)
end

"""
    low(S::AbstractSingleton, i::Int)

Return the lower coordinate of a set with a single value in the given
dimension.

### Input

- `S` -- set with a single value
- `i` -- dimension of interest

### Output

The lower coordinate in the given dimension.
"""
function low(S::AbstractSingleton, i::Int)
    @boundscheck _check_bounds(S, i)
    return element(S)[i]
end

"""
   genmat(S::AbstractSingleton{N}) where {N}

Return the (empty) generator matrix of a set with a single value.

### Input

- `S` -- set with a single value

### Output

A matrix with no columns representing the generators of `S`.
"""
function genmat(S::AbstractSingleton{N}) where {N}
    return Matrix{N}(undef, dim(S), 0)
end

"""
    generators(S::AbstractSingleton{N}) where {N}

Return an (empty) iterator over the generators of a set with a single value.

### Input

- `S` -- set with a single value

### Output

An empty iterator.
"""
function generators(S::AbstractSingleton{N}) where {N}
    return EmptyIterator{Vector{N}}()
end

"""
    ngens(S::AbstractSingleton)

Return the number of generators of a set with a single value.

### Input

- `H` -- set with a single value

### Output

The number of generators, which is ``0``.
"""
function ngens(S::AbstractSingleton)
    return 0
end

"""
    center(S::AbstractSingleton)

Return the center of a set with a single value.

### Input

- `S` -- set with a single value

### Output

The center of the set.
"""
function center(S::AbstractSingleton)
    return element(S)
end

"""
    center(S::AbstractSingleton, i::Int)

Return the center of a set with a single value in a given dimension.

### Input

- `S` -- set with a single value
- `i` -- dimension of interest

### Output

The `i`-th entry of the center of the set.
"""
function center(S::AbstractSingleton, i::Int)
    @boundscheck _check_bounds(S, i)
    return element(S, i)
end

"""
    vertices(S::AbstractSingleton{N}) where {N}

Construct an iterator over the vertices of a set with a single value.

### Input

- `S` -- set with a single value

### Output

An iterator with a single value.
"""
function vertices(S::AbstractSingleton{N}) where {N}
    return SingletonIterator(element(S))
end

"""
    vertices_list(S::AbstractSingleton)

Return the list of vertices of a set with a single value.

### Input

- `S` -- set with a single value

### Output

A list containing only a single vertex.
"""
function vertices_list(S::AbstractSingleton)
    return [element(S)]
end

"""
    σ(d::AbstractVector, S::AbstractSingleton)

Return the support vector of a set with a single value.

### Input

- `d` -- direction
- `S` -- set with a single value

### Output

The support vector, which is the set's vector itself, irrespective of the given
direction.
"""
function σ(d::AbstractVector, S::AbstractSingleton)
    return element(S)
end

"""
    ρ(d::AbstractVector, S::AbstractSingleton)

Evaluate the support function of a set with a single value in a given direction.

### Input

- `d` -- direction
- `S` -- set with a single value

### Output

The support value in the given direction.
"""
function ρ(d::AbstractVector, S::AbstractSingleton)
    return dot(d, element(S))
end

"""
    ∈(x::AbstractVector, S::AbstractSingleton)

Check whether a given point is contained in a set with a single value.

### Input

- `x` -- point/vector
- `S` -- set with a single value

### Output

`true` iff ``x ∈ S``.

### Notes

This implementation performs an approximate comparison to account for
imprecision in floating-point computations.
"""
function ∈(x::AbstractVector, S::AbstractSingleton)
    return _isapprox(x, element(S))
end

# this operation is forbidden, but it is a common error
function ∈(S::AbstractSingleton, X::LazySet)
    throw(ArgumentError("cannot make a point-in-set check if the left-hand " *
          "side is a set; either check for set inclusion, as in `S ⊆ X`, or " *
          "check for membership, as in `element(S) ∈ X` (the results are " *
          "equivalent, but the implementations may differ)"))
end

function chebyshev_center_radius(S::AbstractSingleton{N}) where {N}
    return element(S), zero(N)
end

"""
    plot_recipe(S::AbstractSingleton{N}, [ε]=zero(N)) where {N}

Convert a singleton to a pair `(x, y)` of points for plotting.

### Input

- `S` -- singleton
- `ε` -- (optional, default: `0`) ignored, used for dispatch

### Output

A pair `(x, y)` of one point that can be plotted.
"""
function plot_recipe(S::AbstractSingleton{N}, ε=zero(N)) where {N}
    n = dim(S)
    if n == 1
        return [element(S)[1]], [zero(N)]
    elseif n == 2
        return [element(S)[1]], [element(S)[2]]
    elseif n == 3
        return [element(S)[1]], [element(S)[2]], [element(S)[3]]
    else
        throw(ArgumentError("cannot plot a $n-dimensional $(typeof(S))"))
    end
end
