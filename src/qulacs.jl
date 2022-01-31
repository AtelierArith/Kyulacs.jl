module Qulacs

using PyCall

export qulacs

const qulacs = PyNULL()

const qulacs_class = [
    :DensityMatrix, :QuantumGate_SingleParameter,
    :GeneralQuantumOperator, :QuantumState,
    :Observable, :QuantumStateBase,
    :ParametricQuantumCircuit, :StateVector,
    :PauliOperator,                #:circuit
    :QuantumCircuit,               #:gate
    :QuantumCircuitSimulator,      #:observable
    :QuantumGateBase,              #:quantum_operator
    :QuantumGateMatrix,            #:state
]

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

# Write your package code here.
function __init__()
    copy!(qulacs, pyimport("qulacs"))
end

end
