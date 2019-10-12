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

@testset "CycleGraph" begin
    @testset "CycleGraph{T}(n): (T = $T, n = $n)" for
        T in [UInt8, Int32, Int64],
        n in [0, 1, 2, 3, 8] ∪ (T == UInt8 ? (255,) : ()) # extremal case for UInt8

        @testset "Constructor CycleGraph(n::T)" begin
            g = CycleGraph(T(n))

            @test typeof(g) == CycleGraph{T}
            @test LG.nv(g) == n
        end

        @testset "Constructor CycleGraph{T}(n)" begin
            g = CycleGraph{T}(n)

            @test typeof(g) == CycleGraph{T}
            @test LG.nv(g) == n
        end

        g = CycleGraph{T}(n)

        @testset "vertices(g)" begin
            @test eltype(LG.vertices(g)) == T
            @test collect(LG.vertices(g)) == 1:n
        end

        @testset "ne(g)" begin
            @test typeof(LG.ne(g)) == Int
            ne_expected =
                if n == 0 || n == 1
                    0
                elseif n == 2
                    1
                else
                    n
                end
            @test LG.ne(g) == ne_expected
        end

        @testset "eltype" begin
            @test eltype(g) == T
            @test eltype(typeof(g)) == T
        end

        @testset "edgetype" begin
            @test LG.edgetype(g) == LG.Edge{T}
            @test LG.edgetype(typeof(g)) == LG.Edge{T}
        end

        @testset "is_directed" begin
            @test LG.is_directed(typeof(g)) == false
        end

        @testset "has_vertex(g, $v)" for
            v in [-1, 0, 1, 2, 255]

            has_vertex_expected = v ∈ 1:n
            @test LG.has_vertex(g, v) == has_vertex_expected
        end

        @testset "has_edge(g, $src, $dst)" for
            (src, dst) in [(1, 2), (2, 1), (1, 3), (0, 1), (1, n), (n, 1), (n, n +1)]

            has_edge_expected =
                src in 1:n && dst in 1:n &&
                ((max(src, dst) - min(src, dst) == 1) || (min(src, dst) == 1 && max(src, dst) == n))

            @test LG.has_edge(g, src, dst) == has_edge_expected
        end

        @testset "edges(g)" begin
            edges = LG.edges(g)

            @testset "eltype" begin
                @test eltype(edges) == LG.edgetype(g)
                @test eltype(typeof(edges)) == LG.edgetype(g)
            end

            @testset "length" begin
                @test length(edges) == LG.ne(g)
            end

            @testset "lexicographicaly sorted and unique" begin
                # No order defined on Edge so we convert to Tuple first
                tuples = map(Tuple, edges)
                @test issorted(tuples)
                @test allunique(tuples)
            end

            @testset "are edges of g" begin
                @test all(e -> LG.has_edge(g, e), edges)
            end
        end

        @testset "outneigbors(g, $v)" for v in (unique([1, 2, n - 1, n]) ∩ LG.vertices(g))
            outneighbors = LG.outneighbors(g, v)

            @testset "same as inneighbors" begin
                @test LG.inneighbors(g, v) == outneighbors
            end

            @testset "eltype" begin
                @test eltype(outneighbors) == T
                @test eltype(typeof(outneighbors)) == T
            end

            @testset "length" begin
                length_expected =
                    if n == 0 || n == 1
                        0
                    elseif n == 2
                        1
                    else
                        2
                    end
                @test length(outneighbors) == length_expected
            end

            @testset "issorted and unique" begin
                @test issorted(outneighbors)
                @test allunique(outneighbors)
            end

            @testset "correct values" begin
                if n == 2
                    @test first(outneighbors) == (v == 1 ? 2 : 1)
                elseif n >= 3
                    n1, n2 = outneighbors

                    n1_expected, n2_expected =
                        if v == 1
                            (2, n)
                        elseif v == n
                            (1, n - 1)
                        else
                            (v - 1, v + 1)
                        end
                    @test (n1, n2) == (n1_expected, n2_expected)
                end
            end
        end

        @testset "converting to SimpleGraph" begin

            gsimple = LG.SimpleGraph(g)
            @test gsimple == LG.cycle_graph(T(n))
            @test eltype(g) == eltype(gsimple)
        end

        @testset "pagerank" begin
            if n > 0 # pagerank does not work for empty graphs
                @test LG.pagerank(g) ≈ LG.pagerank(LG.cycle_graph(T(n)))
            end
        end
    end
end


@testset "CompleteBipartiteGraph" begin
    @testset "CompleteBipartiteGraph{T}(m, n): (T = $T, m = $m, n = $n)" for
        T in [UInt8, Int32, Int64],
        (m, n) in [(0, 0), (1, 0), (0, 2), (3, 1), (3, 4), (7, 5)] ∪ (T == UInt8 ? [(255, 0), (127, 128), (1, 244)] : ()) # extremal cases for UInt8

        @testset "Constructor CompleteBipartiteGraph(m::T, n::T)" begin
            g = CompleteBipartiteGraph(T(m), T(n))

            @test typeof(g) == CompleteBipartiteGraph{T}
            @test LG.nv(g) == (m + n)
        end

        @testset "Constructor CompleteBipartiteGraph{T}(m, n)" begin
            g = CompleteBipartiteGraph{T}(m, n)

            @test typeof(g) == CompleteBipartiteGraph{T}
            @test LG.nv(g) == (m + n)
        end

        g = CompleteBipartiteGraph{T}(m, n)

        @testset "vertices(g)" begin
            @test eltype(LG.vertices(g)) == T
            @test collect(LG.vertices(g)) == 1:(m + n)
        end

        @testset "ne(g)" begin
            @test typeof(LG.ne(g)) == Int
            @test LG.ne(g) == m * n
        end

        @testset "eltype" begin
            @test eltype(g) == T
            @test eltype(typeof(g)) == T
        end

        @testset "edgetype" begin
            @test LG.edgetype(g) == LG.Edge{T}
            @test LG.edgetype(typeof(g)) == LG.Edge{T}
        end

        @testset "is_directed" begin
            @test LG.is_directed(typeof(g)) == false
        end

        @testset "has_vertex(g, $v)" for
            v in [-1, 0, 1, 2, 255]

            has_vertex_expected = v ∈ 1:(m + n)
            @test LG.has_vertex(g, v) == has_vertex_expected
        end

        @testset "has_edge(g, $src, $dst)" for
            (src, dst) in [(1, 2), (2, 1), (1, 3), (0, 1), (1, n), (n, 1), (1, m + n), (m + n, n), (m + n - 1, m + n) ]

            (src ∉ 0:(m+n) || dst ∉ 0:(m+n)) && continue # otherwise we could get problems with truncating

            has_edge_expected = (src ∈ (1:m) && dst in (m+1 : m+n)) || (dst ∈ (1:m) && src in (m+1 : m+n))
            @test LG.has_edge(g, src, dst) == has_edge_expected
        end

        @testset "edges(g)" begin
            edges = LG.edges(g)

            @testset "eltype" begin
                @test eltype(edges) == LG.edgetype(g)
                @test eltype(typeof(edges)) == LG.edgetype(g)
            end

            @testset "correct IndexStyle" begin
                @test IndexStyle(edges) == IndexLinear()
                @test IndexStyle(typeof(edges)) == IndexLinear()
            end

            @testset "length" begin
                @test length(edges) == LG.ne(g)
            end

            @testset "lexicographicaly sorted and unique" begin
                # No order defined on Edge so we convert to Tuple first
                tuples = map(Tuple, edges)
                @test issorted(tuples)
                @test allunique(tuples)
            end

            @testset "are edges of g" begin
                @test all(e -> LG.has_edge(g, e), edges)
            end
        end

        @testset "outneigbors(g, $v)" for v in (unique([1, 2, m - 1, m, m + 1, m + 2, n + m - 1, n + m]) ∩ LG.vertices(g))
            outneighbors = LG.outneighbors(g, v)

            @testset "same as inneighbors" begin
                @test LG.inneighbors(g, v) == outneighbors
            end

            @testset "eltype" begin
                @test eltype(outneighbors) == T
                @test eltype(typeof(outneighbors)) == T
            end

            @testset "correct IndexStyle" begin
                @test IndexStyle(outneighbors) == IndexLinear()
                @test IndexStyle(typeof(outneighbors)) == IndexLinear()
            end

            @testset "length" begin
                length_expected = (v ∈ 1:m) ? n : m
                @test length(outneighbors) == length_expected
            end

            @testset "issorted and unique" begin
                @test issorted(outneighbors)
                @test allunique(outneighbors)
            end

            @testset "correct values" begin
                outneighbors_expected = (v ∈ 1:m) ? (m+1:m+n) : (1:m)
                @test outneighbors == outneighbors_expected
            end
        end

        @testset "convert(SimpleGraph, g)" begin

            gsimple = convert(LG.SimpleGraph, g)
            @test gsimple == LG.complete_bipartite_graph(T(m), T(n))
            @test gsimple == LG.complete_bipartite_graph(T(m), T(n))
            @test eltype(g) == eltype(gsimple)
            @test eltype(g) == eltype(gsimple)
        end

        @testset "convert(SimpleGraph{$T2}, g)" for T2 in (UInt32, Int64, UInt64)

            gsimple = convert(LG.SimpleGraph{T2}, g)
            @test gsimple == LG.complete_bipartite_graph(T2(m), T2(n))
            @test eltype(gsimple) == T2
        end

        @testset "pagerank" begin
            if m > 0 && n > 0 # pagerank does not work for empty graphs
                @test LG.pagerank(g) ≈ LG.pagerank(LG.complete_bipartite_graph(T(m), T(n)))
            end
        end
    end
end
