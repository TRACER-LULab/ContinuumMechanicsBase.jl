module ContinuumMechanicsBase

using LinearAlgebra
using RecursiveArrayTools
using DocStringExtensions

abstract type AbstractMaterialModel end
abstract type AbstractMaterialState end
abstract type AbstractMaterialTest end

export I₁, I₂, I₃, J
export MaterialHistory, update_history, update_history!
export predict

## Material Tests
"""
$(TYPEDSIGNATURES)

Fields:
- `ψ`: Material Model
- `test` or `tests`: A single test or vector of tests. This is used to predict the response of the model in comparison to the experimental data provided.
- `ps`: Model parameters to be used.
"""
function predict(ψ::AbstractMaterialModel, test::AbstractMaterialTest, ps; kwargs...)
    @error "Method not implemented for model $(typeof(ψ)) and test $(typeof(test))"
end

function predict(ψ::AbstractMaterialModel, tests::Vector{<:AbstractMaterialTest}, ps; kwargs...)
    f(test) = predict(ψ, test, ps; kwargs...)
    results = map(f, tests)
    return results
end

"""
$(TYPEDSIGNATURES)

Structure for storing the behavior of a material as it evolves in time. Design to be used in time-dependent models such as viscoelasticity.

"""
struct MaterialHistory{T} <: AbstractMaterialState
    value::VectorOfArray
    time::Vector{T}
    function MaterialHistory(value::Vector, time::T) where { T}
        new{T}(VectorOfArray([value]), [time])
    end
    function MaterialHistory(value::Matrix, time::T) where {T}
        new{T}(VectorOfArray([value]), [time])
    end
end

## Energy Models
for Model ∈ [
    :StrainEnergyDensity,
    :StrainEnergyDensity!,
]
    name = string(Model)
    @eval begin
        export $Model
        @doc """$($(name))(Model, State, Parameters; kwargs...)
        """
        $Model(M::AbstractMaterialModel, S, P; kwargs...) = nothing
    end
end
## Stress Tensors
for Tensor ∈ [
    :FirstPiolaKirchoffStressTensor,
    :SecondPiolaKirchoffStressTensor,
    :CauchyStressTensor,
    :FirstPiolaKirchoffStressTensor!,
    :SecondPiolaKirchoffStressTensor!,
    :CauchyStressTensor!,
]
    name = string(Tensor)
    @eval begin
        export $Tensor
        @doc """$($(name))(Model, State, Parameters; kwargs...)
        """
        $Tensor(M::AbstractMaterialModel, S, P; kwargs...) = nothing
    end
end
## Deformation Tensors
for Tensor ∈ [
    :DeformationGradientTensor,
    :InverseDeformationGradientTensor,
    :RightCauchyGreenDeformationTensor,
    :LeftCauchyGreenDeformationTensor,
    :InverseLeftCauchyGreenDeformationTensor,
    :DeformationGradientTensor!,
    :InverseDeformationGradientTensor!,
    :RightCauchyGreenDeformationTensor!,
    :LeftCauchyGreenDeformationTensor!,
    :InverseLeftCauchyGreenDeformationTensor!,
]
    name = string(Tensor)
    @eval begin
        export $Tensor
        @doc """$($(name))(Model, State, Parameters; kwargs...)
        """
        $Tensor(M::AbstractMaterialModel, S, P; kwargs...) = nothing
    end
end


## Strain Tensors
for Tensor ∈ [
    :GreenStrainTensor,
    :AlmansiStrainTensor,
    :GreenStrainTensor!,
    :AlmansiStrainTensor!,
]
    name = string(Tensor)
    @eval begin
        export $Tensor
        @doc """$($(name))(Model, State, Parameters; kwargs...)
        """
        $Tensor(M::AbstractMaterialModel, S, P; kwargs...) = nothing
    end
end

## Time Dependent Tensors
# Deformation
for Tensor ∈ [
    :VelocityGradientTensor,
    :VelocityGradientTensor!,
]
    name = string(Tensor)
    @eval begin
        export $Tensor
        @doc """$($(name))(Model, State, Parameters; kwargs...)
        """
        $Tensor(M::AbstractMaterialModel, S, P; kwargs...) = nothing
    end
end

## Electric Field Tensors

## Charge Displacement Tensors

## Tensor Invariant Calculations
"""
$(TYPEDSIGNATURES)

``I_1 = \\text{tr}(T)``
"""
I₁(T::AbstractMatrix) = tr(T)
"""
$(TYPEDSIGNATURES)

``I_2 = \\frac{1}{2}\\left(\\text{tr}(T)^2 - \\text{tr}(T^2)\\right)``
"""
I₂(T::AbstractMatrix) = 1 / 2 * (tr(T)^2 - tr(T^2))
"""
$(TYPEDSIGNATURES)

``I_3 = \\det{T}``
"""
I₃(T::AbstractMatrix) = det(T)
"""
$(TYPEDSIGNATURES)
"""
J(T::AbstractMatrix) = sqrt(det(T))

end
