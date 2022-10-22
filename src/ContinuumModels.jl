module ContinuumModels

import Tensors.AbstractTensor
using LinearAlgebra

abstract type AbstractMaterialModel end
abstract type AbstractMaterialState end

export I₁, I₂, I₃, I1, I2, I3, J
## Energy Models
for Model ∈ [
    :StrainEnergyDensity
    ]
    @eval @inline function $Model(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
    @eval export $Model
end
## Stress Tensors
for Tensor ∈ [
    :FirstPiolaKirchoffStressTensor,
    :SecondPiolaKirchoffStressTensor,
    :CauchyStressTensor
]
    # @eval struct $Tensor{order,dim,T<:Number} <: AbstractTensor{order,dim,T} end
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
    @eval export $Tensor
end

## Deformation Tensors
for Tensor ∈ [
    :DeformationGradientTensor,
    :InverseDeformationGradientTensor,
    :RightCauchyGreenDeformationTensor,
    :LeftCauchyGreenDeformationTensor,
    :InverseLeftCauchyGreenDeformationTensor
]
    # @eval struct $Tensor{order,dim,T<:Number} <: AbstractTensor{order,dim,T} end
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
    @eval export $Tensor
end


## Strain Tensors
for Tensor ∈ [
    :GreenStrainTensor,
    :AlmansiStrainTensor
]
    # @eval struct $Tensor{order,dim,T<:Number} <: AbstractTensor{order,dim,T} end
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
    @eval export $Tensor
end

## Time Dependent Tensors
# Deformation
for Tensor ∈ [
    :VelocityGradientTensor
]
    # @eval struct $Tensor{order,dim,T<:Number} <: AbstractTensor{order,dim,T} end
    @eval @inline function $Tensor(M::AbstractMaterialModel, S::AbstractMaterialState, P) end
    @eval export $Tensor
end

## Electric Field Tensors

## Charge Displacement Tensors

## Tensor Invariant Calculations
I₁(T::AbstractMatrix) = tr(T)
I₂(T::AbstractMatrix) = 1/2*(tr(T) - tr(T^2))
I₃(T::AbstractMatrix) = det(T)
J(T::AbstractMatrix) = sqrt(det(T))
const I1 = I₁
const I2 = I₂
const I3 = I₃

## Precompile
using SnoopPrecompile

end
