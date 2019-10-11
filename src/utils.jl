

"""
    OutNeighborsIter

A structure for iterating over the out neighbors in a graph for a certain vertex.
"""
struct OutNeighborsIter{V, G <: LG.AbstractGraph{V}}
    graph::G
    vertex::V
end

Base.eltype(::Type{<:OutNeighborsIter{V, G}}) where {V, G} = eltype(G)  

"""
    OutNeighborVector <: AbstractVector
A structure for iterating over the out neighbors in a graph for a certain vertex.
"""
struct OutNeighborVector{V, G <: AbstractGraph{V}} <: AbstractVector{V}
    graph::G
    vertex::V
end

"""
    SimpleEdgeVector <: AbstractVector
A structure for iterating over the edges of a graph
"""
struct SimpleEdgeVector{V, G <: AbstractGraph{V}} <: AbstractVector{LG.Edge{V}}
    graph::G
end
