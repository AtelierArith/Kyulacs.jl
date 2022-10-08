module Qulacs

using PyCall

import ..@pyfunc
import ..@pyclass

export qulacs

const qulacs = PyNULL()

const qulacs_class = [
    :DensityMatrix, :QuantumGate_SingleParameter,
    :GeneralQuantumOperator, :QuantumState,
    :Observable, :QuantumStateBase,
    :ParametricQuantumCircuit, :StateVector,
    :PauliOperator,
    :QuantumCircuit,
    :QuantumCircuitSimulator,
    :QuantumGateBase,
    :QuantumGateMatrix,
]

#=
for class in qulacs_class
    @eval begin
        struct $class
            pyobj::PyObject
            $(class)(args...) = new(qulacs.$(class)(args...))
        end

        PyObject(t::$(class)) = t.pyobj

        function Base.propertynames(t::$(class))
            propertynames(getfield(t, :pyobj))
        end

        function Base.getproperty(t::$(class), s::Symbol)
            if s ∈ fieldnames($(class))
                return getfield(t, s)
            else
                return getproperty(getfield(t, :pyobj), s)
            end
        end

        export $(class)
    end
end
=#

for class in qulacs_class
    @eval begin
        @pyclass qulacs $(class)
        export $(class)
    end
end

function __init__()
    try
        # Try to import "scipy" from Python
        pyimport_conda("scipy", "scipy")
    catch e
        @warn """
        Kyulacs.$(nameof(@__MODULE__)) has failed to import scipy from Python.
        It is necessary to call `get_matrix` method with in a gate object or a observable object.
        Please make sure these are installed.
        """
    end
    copy!(qulacs, pyimport("qulacs"))
end

end
