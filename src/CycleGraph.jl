
# =======================================================
#         CycleGraph struct
# =======================================================

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

# ---- edges iterator -----------------------------------

LG.edges(g::CycleGraph) = LG.SimpleGraphs.SimpleEdgeIter(g)

Base.eltype(::Type{<:LG.SimpleGraphs.SimpleEdgeIter{G}}) where {T, G <: CycleGraph{T}} =
    LG.Edge{T}

function LG.iterate(iter::LG.SimpleGraphs.SimpleEdgeIter{G}) where {G <: CycleGraph}

    g = iter.g
    nvg = LG.nv(g)
    T = eltype(g)

    nvg <= one(T) && return nothing

    e = LG.Edge{T}(one(T), T(2))
    nvg == T(2) && return e, T(2)

    return e, T(1) 
end

function LG.iterate(iter::LG.SimpleGraphs.SimpleEdgeIter{G}, state) where {G <: CycleGraph}

    g = iter.g
    nvg = nv(g)
    T = eltype(g) 

   state == nvg && return nothing
    src = state
    dst = ifelse(state == one(T), nvg, state + one(T))
    e = LG.Edge{T}(src, dst)
        
    return e, (state + one(T))

end


# =======================================================
#        neighbors
# =======================================================

# TODO maybe we want an inbounds check
LG.outneighbors(g::CycleGraph, v::Integer) = OutNeighborsIter(g, eltype(g)(v))

LG.inneighbors(g::CycleGraph, v::Integer) = LG.outneighbors(g, v)
LG.neighbors(g::CycleGraph, v::Integer) = LG.outneighbors(g, v)
LG.all_neighbors(g::CycleGraph, v::Integer) = LG.outneighbors(g, v)

# ---- neighbors iterator -----------------------------------

struct OutNeighborsIter{T, G <: LG.AbstractGraph{T}}
    graph::G
    vertex::T
end

Base.eltype(::Type{<:OutNeighborsIter{T, G}}) where {T, G} = eltype(G)  

function LG.iterate(iter::OutNeighborsIter{T, G}) where {T, G <: CycleGraph}

    g = iter.graph
    v = iter.vertex
    nvg = nv(g)

    nvg <= one(T) && return nothing
    nvg == T(2)   && return (T(3) - v), zero(T)
    v == one(T)   && return v + one(T),       nvg
    v == nvg      && return one(T),     (v - one(T))

    return (v - one(T)), (v + one(T))
end

function LG.iterate(iter::OutNeighborsIter{T, G}, state) where {T, G <: CycleGraph}

    g = iter.graph

    state == zero(T) && return nothing
    return state, zero(T)
end

function Base.length(iter::OutNeighborsIter{T, G}) where {T, G <: CycleGraph}

    g = iter.graph
    nvg = nv(g)

    nvg <= one(T) && return 0
    nvg <= T(2) && return 1

    return 2
end


# =======================================================
#         converting
# =======================================================

LG.SimpleGraph(g::CycleGraph) = LG.cycle_graph(nv(g))

