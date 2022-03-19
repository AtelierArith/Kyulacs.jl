module State

using PyCall
import ..@pyfunc

#qulacs = PyNULL()

state = PyNULL()
const state_functions = [
    :inner_product,
    :tensor_product,
    :permutate_qubit,
    :drop_qubit,
    :partial_trace,
]

#=
for func in state_functions
    @eval begin
        function $(func)(args...; kwargs...)
            qulacs.state.$(func)(args...; kwargs...)
        end
        export $(func)
    end
end
=#

for func in state_functions
    @eval begin
        @pyfunc state $(func)
        export $(func)
    end
end

function __init__()
    #copy!(qulacs, pyimport("qulacs"))
    copy!(state, pyimport("qulacs.state"))
end

end # module State
