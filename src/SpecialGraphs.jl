module SpecialGraphs

import LightGraphs
const LG = LightGraphs

using LightGraphs: nv, ne, outneighbors, inneighbors, vertices, edges, Edge

export WheelGraph, PathGraph

include("WheelGraph.jl")
include("PathGraph.jl")

end # module
