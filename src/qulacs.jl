module Qulacs

using PyCall

import ..@pyfunc
import ..@pyclass

export qulacs

const qulacs = PyNULL()

const qulacs_classes = [
    :CausalConeSimulator,
    :DensityMatrix,
    :GeneralQuantumOperator,
    :GradCalculator,
    :NoiseSimulator,
    :Observable,
    :ParametricQuantumCircuit,
    :PauliOperator,
    :QuantumCircuit,
    :QuantumCircuitSimulator,
    :QuantumGateBase,
    :QuantumGateMatrix,
    :QuantumGate_SingleParameter,
    :QuantumState,
    :QuantumStateBase,
    :StateVector,
]

const qulacs_functions = [
]

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
