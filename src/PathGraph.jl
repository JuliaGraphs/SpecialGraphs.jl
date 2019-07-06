
"""
    PathGraph{T<:Integer}

A path graph, with each node linked to the previous and next one.
"""
struct PathGraph{T<:Integer} <: LG.AbstractGraph{T}
    nv::Int
    function PathGraph{T}(nv::Integer) where {T<:Integer}
        _nv = nv >= 0 ? Int(nv) : 0
        new{T}(_nv)
    end
end

PathGraph(nv::Integer) = PathGraph{Int}(nv)

LG.edgetype(::PathGraph) = LG.Edge{Int}
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
