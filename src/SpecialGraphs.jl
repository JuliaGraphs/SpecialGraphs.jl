module SpecialGraphs

import LightGraphs
const LG = LightGraphs

using LightGraphs: nv, ne, outneighbors, inneighbors, vertices, edges, Edge
export WheelGraph

include("WheelGraph.jl")

end # module
