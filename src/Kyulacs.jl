module Kyulacs

using PyCall
using Reexport

include("pywraputils.jl")

# qulacs
include("qulacs.jl")
@reexport using .Qulacs

include("qulacs_gpu.jl")

# qulacs.circuit
include("circuit.jl")

# qulacs.gate
include("gate.jl")

# qulacs.observable
include("observable.jl")

# qulacs.quantum_operator
include("quantum_operator.jl")

# qulacs.state
include("state.jl")

# qulacsvis.visualization
include("qulacsvis.jl")

function print_configurations()
    metadata = pyimport("importlib.metadata")
    println("-- PyCall.jl settings --")
    @show PyCall.pyversion
    @show Base.Filesystem.contractuser(PyCall.libpython)
    @show Base.Filesystem.contractuser(PyCall.pyprogramname)
    @show PyCall.conda
    println("-- Python dependencies --")
    qulacs_version = metadata.distribution("qulacs").version
    @show qulacs_version
    scipy_version = metadata.distribution("scipy").version
    @show scipy_version
    nothing
end

end # module Kyulacs
