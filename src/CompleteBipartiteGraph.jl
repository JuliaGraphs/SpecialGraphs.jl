

# =======================================================
#         CompleteBipartiteGraph struct
# =======================================================

"""
    CompleteBipartiteGraph <: AbstractGraph

A structure representing an undirected bipartite graph.


See also: [`LightGraphs.complete_bipartite_graph`](@ref)
"""
struct CompleteBipartiteGraph{T<:Integer} <: LG.AbstractGraph{T}
    m::T
    n::T

    function CompleteBipartiteGraph{T}(m, n) where {T}
       
        m = convert(T, m)
        n = convert(T, n)
        m >= zero(T) || throw(ArgumentError("m must be >= 0"))
        n >= zero(T) || throw(ArgumentError("n must be >= 0"))
        # TODO overflow check

        return new{T}(m, n)
    end
end

CompleteBipartiteGraph(m::T, n::T) where {T<: Integer} = CompleteBipartiteGraph{T}(m, n)


# =======================================================
#         traits
# =======================================================

LG.is_directed(::Type{<:CompleteBipartiteGraph}) = false


# =======================================================
#        vertices
# =======================================================

Base.eltype(::Type{CompleteBipartiteGraph{T}}) where {T} = T
Base.eltype(g::CompleteBipartiteGraph) = eltype(typeof(g))

LG.nv(g::CompleteBipartiteGraph{T}) where {T} = T(g.m + g.n)

LG.vertices(g::CompleteBipartiteGraph{T}) where {T} = Base.OneTo(nv(g))

LG.has_vertex(g::CompleteBipartiteGraph, v) = v in vertices(g)


# =======================================================
#        edges
# =======================================================


LG.edgetype(::Type{CompleteBipartiteGraph{T}}) where {T} = Edge{T}
LG.edgetype(g::CompleteBipartiteGraph{T}) where {T} = edgetype(typeof(g))

function LG.ne(g::CompleteBipartiteGraph)
    m = Int(g.m)
    n = Int(g.n)

    return m * n
end

function LG.has_edge(g::CompleteBipartiteGraph{T}, u, v) where {T}

    u, v = minmax(T(u), T(v))

    m = g.m
    n = g.n
rem
    return (u ∈ Base.OneTo(m)) & ((v - m) ∈ (Base.OneTo(n)))
end

# ---- edges vector -----------------------------------

LG.edges(g::CompleteBipartiteGraph) = SimpleEdgeVector(g)

function Base.size(edgevec::SimpleEdgeVector{V, G}) where {V, G <: CompleteBipartiteGraph}

    g = edgevec.graph

    return (ne(g), )
end

@inline function Base.getindex(edgevec::SimpleEdgeVector{V, G}, i::Int) where {V, G <: CompleteBipartiteGraph}

    @boundscheck i ∈ Base.OneTo(length(edgevec)) || throw(BoundsError(edgevec, i))

    g = edgevec.graph
    T = eltype(g)
    m::T = g.m
    n::T = g.n

    div, rem = divrem(T(i - 1), n)

    u = div + one(T)
    v = rem + one(T) + m
    return Edge(u, v)
end

Base.IndexStyle(::Type{<:SimpleEdgeVector{V, G}}) where {V, G <: CompleteBipartiteGraph} = IndexLinear()


# =======================================================
#        neighbors
# =======================================================

@inline function LG.outneighbors(g::CompleteBipartiteGraph, v::Integer)

    @boundscheck v ∈ vertices(g) || throw(BoundsError(g, v))

    return OutNeighborVector(g, eltype(g)(v))
end

LG.inneighbors(g::CompleteBipartiteGraph, v::Integer) = outneighbors(g, v)

# ---- neighbors vector -----------------------------------

function Base.size(nbs::OutNeighborVector{V, G}) where {V, G <: CompleteBipartiteGraph}

    g = nbs.graph
    T = eltype(g)
    m::T = g.m
    n::T = g.n
    v::T = nbs.vertex

    return (Int(ifelse(v <= m, n, m)), )
end

@inline function Base.getindex(nbs::OutNeighborVector{V, G}, i::Int) where {V, G <: CompleteBipartiteGraph}

    @boundscheck i ∈ Base.OneTo(length(nbs)) || throw(BoundsError(nbs, i))

    g = nbs.graph
    T = eltype(g)
    m::T = g.m
    n::T = g.n
    v::T = nbs.vertex

    return ifelse(v <= m, T(i) + m, T(i))
end

Base.IndexStyle(::Type{<:OutNeighborVector{V, G}}) where {V, G <: CompleteBipartiteGraph} = IndexLinear()


# =======================================================
#         converting
# =======================================================

Base.convert(::Type{SimpleGraph}, g::CompleteBipartiteGraph{T}) where {T} = complete_bipartite_graph(g.m, g.n)
Base.convert(::Type{SimpleGraph{T}}, g::CompleteBipartiteGraph) where {T} = complete_bipartite_graph(T(g.m), g.n)
