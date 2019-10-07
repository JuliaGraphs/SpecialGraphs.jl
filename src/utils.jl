

"""
    OutNeighborsIter

A structure for iterating over the out neighbors in a graph for a certain vertex.
"""
struct OutNeighborsVector{V, G <: LG.AbstractGraph{V}} <: AbstractVector{V}
    graph::G
    vertex::V
end


