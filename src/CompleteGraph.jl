
struct CompleteGraph{T<:Integer} <: LG.AbstractGraph{T}
    nv::Int
end

CompleteGraph(nv::Integer) = CompleteGraph{Int}(nv)

LG.edgetype(::CompleteGraph) = LG.Edge{Int}
LG.is_directed(::Type{<:CompleteGraph}) = false
LG.nv(g::CompleteGraph) = g.nv
LG.ne(g::CompleteGraph) = div(nv(g) * (nv(g)-1), 2)
LG.vertices(g::CompleteGraph) = 1:LG.nv(g)

LG.edges(g::CompleteGraph) = [Edge(i, j) for i in 1:nv(g)-1 for j in i+1:nv(g)]

function LG.outneighbors(g::CompleteGraph, v)
    return [v1 for v1 in vertices(g) if v1 != v]
end

LG.inneighbors(g::CompleteGraph, v) = outneighbors(g, v)

LG.has_vertex(g::CompleteGraph, v) = v <= LG.nv(g)

function LG.has_edge(g::CompleteGraph, v1, v2)
    if !has_vertex(g, v1) || !has_vertex(g, v2)
        return false
    end
    return v1 != v2
end
