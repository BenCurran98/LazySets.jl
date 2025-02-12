import Base.isempty

export AbstractPolytope,
       vertices_list,
       isempty,
       minkowski_sum

"""
    AbstractPolytope{N} <: AbstractPolyhedron{N}

Abstract type for compact convex polytopic sets.

### Notes

Every concrete `AbstractPolytope` must define the following method:

- `vertices_list(::AbstractPolytope)` -- return a list of all vertices

```jldoctest; setup = :(using LazySets: subtypes)
julia> subtypes(AbstractPolytope)
4-element Vector{Any}:
 AbstractCentrallySymmetricPolytope
 AbstractPolygon
 HPolytope
 VPolytope
```

A polytope is a bounded polyhedron (see [`AbstractPolyhedron`](@ref)).
Polytopes are compact convex sets with either of the following equivalent
properties:
1. They are the intersection of a finite number of closed half-spaces.
2. They are the convex hull of finitely many vertices.
"""
abstract type AbstractPolytope{N} <: AbstractPolyhedron{N} end

isconvextype(::Type{<:AbstractPolytope}) = true

function isboundedtype(::Type{<:AbstractPolytope})
    return true
end

"""
    isbounded(P::AbstractPolytope)

Check whether a polytopic set is bounded.

### Input

- `P` -- polytopic set

### Output

`true` (since a polytopic set must be bounded).
"""
function isbounded(::AbstractPolytope)
    return true
end

"""
    isempty(P::AbstractPolytope)

Check whether a polytopic set is empty.

### Input

- `P` -- polytopic set

### Output

`true` if the given polytopic set contains no vertices, and `false` otherwise.

### Algorithm

This algorithm checks whether the `vertices_list` of `P` is empty.
"""
function isempty(P::AbstractPolytope)
    return isempty(vertices_list(P))
end

"""
    isuniversal(P::AbstractPolytope{N}, [witness]::Bool=false) where {N}

Check whether a polytopic set is universal.

### Input

- `P`       -- polytopic set
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `false`
* If `witness` option is activated: `(false, v)` where ``v ∉ P`` unless the list
  of constraints is empty (which should not happen for a normal polytope)

### Algorithm

A witness is produced using `isuniversal(H)` where `H` is the first linear
constraint of `P`.
"""
function isuniversal(P::AbstractPolytope{N}, witness::Bool=false) where {N}
    if witness
        constraints = constraints_list(P)
        if isempty(constraints)
            return (true, N[])  # special case for polytopes without constraints
        end
        return isuniversal(constraints[1], true)
    else
        return false
    end
end

# given a polytope P, apply the linear map P to each vertex of P
# it is assumed that the interface function `vertices_list(P)` is available
@inline function _linear_map_vrep(M::AbstractMatrix, P::AbstractPolytope,
                                  algo::LinearMapVRep=LinearMapVRep(nothing);
                                  apply_convex_hull::Bool=false)
    vlist = broadcast(v -> M * v, vertices_list(P))

    m = size(M, 1) # output dimension
    if m == 1
        convex_hull!(vlist)
        # points are sorted
        return Interval(vlist[1][1], vlist[end][1])
    elseif m == 2
        return VPolygon(vlist)
    else
        if apply_convex_hull
            convex_hull!(vlist)
        end
        return VPolytope(vlist)
    end
end

function _linear_map_hrep_helper(M::AbstractMatrix, P::AbstractPolytope,
                                 algo::AbstractLinearMapAlgorithm)
    constraints = _linear_map_hrep(M, P, algo)
    m = size(M, 1) # output dimension
    if m == 1
        # TODO: create interval directly ?
        return convert(Interval, HPolytope(constraints))
    elseif m == 2
        return HPolygon(constraints)
    else
        return HPolytope(constraints)
    end
end

# the "backend" argument is ignored, used for dispatch
function _vertices_list(P::AbstractPolytope, backend)
    return vertices_list(P)
end

"""
    volume(P::AbstractPolytope; backend=default_polyhedra_backend(P))

Compute the volume of a polytopic set.

### Input

- `P`       -- polytopic set
- `backend` -- (optional, default: `default_polyhedra_backend(P)`) the backend
               for polyhedral computations; see [Polyhedra's
               documentation](https://juliapolyhedra.github.io/) for further
               information

### Output

The volume of `P`.

### Algorithm

The volume is computed by the `Polyhedra` library.
"""
function volume(P::AbstractPolytope; backend=nothing)
    require(@__MODULE__, :Polyhedra; fun_name="volume")
    if isnothing(backend)
        backend = default_polyhedra_backend(P)
    end

    return Polyhedra.volume(polyhedron(P; backend=backend))
end
