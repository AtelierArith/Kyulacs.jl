module QuantumOperator

using PyCall

import ..@pyfunc

#qulacs = PyNULL()
quantum_operator = PyNULL()

const quantum_operator_functions = [
    :create_quantum_operator_from_openfermion_file,
    :create_quantum_operator_from_openfermion_text,
    :create_split_quantum_operator,
]

#=
for func in quantum_operator_functions
    @eval begin
        function $(func)(args...; kwargs...)
            qulacs.quantum_operator.$(func)(args...; kwargs...)
        end
        export $(func)
    end
end
=#

for func in quantum_operator_functions
    @eval begin
        @pyfunc quantum_operator $(func)
        export $(func)
    end
end

function __init__()
    #copy!(qulacs, pyimport("qulacs"))
    copy!(quantum_operator, pyimport("qulacs.quantum_operator"))
end

end # module QuantumOperator
