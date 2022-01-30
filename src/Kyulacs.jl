module Kyulacs

using PyCall

export qulacs

const qulacs=PyNULL()

for class in [:Observable, :QuantumState, :QuantumCircuit]
    @eval begin
        struct $class
            pyobj::PyObject
            $(class)(args...)=new(qulacs.$class(args...))
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
    end
end

# Write your package code here.
function __init__()
    copy!(qulacs, pyimport("qulacs"))
end

end
