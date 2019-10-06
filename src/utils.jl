

"""
    OutNeighborsIter

A structure for iterating over the out neighbors in a graph for a certain vertex.
"""
struct OutNeighborsIter{V, G <: LG.AbstractGraph{V}}
    graph::G
    vertex::V
end

Base.eltype(::Type{<:OutNeighborsIter{V, G}}) where {V, G} = eltype(G)  

