module Circuit

using PyCall

import ..@pyfunc
import ..@pyclass

const circuit = PyNULL()

const circuit_class = [
    :QuantumCircuitOptimizer,
]

for class in circuit_class
    @eval begin
        @pyclass circuit $(class)
        export $(class)
    end
end

function __init__()
    copy!(circuit, pyimport("qulacs.circuit"))
end

end # module
