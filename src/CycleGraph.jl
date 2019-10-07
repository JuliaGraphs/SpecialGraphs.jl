
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
struct CycleGraph{T<:Integer} <: LG.AbstractGraph{T}
    nv::T

    function CycleGraph{T}(nv) where {T}
       
        nv = convert(T, nv)
        nv >= zero(T) || throw(ArgumentError("nv must be >= 0"))

        return new{T}(nv)
    end
end

CycleGraph(nv) = CycleGraph{typeof(nv)}(nv)


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

LG.edgetype(::Type{CycleGraph{T}}) where {T} = LG.Edge{T}

LG.nv(g::CycleGraph) = g.nv

LG.vertices(g::CycleGraph{T}) where {T} = Base.OneTo(LG.nv(g))

LG.has_vertex(g::CycleGraph, v) = v in LG.vertices(g)


# =======================================================
#        edges
# =======================================================

LG.edgetype(g::CycleGraph{T}) where {T} = LG.edgetype(typeof(g))

function LG.ne(g::CycleGraph)
    nvg = Int(LG.nv(g))
    
    nvg >= 3 && return nvg
    nvg == 2 && return 1

    return 0
end

function LG.has_edge(g::CycleGraph{T}, u, v) where {T}

    u, v = minmax(u, v)
    nvg = LG.nv(g)
    oneT = one(T)
    isinbounds = (oneT <= u) & (v <= nvg) 
    isedge = (v - u == oneT) | ((u == oneT) & (v == nvg))  
    return isinbounds & isedge
end

# ---- edges vector -----------------------------------

LG.edges(g::CycleGraph) = SimpleEdgeVector(g)

function Base.size(edgevec::SimpleEdgeVector{V, G}) where {V, G <: CycleGraph}

    g = edgevec.graph

    return (ne(g), )
end

# TODO propagate inbounds
function Base.getindex(edgevec::SimpleEdgeVector{V, G}, i::Int) where {V, G <: CycleGraph}

    i ∈ Base.OneTo(length(edgevec)) || throw(BoundsError(edgevec, i))

    g = edgevec.graph
    T = eltype(g)
    nvg::T = nv(g)

    i == 1 && return LG.Edge(one(T), T(2))
    i == 2 && return LG.Edge(one(T), nvg)
    return LG.Edge(T(i - 1), T(i))
end

Base.IndexStyle(::Type{<:SimpleEdgeVector{V, G}}) where {V, G <: CycleGraph} = IndexLinear()


# =======================================================
#        neighbors
# =======================================================

# TODO maybe we want an inbounds check
LG.outneighbors(g::CycleGraph, v::Integer) = OutNeighborVector(g, eltype(g)(v))

LG.inneighbors(g::CycleGraph, v::Integer) = LG.outneighbors(g, v)

# ---- neighbors iterator -----------------------------------

function Base.size(nbs::OutNeighborVector{V, G}) where {V, G <: CycleGraph}

    g = nbs.graph
    T = eltype(g)
    nvg::T = nv(g)

    nvg <= one(T) && return (0,)
    nvg == T(2) && return (1,)
    return (2,)
end

# TODO propagate inbounds
function Base.getindex(nbs::OutNeighborVector{V, G}, i::Int) where {V, G <: CycleGraph}

    i ∈ Base.OneTo(length(nbs)) || throw(BoundsError(nbs, i))

    g = nbs.graph
    T = eltype(g)
    v::T = nbs.vertex
    nvg::T = nv(g)

    nvg == T(2) && return T(2) - v
    if i == 1
        return (v == one(T)) ? T(2) : (v - one(T))
    end
    # i == 2
    return (v == nvg) ? (nvg(T) - 1) : (v + one(T))
end

Base.IndexStyle(::Type{<:OutNeighborVector{V, G}}) where {V, G <: CycleGraph} = IndexLinear()


# =======================================================
#         converting
# =======================================================

Base.convert(::Type{LG.SimpleGraph}, g::CycleGraph{T}) where {T} = cycle_graph(nv(g))
Base.convert(::Type{LG.SimpleGraph{T}}, g::CycleGraph) where {T} = cycle_graph(T(nv(g)))

