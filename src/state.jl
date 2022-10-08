module State

using PyCall
import ..@pyfunc

state = PyNULL()
const state_classes = [
]

const state_functions = [
    :drop_qubit,
    :inner_product,
    :partial_trace,
    :permutate_qubit,
    :tensor_product,
]

for func in state_functions
    @eval begin
        @pyfunc state $(func)
        export $(func)
    end
end

function __init__()
    copy!(state, pyimport("qulacs.state"))
end

end # module State
