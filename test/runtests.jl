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

    @testset "overrides for WheelGraph{T}(n): (T = $T, n = $n)" for
        T in [UInt8, Int32, Int64],
        n in [0, 1, 2, 3, 8] ∪ (T == UInt8 ? (255,) : ()) # extremal case for UInt8

        g = WheelGraph(T(n))
        gsimple = LG.wheel_graph(T(n))

        @testset "connectivity" begin

            @test LG.is_connected(g) == LG.is_connected(gsimple)
            @test LG.connected_components(g) == LG.connected_components(gsimple)
        end

        @testset "self-loops" begin

            @test LG.has_self_loops(g) == LG.has_self_loops(gsimple)
            @test LG.num_self_loops(g) == LG.num_self_loops(gsimple)
        end

        @testset "is_bipartite" begin

            @test LG.is_bipartite(g) == LG.is_bipartite(gsimple)
        end

        @testset "squash" begin

            g_squashed = LG.squash(g)
            gsimple_squashed = LG.squash(gsimple)

            @test typeof(g_squashed) == WheelGraph{eltype(gsimple_squashed)}
            @test LG.nv(g) == LG.nv(gsimple_squashed)
            @test LG.ne(g) == LG.ne(gsimple_squashed)
        end

        @testset "min/max degree" begin

            @test typeof(LG.Δ(g)) == Int
            @test LG.Δ(g) == LG.Δ(gsimple)

            @test typeof(LG.Δout(g)) == Int
            @test LG.Δout(g) == LG.Δout(gsimple)

            @test typeof(LG.Δin(g)) == Int
            @test LG.Δin(g) == LG.Δin(gsimple)

            @test typeof(LG.δ(g)) == Int
            @test LG.δ(g) == LG.δ(gsimple)

            @test typeof(LG.δout(g)) == Int
            @test LG.δout(g) == LG.δout(gsimple)

            @test typeof(LG.δin(g)) == Int
            @test LG.δin(g) == LG.δin(gsimple)

        end

    end
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

    @testset "overrrides for PathGraph{T}(n): (T = $T, n = $n)" for
        T in [UInt8, Int32, Int64],
        n in [0, 1, 2, 3, 8] ∪ (T == UInt8 ? (255,) : ()) # extremal case for UInt8

        g = PathGraph(T(n))
        gsimple = LG.path_graph(T(n))

        @testset "connectivity" begin

            @test LG.is_connected(g) == LG.is_connected(gsimple)
            @test LG.connected_components(g) == LG.connected_components(gsimple)
        end

        @testset "self-loops" begin

            @test LG.has_self_loops(g) == LG.has_self_loops(gsimple)
            @test LG.num_self_loops(g) == LG.num_self_loops(gsimple)
        end

        @testset "is_bipartite" begin

            @test LG.is_bipartite(g) == LG.is_bipartite(gsimple)
        end

        @testset "squash" begin

            g_squashed = LG.squash(g)
            gsimple_squashed = LG.squash(gsimple)

            @test typeof(g_squashed) == PathGraph{eltype(gsimple_squashed)}
            @test LG.nv(g) == LG.nv(gsimple_squashed)
            @test LG.ne(g) == LG.ne(gsimple_squashed)
        end

        @testset "min/max degree" begin

            @test typeof(LG.Δ(g)) == Int
            @test LG.Δ(g) == LG.Δ(gsimple)

            @test typeof(LG.Δout(g)) == Int
            @test LG.Δout(g) == LG.Δout(gsimple)

            @test typeof(LG.Δin(g)) == Int
            @test LG.Δin(g) == LG.Δin(gsimple)

            @test typeof(LG.δ(g)) == Int
            @test LG.δ(g) == LG.δ(gsimple)

            @test typeof(LG.δout(g)) == Int
            @test LG.δout(g) == LG.δout(gsimple)

            @test typeof(LG.δin(g)) == Int
            @test LG.δin(g) == LG.δin(gsimple)

        end

        # we must exclude this case because of an error
        # in LightGraphs.adjacency_matrix(::SimpleGraph)
        if !(T == UInt8 && n == 255)
            @testset "adjacency_matrix(g, T2): T2 = $T2" for
                T2 in (Bool, Int, Int8, UInt8)

                @test eltype(LG.adjacency_matrix(g, T2)) == T2
                @test LG.adjacency_matrix(g, T2) == LG.adjacency_matrix(gsimple, T2)
            end
        end
    end
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

    @testset "overrrides for CompleteGraph{T}(n): (T = $T, n = $n)" for
        T in [UInt8, Int32, Int64],
        n in [0, 1, 2, 3, 8] ∪ (T == UInt8 ? (255,) : ()) # extremal case for UInt8

        g = CompleteGraph{T}(n)
        gsimple = LG.complete_graph(T(n))

        @testset "connectivity" begin

            @test LG.is_connected(g) == LG.is_connected(gsimple)
            @test LG.connected_components(g) == LG.connected_components(gsimple)
        end

        @testset "self-loops" begin

            @test LG.has_self_loops(g) == LG.has_self_loops(gsimple)
            @test LG.num_self_loops(g) == LG.num_self_loops(gsimple)
        end

        @testset "is_bipartite" begin

            @test LG.is_bipartite(g) == LG.is_bipartite(gsimple)
        end

        @testset "squash" begin

            g_squashed = LG.squash(g)
            gsimple_squashed = LG.squash(gsimple)

            @test typeof(g_squashed) == CompleteGraph{eltype(gsimple_squashed)}
            @test LG.nv(g) == LG.nv(gsimple_squashed)
            @test LG.ne(g) == LG.ne(gsimple_squashed)
        end

        @testset "min/max degree" begin

            @test typeof(LG.Δ(g)) == Int
            @test LG.Δ(g) == LG.Δ(gsimple)

            @test typeof(LG.Δout(g)) == Int
            @test LG.Δout(g) == LG.Δout(gsimple)

            @test typeof(LG.Δin(g)) == Int
            @test LG.Δin(g) == LG.Δin(gsimple)

            @test typeof(LG.δ(g)) == Int
            @test LG.δ(g) == LG.δ(gsimple)

            @test typeof(LG.δout(g)) == Int
            @test LG.δout(g) == LG.δout(gsimple)

            @test typeof(LG.δin(g)) == Int
            @test LG.δin(g) == LG.δin(gsimple)

        end

        @testset "degree(g)" begin

            @test LG.degree(g) isa AbstractVector{Int}
            @test LG.degree(g) == LG.degree(gsimple)

            @test LG.indegree(g) isa AbstractVector{Int}
            @test LG.indegree(g) == LG.indegree(gsimple)

            @test LG.outdegree(g) isa AbstractVector{Int}
            @test LG.outdegree(g) == LG.outdegree(gsimple)
        end

        @testset "degree(g, vs): vs = $vs" for
            vs in ( Int8[], [1, 1], Int16[1, 2], [2, 1], 1:n, UInt32[n, max(0, n - 1), n])

            vs ⊆ LG.vertices(g) || continue # otherwise we get bound errors

            @test LG.degree(g, vs) isa AbstractVector{Int}
            @test LG.degree(g, vs) == LG.degree(gsimple, vs)

            @test LG.indegree(g) isa AbstractVector{Int}
            @test LG.indegree(g, vs) == LG.indegree(gsimple, vs)

            @test LG.outdegree(g) isa AbstractVector{Int}
            @test LG.outdegree(g, vs) == LG.outdegree(gsimple, vs)
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
            (src, dst) in unique([(1, 1), (1, 2), (2, 1), (1, 3), (0, 1), (1, n), (n, 1), (n, n +1)])

            has_edge_expected =
                src in 1:n && dst in 1:n && src != dst &&
                ((max(src, dst) - min(src, dst) == 1) || (min(src, dst) == 1 && max(src, dst) == n))

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

        @testset "outneigbors(g, $v)" for v in (unique([1, 2, n - 1, n]) ∩ LG.vertices(g))
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

        @testset "convert(SimpleGraph, g)" begin

            gsimple = convert(LG.SimpleGraph, g)
            @test gsimple == LG.cycle_graph(T(n))
            @test eltype(g) == eltype(gsimple)
        end

        @testset "convert(SimpleGraph{$T2}, g)" for T2 in (UInt32, Int64, UInt64)

            gsimple = convert(LG.SimpleGraph{T2}, g)
            @test gsimple == LG.cycle_graph(T2(n))
            @test eltype(gsimple) == T2
        end

        @testset "pagerank" begin
            if n > 0 # pagerank does not work for empty graphs
                @test LG.pagerank(g) ≈ LG.pagerank(LG.cycle_graph(T(n)))
            end
        end

        @testset "overrrides" begin

        gsimple = convert(LG.SimpleGraph, g)

        @testset "connectivity" begin

            @test LG.is_connected(g) == LG.is_connected(gsimple)
            @test LG.connected_components(g) == LG.connected_components(gsimple)
        end

        @testset "self-loops" begin

            @test LG.has_self_loops(g) == LG.has_self_loops(gsimple)
            @test LG.num_self_loops(g) == LG.num_self_loops(gsimple)
        end

        @testset "is_bipartite" begin

            @test LG.is_bipartite(g) == LG.is_bipartite(gsimple)
        end

        @testset "squash" begin

            g_squashed = LG.squash(g)
            gsimple_squashed = LG.squash(gsimple)

            @test typeof(g_squashed) == CycleGraph{eltype(gsimple_squashed)}
            @test LG.nv(g) == LG.nv(gsimple_squashed)
            @test LG.ne(g) == LG.ne(gsimple_squashed)
        end

        @testset "min/max degree" begin

            @test typeof(LG.Δ(g)) == Int
            @test LG.Δ(g) == LG.Δ(gsimple)

            @test typeof(LG.Δout(g)) == Int
            @test LG.Δout(g) == LG.Δout(gsimple)

            @test typeof(LG.Δin(g)) == Int
            @test LG.Δin(g) == LG.Δin(gsimple)

            @test typeof(LG.δ(g)) == Int
            @test LG.δ(g) == LG.δ(gsimple)

            @test typeof(LG.δout(g)) == Int
            @test LG.δout(g) == LG.δout(gsimple)

            @test typeof(LG.δin(g)) == Int
            @test LG.δin(g) == LG.δin(gsimple)

        end

        @testset "degree(g)" begin

            @test LG.degree(g) isa AbstractVector{Int}
            @test LG.degree(g) == LG.degree(gsimple)

            @test LG.indegree(g) isa AbstractVector{Int}
            @test LG.indegree(g) == LG.indegree(gsimple)

            @test LG.outdegree(g) isa AbstractVector{Int}
            @test LG.outdegree(g) == LG.outdegree(gsimple)
        end

        @testset "degree(g, vs): vs = $vs" for
            vs in ( Int8[], [1, 1], Int16[1, 2], [2, 1], 1:n, UInt32[n, max(0, n - 1), n])

            vs ⊆ LG.vertices(g) || continue # otherwise we get bound errors

            @test LG.degree(g, vs) isa AbstractVector{Int}
            @test LG.degree(g, vs) == LG.degree(gsimple, vs)

            @test LG.indegree(g) isa AbstractVector{Int}
            @test LG.indegree(g, vs) == LG.indegree(gsimple, vs)

            @test LG.outdegree(g) isa AbstractVector{Int}
            @test LG.outdegree(g, vs) == LG.outdegree(gsimple, vs)
        end

    end
    end
end
