module Gate

using PyCall
import ..@pyfunc
import ..@pyclass

# qulacs = PyNULL()
gate = PyNULL()

const gate_classes = [
    :Adaptive, :RX,
    :AmplitudeDampingNoise, :RY,
    :BitFlipNoise, :RZ,
    :CNOT, :RandomUnitary,
    :CP, :ReversibleBoolean,
    :CPTP, :S,
    :CZ, :SWAP,
    :DenseMatrix, :Sdag,
    :DephasingNoise, :SparseMatrix,
    :DepolarizingNoise, :StateReflection,
    :DiagonalMatrix, :T,
    :FREDKIN, :TOFFOLI,
    :H, :Tdag,
    :Identity, :TwoQubitDepolarizingNoise,
    :IndependentXZNoise, :U1,
    :Instrument, :U2,
    :Measurement, :U3,
    :P0, :X,
    :P1, :Y,
    :ParametricPauliRotation, :Z,
    :ParametricRX,               #:add,
    :ParametricRY,               #:merge,
    :ParametricRZ,               #:sqrtX,
    :Pauli,                      #:sqrtXdag,
    :PauliRotation,              #:sqrtY,
    :Probabilistic,              #:sqrtYdag,
    :ProbabilisticInstrument,    #:to_matrix_gate,
]

#=
for class in gate_classes
    @eval begin
        struct $class
            pyobj::PyObject
            $(class)(args...) = new(qulacs.gate.$(class)(args...))
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

for class in gate_classes
    @eval begin
        @pyclass gate $(class)
        export $(class)
    end
end

const gate_functions = [
    :add,
    :merge,
    :sqrtX,
    :sqrtXdag,
    :sqrtY,
    :sqrtYdag,
    :to_matrix_gate,
]

#=
for func in gate_functions
    @eval begin
        function $(func)(args...; kwargs...)
            qulacs.gate.$(func)(args...; kwargs...)
        end
        export $(func)
    end
end
=#

for func in gate_functions
    @eval begin
        @pyfunc gate $(func)
        export $(func)
    end
end

function __init__()
    #copy!(qulacs, pyimport("qulacs"))
    copy!(gate, pyimport("qulacs.gate"))
end

end # module Gate
