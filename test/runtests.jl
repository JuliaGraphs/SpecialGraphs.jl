using SpecialGraphs
using Test

import LightGraphs
const LG = LightGraphs
using LightGraphs: Edge, edges

@testset "WheelGraph" begin
    @test !LG.is_directed(WheelGraph)
    @test !LG.is_directed(WheelGraph{Int})
    @test !LG.is_directed(WheelGraph{UInt})
    wg = WheelGraph(10)
    wgref = LG.WheelGraph(10)
    @test eltype(wg) == Int
    @test eltype(WheelGraph{Int8}(Int8(5))) == Int8
    @test LG.edgetype(WheelGraph{Int8}(Int8(5))) == LG.Edge{Int8}
    @test LG.edgetype(wg) <: Edge
    @test LG.has_vertex(wg, 10)
    @test !LG.has_vertex(wg, 11)
    @test !LG.has_edge(wg, 10, 11)
    @test LG.has_edge(wg, 10, 2) # boundary condition
    @test all(LG.pagerank(wg) ≈ LG.pagerank(wgref))
    @test LG.ne(wg) == LG.ne(wgref)
    for ninit in (1, 2, 5)
        @test all(LG.bfs_parents(wg, ninit) .== LG.bfs_parents(wgref, ninit))
        @test all(LG.dfs_parents(wg, ninit) .== LG.dfs_parents(wgref, ninit))
    end
    for i in 2:LG.nv(wg)-1
        e = LG.edges(wg)
        @test Edge(i, i+1) in e
        @test LG.has_edge(wg, i, i+1)
        @test Edge(1, i) in e
        @test LG.has_edge(wg, 1, i)
    end
    @test !LG.has_edge(wg, 2, 4)
end

@testset "PathGraph" begin
    pg = PathGraph(10)
    @test eltype(pg) == Int
    @test eltype(PathGraph{Int8}(Int8(5))) == Int8
    @test LG.edgetype(PathGraph{Int8}(Int8(5))) == LG.Edge{Int8}
    @test !LG.is_directed(PathGraph)
    @test !LG.is_directed(PathGraph{Int})
    @test !LG.is_directed(PathGraph{UInt})
    @test LG.edgetype(pg) <: Edge
    pgref = LG.PathGraph(10)
    @test LG.has_vertex(pg, 10)
    @test !LG.has_vertex(pg, 11)
    @test !LG.has_edge(pg, 10, 11)
    @test all(LG.pagerank(pg) ≈ LG.pagerank(pgref))
    @test LG.ne(pg) == LG.ne(pgref)
    for ninit in (1, 2, 5)
        @test all(LG.dfs_parents(pg, ninit) .== LG.dfs_parents(pgref, ninit))
        @test all(LG.dfs_parents(pg, ninit) .== LG.dfs_parents(pgref, ninit))
    end
    e = edges(pg)
    for v in 2:9
        @test length(LG.outneighbors(pg, v)) == 2
        @test LG.has_edge(pg, v-1, v)
        @test Edge(v-1, v) in e
    end
    @test LG.has_edge(pg, 9, 10)
end

@testset "CompleteGraph" begin
    cg = CompleteGraph(10)
    @test eltype(cg) == Int
    @test eltype(CompleteGraph{Int8}(Int8(5))) == Int8
    @test LG.edgetype(CompleteGraph{Int8}(Int8(5))) == LG.Edge{Int8}
    @test !LG.is_directed(CompleteGraph)
    @test !LG.is_directed(CompleteGraph{Int})
    @test !LG.is_directed(CompleteGraph{UInt})
    @test LG.edgetype(cg) <: Edge
    cgref = LG.CompleteGraph(10)
    @test !LG.has_vertex(cg, 0)
    @test !LG.has_vertex(cg, 11)
    @test !LG.has_edge(cg, 10, 11)
    @test LG.has_vertex(cg, 10)
    @test LG.ne(cg) == LG.ne(cgref)
    @test all(LG.pagerank(cg) ≈ LG.pagerank(cgref))
    for ninit in (1, 2, 5)
        @test all(LG.dfs_parents(cg, ninit) .== LG.dfs_parents(cgref, ninit))
        @test all(LG.dfs_parents(cg, ninit) .== LG.dfs_parents(cgref, ninit))
    end
    for v in LG.vertices(cg)
        @test length(LG.outneighbors(cg, v)) == LG.nv(cg) - 1
        e = LG.edges(cg)
        for v2 in LG.vertices(cg)
            if v == v2
                @test !LG.has_edge(cg, v, v2)
                @test !in(Edge(v, v2), e)
            else
                @test LG.has_edge(cg, v, v2)
                if v < v2
                    @test Edge(v, v2) in e
                end
            end
        end
    end
end
