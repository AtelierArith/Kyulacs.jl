module ObservableFunctions

using PyCall

import ..@pyfunc

observable = PyNULL()

# --- qulacs.observable ---
const observable_classes = [
]

const observable_functions = [
    :create_observable_from_openfermion_file,
    :create_observable_from_openfermion_text,
    :create_split_observable,
]

for func in observable_functions
    @eval begin
        @pyfunc observable $(func)
        export $(func)
    end
end

function __init__()
    copy!(observable, pyimport("qulacs.observable"))
end

end # module ObservableFunctions
