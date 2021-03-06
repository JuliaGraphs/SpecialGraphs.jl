
struct WheelGraph{T <: Integer} <: LG.AbstractGraph{T}
    nv::T
end

LG.eltype(::WheelGraph{T}) where {T} = T
LG.edgetype(::WheelGraph{T}) where {T} = LG.Edge{T}
LG.is_directed(::Type{<:WheelGraph}) = false
LG.nv(g::WheelGraph) = g.nv
function LG.ne(g::WheelGraph)
    n = Int(nv(g))
    return 2 * (n - 1) - (n == 3) - (n == 2) + 2 * (n == 0)
end
LG.vertices(g::WheelGraph) = 1:LG.nv(g)

function LG.edges(g::WheelGraph)
    edges = Vector{LG.Edge{Int}}()
    # add inner edges
    for j in 1:LG.nv(g)-1
        push!(edges, LG.Edge(1, j+1))
    end
    # add perimeter
    for j in 2:LG.nv(g)-1
        push!(edges, LG.Edge(j, j+1))
    end
    push!(edges, LG.Edge(2, LG.nv(g)))
    return edges
end

function LG.outneighbors(g::WheelGraph, v)
    if v == 1
        return collect(2:LG.nv(g))
    end
    if v == 2
        return [1, 3, LG.nv(g)]
    end
    if v == LG.nv(g)
        return [1, 2, LG.nv(g)-1]
    end
    return [1, v-1, v+1]
end

LG.inneighbors(g::WheelGraph, v) = outneighbors(g, v)

LG.has_vertex(g::WheelGraph, v) = 1 <= v <= LG.nv(g)

function LG.has_edge(g::WheelGraph, v1, v2)
    v1, v2 = minmax(v1, v2)

    if !has_vertex(g, v1) || !has_vertex(g, v2)
        return false
    end
    # rayon
    if v1 == 1 && v2 > 1
        return true
    end
    # perimeter
    if v2 == v1 + 1
        return true
    end
    # boundary conditions
    if v1 == 2 && v2 == LG.nv(g) && v1 != v2
        return true
    end
    return false
end

# =======================================================
#         overrides
# =======================================================

# we use this check so that we have the same convention as in LightGraphs
LG.is_connected(g::WheelGraph) = nv(g) > 0

function LG.connected_components(g::WheelGraph)

    nv(g) == 0 && return typeof(vertices(g))[]
    return [vertices(g)]
end

# has_self_loops is defined in terms of this
LG.num_self_loops(::WheelGraph) = 0

LG.is_bipartite(g::WheelGraph) = nv(g) <= 2

function LG.squash(g::WheelGraph)
    nvg = nv(g)
    for T ∈ (UInt8, UInt16, UInt32, UInt64)
        nv(g) < typemax(T) && return WheelGraph(T(nvg))
    end
end

# ---- degree -----------------------------------

function LG.Δ(g::WheelGraph)
    nvg = nv(g)
    return ifelse(nvg == 0, typemin(Int), Int(nvg) - 1)
end

LG.Δout(g::WheelGraph) = Δ(g)
LG.Δin(g::WheelGraph) = Δ(g)

function LG.δ(g::WheelGraph)
    nvg = nv(g)
    return ifelse(nvg == 0, typemax(Int), ifelse(nvg <= 3, Int(nvg) - 1, 3))
end

LG.δout(g::WheelGraph) = δ(g)
LG.δin(g::WheelGraph) = δ(g)
