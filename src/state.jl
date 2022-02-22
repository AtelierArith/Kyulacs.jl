module State

using PyCall

qulacs = PyNULL()

const state_functions = [
    :inner_product,
    :tensor_product,
    :permutate_qubit,
    :drop_qubit,
    :partial_trace,
]

for func in state_functions
    @eval begin
        function $(func)(args...; kwargs...)
            qulacs.state.$(func)(args...; kwargs...)
        end
        export $(func)
    end
end

function __init__()
    copy!(qulacs, pyimport("qulacs"))
end

end # module State
