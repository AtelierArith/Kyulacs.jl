module QuantumOperator

using PyCall

import ..@pyfunc

quantum_operator = PyNULL()

# --- qulacs_core.quantum_operator ---
const quantum_operator_classes = [
]

const quantum_operator_functions = [
    :create_quantum_operator_from_openfermion_file,
    :create_quantum_operator_from_openfermion_text,
    :create_split_quantum_operator,
]

for func in quantum_operator_functions
    @eval begin
        @pyfunc quantum_operator $(func)
        export $(func)
    end
end

function __init__()
    copy!(quantum_operator, pyimport("qulacs.quantum_operator"))
end

end # module QuantumOperator
