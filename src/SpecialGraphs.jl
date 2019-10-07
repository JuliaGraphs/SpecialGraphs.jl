module SpecialGraphs

import LightGraphs
const LG = LightGraphs

import Base.eltype, Base.convert, Base.size, Base.getindex, Base.IndexStyle

using LightGraphs: AbstractGraph, SimpleGraph,
                   nv, ne, outneighbors, edgetype,
                   inneighbors, vertices, edges, Edge,
                   has_vertex, has_edge, SimpleGraph, cycle_graph

export CycleGraph, WheelGraph, PathGraph, CompleteGraph

include("utils.jl")
include("CycleGraph.jl")
include("WheelGraph.jl")
include("PathGraph.jl")
include("CompleteGraph.jl")

end # module
