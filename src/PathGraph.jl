
"""
    PathGraph{T<:Integer}

A path graph, with each node linked to the previous and next one.
"""
struct PathGraph{T<:Integer} <: LG.AbstractGraph{T}
    nv::T
    function PathGraph{T}(nv::T) where {T<:Integer}
        _nv = nv >= 0 ? T(nv) : zero(T)
        new{T}(_nv)
    end
end

PathGraph(nv::T) where {T<:Integer} = PathGraph{T}(nv)

LG.eltype(::PathGraph{T}) where {T} = T
LG.edgetype(::PathGraph{T}) where {T} = LG.Edge{T}
LG.is_directed(::Type{<:PathGraph}) = false
LG.nv(g::PathGraph) = g.nv
LG.ne(g::PathGraph) = LG.nv(g) - 1
LG.vertices(g::PathGraph) = 1:LG.nv(g)

LightGraphs.edges(g::PathGraph) = [LG.Edge(i, i+1) for i in 1:LG.nv(g)-1]

LightGraphs.has_vertex(g::PathGraph, v) = 1 <= v <= LG.nv(g)

function LightGraphs.outneighbors(g::PathGraph, v)
    LG.has_vertex(g, v) || return Int[]
    nv(g) > 1 || return Int[]
    if v == 1
        return [2]
    end
    if v == nv(g)
        return [nv(g)-1]
    end
    return [v-1, v+1]
end

LightGraphs.inneighbors(g::PathGraph, v) = outneighbors(g, v)

function LightGraphs.has_edge(g::PathGraph, v1, v2)
    if !has_vertex(g, v1) || !has_vertex(g, v2)
        return false
    end
    return abs(v1-v2) == 1
end

# =======================================================
#         overrides
# =======================================================

# we use this check so that we have the same convention as in LightGraphs
LG.is_connected(g::PathGraph) = nv(g) > 0

function LG.connected_components(g::PathGraph)

    nvg(g) == 0 && return typeof(vertices(g))[]
    return [vertices(g)]
end

# has_self_loops is defined in terms of this
LG.num_self_loops(::PathGraph) = 0

LG.is_bipartite(g::PathGraph) = true

function LG.squash(g::PathGraph)
    nvg = nv(g)
    for T ∈ (UInt8, UInt16, UInt32, UInt64)
        nv(g) < typemax(T) && return PathGraph(T(nvg))
    end
end

# ---- degree -----------------------------------

function LG.Δ(g::PathGraph)
    nvg = nv(g)
    return typemin(Int) * (nvg == 0) + (nvg >= 2) + (nvg >= 3)
end

LG.Δout(g::PathGraph) = Δ(g)
LG.Δin(g::PathGraph) = Δ(g)

function LG.δ(g::PathGraph)
    nvg = nv(g)
    return ifelse(nvg == 0, typemax(Int), ifelse(nvg == 1, 0, 1))
end

LG.δout(g::PathGraph) = δ(g)
LG.δin(g::PathGraph) = δ(g)

# =======================================================
#         matrices
# =======================================================

# TODO If there is a library that provides this, we could use a Toeplitz matrix instead
function LG.adjacency_matrix(g::PathGraph, T::DataType=Int)

    nvg = nv(g)
    dv = zeros(T, nv(g))
    ev = ones(T, max(0, nv(g) - 1))
    return SymTridiagonal(dv, ev)
end
