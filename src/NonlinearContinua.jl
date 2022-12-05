module NonlinearContinua

using LinearAlgebra
using Accessors

abstract type AbstractMaterialModel end
abstract type AbstractMaterialState end
abstract type AbstractMaterialTest end

export I₁, I₂, I₃, J
export MaterialHistory, update_history, update_history!
export predict

## Material Tests
"""
`predict(ψ::AbstractMaterialModel, test::AbstractMaterialTest, ps)`

Fields:
- `ψ`: Material Model
- `test` or `tests`: A single test or vector of tests. This is used to predict the response of the model in comparison to the experimental data provided.
- `ps`: Model parameters to be used.
"""
function predict(ψ::AbstractMaterialModel, test::AbstractMaterialTest, ps)
    @error "Method not implemented for model $(typeof(ψ)) and test $(typeof(test))"
end
function predict(ψ::AbstractMaterialModel, tests::Vector{<:AbstractMaterialTest}, ps)
    f(test) = predict(ψ, test, ps)
    results = map(f, tests)
    return results
end

"""
`MaterialHistory(values::Vector, times::Vector)`

Structure for storing the behavior of a material as it evolves in time. Design to be used in time-dependent models such as viscoelasticity.

"""
struct MaterialHistory{T,S} <: AbstractMaterialState
    value::Vector{T}
    time::Vector{S}
    function MaterialHistory(values::Vector, times::Vector)
        new{eltype(values),eltype(times)}(values, times)
    end
end
value(history::MaterialHistory) = history.value
time(history::MaterialHistory) = history.time

"""
`update_history!(history::MaterialHistory, value, time)`

Update the material history with the provided time an value.
"""
function update_history!(history::MaterialHistory, value, time)
    push!(history.value, value)
    push!(history.time, time)
    return nothing
end

"""
`update_history(history::MaterialHistory, value, time)`

Update the material history with the provided time an value.
"""
function update_history(history::MaterialHistory, value, time)
    history = @set history.value = vcat(history.value, [value])
    history = @set history.time = vcat(history.time, [time])
    return history
end

## Energy Models
for Model ∈ [
    :StrainEnergyDensity,
    :StrainEnergyDensity!,
]
    @eval export $Model
    @eval @inline function $Model(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
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
    @eval export $Tensor
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
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
    @eval export $Tensor
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
end


## Strain Tensors
for Tensor ∈ [
    :GreenStrainTensor,
    :AlmansiStrainTensor,
    :GreenStrainTensor!,
    :AlmansiStrainTensor!,
]
    @eval export $Tensor
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
end

## Time Dependent Tensors
# Deformation
for Tensor ∈ [
    :VelocityGradientTensor,
    :VelocityGradientTensor!,
]
    @eval export $Tensor
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
end

## Electric Field Tensors

## Charge Displacement Tensors

## Tensor Invariant Calculations
I₁(T::AbstractMatrix) = tr(T)
I₂(T::AbstractMatrix) = 1 / 2 * (tr(T)^2 - tr(T^2))
I₃(T::AbstractMatrix) = det(T)
J(T::AbstractMatrix) = sqrt(det(T))

end
