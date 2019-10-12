
struct CompleteGraph{T<:Integer} <: LG.AbstractGraph{T}
    nv::T
end

LG.eltype(::CompleteGraph{T}) where {T} = T
LG.edgetype(::CompleteGraph{T}) where {T} = LG.Edge{T}
LG.is_directed(::Type{<:CompleteGraph}) = false
LG.nv(g::CompleteGraph) = g.nv
LG.ne(g::CompleteGraph) = div(nv(g) * (nv(g)-1), 2)
LG.vertices(g::CompleteGraph) = 1:LG.nv(g)

LG.edges(g::CompleteGraph) = [Edge(i, j) for i in 1:nv(g)-1 for j in i+1:nv(g)]

function LG.outneighbors(g::CompleteGraph, v)
    return [v1 for v1 in vertices(g) if v1 != v]
end

LG.inneighbors(g::CompleteGraph, v) = outneighbors(g, v)

LG.has_vertex(g::CompleteGraph, v) = 1 <= v <= LG.nv(g)

function LG.has_edge(g::CompleteGraph, v1, v2)
    if !has_vertex(g, v1) || !has_vertex(g, v2)
        return false
    end
    return v1 != v2
end

# =======================================================
#         overrides
# =======================================================

# we use this check so that we have the same convention as in LightGraphs
LG.is_connected(::CompleteGraph) = nv(g) > 0

function LG.connected_components(g::CompleteGraph)

    nvg(g) == 0 && return typeof(vertices(g))[]
    return [vertices(g)]
end

# has_self_loops is defined in terms of this
LG.num_self_loops(::CompleteGraph) = 0

LG.is_bipartite(g::CompleteGraph) = (nv(g) <= 2)

function LG.squash(g::CompleteGraph)
    nvg = nv(g)
    for T ∈ (UInt8, UInt16, UInt32, UInt64)
        nv(g) < typemax(T) && return CompleteGraph(T(nvg))
    end
end

# ---- degree -----------------------------------

function LG.Δ(g::CompleteGraph)
    nvg = nv(g)
    return ifelse(nvg == 0, typemin(Int), Int(nvg) - 1)
end

LG.Δout(g::CompleteGraph) = Δ(g)
LG.Δin(g::CompleteGraph) = Δ(g)

function LG.δ(g::CompleteGraph)
    nvg = nv(g)
    return ifelse(nvg == 0, typemax(Int), Int(nvg) - 1)
end

LG.δout(g::CompleteGraph) = δ(g)
LG.δin(g::CompleteGraph) = δ(g)

LG.degree(g::CompleteGraph, vs::AbstractVector=vertices(g)) = Fill(Δ(g), length(vs))

LG.indegree(g::CompleteGraph, vs::AbstractVector=vertices(g)) = degree(g, vs)
LG.outdegree(g::CompleteGraph, vs::AbstractVector=vertices(g)) = degree(g, vs)
