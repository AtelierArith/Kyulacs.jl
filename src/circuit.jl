module Circuit

using PyCall

import ..@pyfunc
import ..@pyclass

#const qulacs = PyNULL()
const circuit = PyNULL()

const circuit_class = [
    :QuantumCircuitOptimizer,
]

#=
for class in circuit_class
    @eval begin
        struct $class
            pyobj::PyObject
            $(class)(args...) = new(qulacs.circuit.$(class)(args...))
        end

        PyObject(t::$(class)) = t.pyobj

        function Base.propertynames(t::$(class))
            propertynames(getfield(t, :pyobj))
        end

        function Base.getproperty(t::$(class), s::Symbol)
            if s ∈ fieldnames($(class))
                return getfield(t, s)
            else
                return getproperty(getfield(t, :pyobj), s)
            end
        end

        export $(class)
    end
end
=#

for class in circuit_class
    @eval begin
        @pyclass circuit $(class)
        export $(class)
    end
end
function __init__()
    #copy!(qulacs, pyimport("qulacs"))
    copy!(circuit, pyimport("qulacs.circuit"))
end

end # module
