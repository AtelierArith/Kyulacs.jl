module ObservableFunctions

using PyCall

import ..@pyfunc

#qulacs = PyNULL()
observable = PyNULL()

const observable_functions = [
    :create_observable_from_openfermion_file,
    :create_observable_from_openfermion_text,
    :create_split_observable,
]

#=
for func in observable_functions
    @eval begin
        function $(func)(args...; kwargs...)
            qulacs.observable.$(func)(args...; kwargs...)
        end
        export $(func)
    end
end
=#

for func in observable_functions
    @eval begin
        @pyfunc observable $(func)
        export $(func)
    end
end

function __init__()
    #copy!(qulacs, pyimport("qulacs"))
    copy!(observable, pyimport("qulacs.observable"))
end

end # module ObservableFunctions
