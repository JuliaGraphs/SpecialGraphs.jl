

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
struct SimpleEdgeVector{V, G <: LG.AbstractGraph{V}} <: AbstractVector{LG.Edge{V}}
    graph::G
end

