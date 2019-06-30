using SpecialGraphs
using Test

import LightGraphs
const LG = LightGraphs

@testset "WheelGraph" begin
    wg = WheelGraph{Int}(10)
    wgref = LG.WheelGraph(10)
    @test all(LG.pagerank(wg) ≈ LG.pagerank(wgref))
end
