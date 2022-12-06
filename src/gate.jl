module Gate

using PyCall
import ..@pyfunc
import ..@pyclass

gate = PyNULL()

# --- qulacs_core.gate ---
const gate_classes = [
    :Adaptive,
    :AmplitudeDampingNoise,
    :BitFlipNoise,
    :CNOT,
    :CP,
    :CPTP,
    :CZ,
    :DenseMatrix,
    :DephasingNoise,
    :DepolarizingNoise,
    :DiagonalMatrix,
    :FREDKIN,
    :H,
    :Identity,
    :IndependentXZNoise,
    :Instrument,
    :Measurement,
    :NoisyEvolution,
    :NoisyEvolution_fast,
    :P0,
    :P1,
    :ParametricPauliRotation,
    :ParametricRX,
    :ParametricRY,
    :ParametricRZ,
    :Pauli,
    :PauliRotation,
    :Probabilistic,
    :ProbabilisticInstrument,
    :RX,
    :RY,
    :RZ,
    :RandomUnitary,
    :ReversibleBoolean,
    :RotInvX,
    :RotInvY,
    :RotInvZ,
    :RotX,
    :RotY,
    :RotZ,
    :S,
    :SWAP,
    :Sdag,
    :SparseMatrix,
    :StateReflection,
    :T,
    :TOFFOLI,
    :Tdag,
    :TwoQubitDepolarizingNoise,
    :U1,
    :U2,
    :U3,
    :X,
    :Y,
    :Z,
]

const gate_functions = [
    :add,
    :merge,
    :sqrtX,
    :sqrtXdag,
    :sqrtY,
    :sqrtYdag,
    :to_matrix_gate,
]

for class in gate_classes
    @eval begin
        @pyclass gate $(class)
        export $(class)
    end
end

for func in gate_functions
    @eval begin
        @pyfunc gate $(func)
        export $(func)
    end
end

function __init__()
    copy!(gate, pyimport("qulacs.gate"))
end

end # module Gate
