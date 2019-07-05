using SpecialGraphs
using Test

import LightGraphs
const LG = LightGraphs

@testset "WheelGraph" begin
    wg = WheelGraph(10)
    wgref = LG.WheelGraph(10)
    @test LG.has_vertex(wg, 10)
    @test !LG.has_vertex(wg, 11)
    @test all(LG.pagerank(wg) ≈ LG.pagerank(wgref))
    for ninit in (1, 2, 5)
        @test all(LG.bfs_parents(wg, ninit) .== LG.bfs_parents(wgref, ninit))
        @test all(LG.dfs_parents(wg, ninit) .== LG.dfs_parents(wgref, ninit))
    end
end

@testset "PathGraph" begin
    pg = PathGraph(10)
    pgref = LG.PathGraph(10)
    @test LG.has_vertex(pg, 10)
    @test !LG.has_vertex(pg, 11)
    @test all(LG.pagerank(pg) ≈ LG.pagerank(pgref))
    for ninit in (1, 2, 5)
        @test all(LG.dfs_parents(pg, ninit) .== LG.dfs_parents(pgref, ninit))
        @test all(LG.dfs_parents(pg, ninit) .== LG.dfs_parents(pgref, ninit))
    end
    for v in 2:9
        @test length(LG.outneighbors(pg, v)) == 2
    end
end
