
# =======================================================
#         CycleGraph struct
# =======================================================

"""
    CycleGraph <: AbstractGraph

A structure representing an undirected cycle graph.

A `CycleGraph` with one vertex is a single vertex without any edges (no self-loops)
and a `CycleGraph` with two vertices is a single edge.

See also: [`LightGraphs.cycle_graph`](@ref)
"""
struct CycleGraph{T<:Integer} <: AbstractGraph{T}
    nv::T

    function CycleGraph{T}(nv) where {T}
       
        nv = convert(T, nv)
        nv >= zero(T) || throw(ArgumentError("nv must be >= 0"))

        return new{T}(nv)
    end
end

CycleGraph(nv::T) where {T<: Integer} = CycleGraph{T}(nv)


# =======================================================
#         traits
# =======================================================

LG.is_directed(::Type{<:CycleGraph}) = false

#
# =======================================================
#        vertices
# =======================================================

Base.eltype(::Type{CycleGraph{T}}) where {T} = T
Base.eltype(g::CycleGraph) = eltype(typeof(g))

LG.edgetype(::Type{CycleGraph{T}}) where {T} = Edge{T}

LG.nv(g::CycleGraph) = g.nv

LG.vertices(g::CycleGraph{T}) where {T} = Base.OneTo(nv(g))

LG.has_vertex(g::CycleGraph, v) = v in vertices(g)


# =======================================================
#        edges
# =======================================================

LG.edgetype(g::CycleGraph{T}) where {T} = edgetype(typeof(g))

function LG.ne(g::CycleGraph)
    nvg = Int(nv(g))
    
    nvg >= 3 && return nvg
    nvg == 2 && return 1

    return 0
end

function LG.has_edge(g::CycleGraph{T}, u, v) where {T}

    u, v = minmax(u, v)
    nvg = nv(g)
    oneT = one(T)
    isinbounds = (oneT <= u) & (v <= nvg) 
    isedge = ((v - u == oneT) | (v - u == nvg - oneT)) & (u != v)
    return isinbounds & isedge
end

# ---- edges vector -----------------------------------

LG.edges(g::CycleGraph) = SimpleEdgeVector(g)

function Base.size(edgevec::SimpleEdgeVector{V, G}) where {V, G <: CycleGraph}

    g = edgevec.graph

    return (ne(g), )
end

@inline function Base.getindex(edgevec::SimpleEdgeVector{V, G}, i::Int) where {V, G <: CycleGraph}

    @boundscheck i ∈ Base.OneTo(length(edgevec)) || throw(BoundsError(edgevec, i))

    g = edgevec.graph
    T = eltype(g)
    nvg::T = nv(g)

    i == 1 && return Edge(one(T), T(2))
    i == 2 && return Edge(one(T), nvg)
    return Edge(T(i - 1), T(i))
end

Base.IndexStyle(::Type{<:SimpleEdgeVector{V, G}}) where {V, G <: CycleGraph} = IndexLinear()


# =======================================================
#        neighbors
# =======================================================

@inline function LG.outneighbors(g::CycleGraph, v::Integer)

    @boundscheck v ∈ vertices(g) || throw(BoundError(g, v))

    return OutNeighborVector(g, eltype(g)(v))
end

LG.inneighbors(g::CycleGraph, v::Integer) = outneighbors(g, v)

# ---- neighbors vector -----------------------------------

function Base.size(nbs::OutNeighborVector{V, G}) where {V, G <: CycleGraph}

    g = nbs.graph
    T = eltype(g)
    nvg::T = nv(g)

    nvg <= one(T) && return (0,)
    nvg == T(2) && return (1,)
    return (2,)
end

@inline function Base.getindex(nbs::OutNeighborVector{V, G}, i::Int) where {V, G <: CycleGraph}

    @boundscheck i ∈ Base.OneTo(length(nbs)) || throw(BoundsError(nbs, i))

    g = nbs.graph
    T = eltype(g)
    v::T = nbs.vertex
    nvg::T = nv(g)

    if i == 1
        v == one(T) && return T(2)
        v == nvg && return one(T)
        return v - one(T)
    end
    # i == 2
    v == one(T) && return nvg
    v == nvg && return nvg - T(1)
    return v + one(T)
end

Base.IndexStyle(::Type{<:OutNeighborVector{V, G}}) where {V, G <: CycleGraph} = IndexLinear()


# =======================================================
#         converting
# =======================================================

Base.convert(::Type{SimpleGraph}, g::CycleGraph{T}) where {T} = cycle_graph(nv(g))
Base.convert(::Type{SimpleGraph{T}}, g::CycleGraph) where {T} = cycle_graph(T(nv(g)))


# =======================================================
#         overrides
# =======================================================

# we use this check so that we have the same convention as in LightGraphs
LG.is_connected(g::CycleGraph) = nv(g) > 0

function LG.connected_components(g::CycleGraph)

    nv(g) == 0 && return typeof(vertices(g))[]
    return [vertices(g)]
end

# has_self_loops is defined in terms of this
LG.num_self_loops(g::CycleGraph) = 0

LG.is_bipartite(g::CycleGraph) = (nv(g) == 1) | iseven(nv(g))

function LG.squash(g::CycleGraph)
    nvg = nv(g)
    for T ∈ (UInt8, UInt16, UInt32, UInt64)
        nv(g) < typemax(T) && return CycleGraph{T}(nvg)
    end
end

# ---- degree -----------------------------------

function LG.Δ(g::CycleGraph)
    nvg = nv(g)
    return typemin(Int) * (nvg == 0) + (nvg >= 2) + (nvg >= 3)
end

LG.Δout(g::CycleGraph) = Δ(g)
LG.Δin(g::CycleGraph) = Δ(g)

function LG.δ(g::CycleGraph)
    nvg = nv(g)
    return typemax(Int) * (nvg == 0) + (nvg >= 2) + (nvg >= 3)
end

LG.δout(g::CycleGraph) = δ(g)
LG.δin(g::CycleGraph) = δ(g)

LG.degree(g::CycleGraph, vs::AbstractVector=vertices(g)) = Fill(Δ(g), length(vs))

LG.indegree(g::CycleGraph, vs::AbstractVector=vertices(g)) = degree(g, vs)
LG.outdegree(g::CycleGraph, vs::AbstractVector=vertices(g)) = degree(g, vs)

