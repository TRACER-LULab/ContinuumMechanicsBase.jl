module OptimizationContinuumMechanicsBaseExt


using ContinuumMechanicsBase
using DocStringExtensions
using Optimization

export parameters, parameter_bounds


"""
$(TYPEDSIGNATURES)

Empty function call of model parameters tuple for optimization.
"""
function parameters(::M) where {M<:ContinuumMechanicsBase.AbstractMaterialModel} end

"""
$(TYPEDSIGNATURES)

Default bounds for each parameter in tuple for optimization.
Without method dispatching for certain models, constants can be "optimized" in the range [-∞, ∞].
Use discretion whether this is realistic.
"""
function parameter_bounds(::M, ::Any) where {M<:ContinuumMechanicsBase.AbstractMaterialModel}
    lb = nothing
    ub = nothing
    return (lb = lb, ub = ub)
end

function parameter_bounds(
            ψ       ::M,
            tests   ::Vector{Any},
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
    return (lb = lb, ub = ub)
end

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
function MaterialOptimizationProblem end



end # end of module
