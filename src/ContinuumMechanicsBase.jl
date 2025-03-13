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
export parameters, parameter_bounds, MaterialOptimizationProblem

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

-`ψ`: Material Model

Returns:
- Tuple of symbols for material model parameters
"""
function parameters(::M) where {M<:ContinuumMechanicsBase.AbstractMaterialModel}
    @error "Method not implemented for model $M."
end

"""
$(TYPEDSIGNATURES)

Structure for storing the behavior of a material as it evolves in time. Design to be used in time-dependent models such as viscoelasticity.

"""
struct MaterialHistory{T} <: AbstractMaterialState
    value::VectorOfArray
    time::Vector{T}
    function MaterialHistory(value::Vector, time::T) where {T}
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

"""
$(SIGNATURES)

Creates an `OptimizationProblem` for use in [`Optimization.jl`](https://docs.sciml.ai/Optimization/stable/) to find the optimal parameters.

# Arguments:
- `ψ`: material model to use
- `test` or `tests`: A single or vector of `::AbstractMaterialTest`s to use when fitting the parameters
- `u₀`: Initial guess for parameters
- `ps`: Any additional parameters for calling `predict()`
- `adb`: Select differentiation type from [`ADTypes.jl`](https://github.com/SciML/ADTypes.jl). The type is automatically applied to the type of AD applied to the `OptimizationProblem` also.
- `loss`: Loss function from [`LossFunctions.jl`](https://github.com/JuliaML/LossFunctions.jl)
"""
function MaterialOptimizationProblem(ψ::M, test, u₀, ps, adb, loss) where {M<:ContinuumMechanicsBase.AbstractMaterialModel}
    @error "MaterialOptimizationProblem is not implemented for $ψ"
end

"""
$(TYPEDSIGNATURES)

Default bounds for each parameter in tuple for optimization.
Without method dispatching for certain models, constants can be "optimized" in the range [-∞, ∞].
Use discretion whether this is realistic.
"""
function parameter_bounds(::M, ::ContinuumMechanicsBase.AbstractMaterialTest) where {M<:ContinuumMechanicsBase.AbstractMaterialModel}
    lb = nothing
    ub = nothing
    return (lb=lb, ub=ub)
end

function parameter_bounds(
    ψ::M,
    tests::Vector{ContinuumMechanicsBase.AbstractMaterialTest},
) where {M<:ContinuumMechanicsBase.AbstractMaterialModel}
    bounds = map(Base.Fix1(parameter_bounds, ψ), tests)
    lbs = getfield.(bounds, :lb)
    ubs = getfield.(bounds, :ub)
    if !(eltype(lbs) <: Nothing)
        lb_ps = fieldnames(eltype(lbs))
        lb = map(p -> p .=> maximum(getfield.(lbs, p)), lb_ps) |> NamedTuple
    else
        lb = nothing
    end
    if !(eltype(ubs) <: Nothing)
        ub_ps = fieldnames(eltype(ubs))
        ub = map(p -> p .=> minimum(getfield.(ubs, p)), ub_ps) |> NamedTuple
    else
        ub = nothing
    end
    return (lb=lb, ub=ub)
end

end # end of module
