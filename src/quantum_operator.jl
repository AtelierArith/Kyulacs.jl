module QuantumOperator

using PyCall

qulacs = PyNULL()

const observable_functions = [
    :create_quantum_operator_from_openfermion_file,
    :create_quantum_operator_from_openfermion_text,
    :create_split_quantum_operator,
]

for func in observable_functions
    @eval begin
        function $(func)(args...; kwargs...)
            qulacs.quantum_operator.$(func)(args...; kwargs...)
        end
        export $(func)
    end
end

function __init__()
    copy!(qulacs, pyimport("qulacs"))
end

end # module QuantumOperator
