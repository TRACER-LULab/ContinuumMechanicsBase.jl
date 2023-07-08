using ContinuumMechanicsBase
using Test
using LinearAlgebra

@testset "ContinuumMechanicsBase.jl" begin
    F = I(3)
    @test I₁(F) = 3
    @test I₂(F) = 3
    @test I₃(F) = 1
    @test J(F)= 1
    @test_throws
end
