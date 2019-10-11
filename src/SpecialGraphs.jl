module SpecialGraphs

import LightGraphs
const LG = LightGraphs

import Base.eltype, Base.IndexStyle

using LightGraphs: nv, ne, outneighbors,
                   inneighbors, vertices, edges, Edge, SimpleGraph, AbstractGraph,
                   has_vertex, has_edge, complete_bipartite_graph

export CompleteBipartiteGraph, CycleGraph, WheelGraph, PathGraph, CompleteGraph

include("utils.jl")
include("CompleteBipartiteGraph.jl")
include("CycleGraph.jl")
include("WheelGraph.jl")
include("PathGraph.jl")
include("CompleteGraph.jl")

end # module
