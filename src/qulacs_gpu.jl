module GPU

using PyCall
import ..LazyHelp

const qulacs = PyNULL()

const qulacs_classes = [
    :QuantumStateGpu,
    :StateVectorGpu,
]

for class in qulacs_classes
    @eval begin
        @doc LazyHelp(qulacs, nameof($(class))) struct $class
            pyobj::PyObject
            function $(class)(args...)
                try
                    class4gpu = qulacs.$(class)
                    new(class4gpu(args...))
                catch e
                    if isa(e, KeyError)
                        msg = """
                        Make sure you've installed GPU-version of `qulacs`.
                        Try with the following command:
                        ```console
                        \$ pip3 install qulacs-gpu
                        ```
                        """
                        throw(error(msg))
                    else
                        rethrow(e)
                    end
                end
            end
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

function __init__()
    copy!(qulacs, pyimport("qulacs"))
end

end
