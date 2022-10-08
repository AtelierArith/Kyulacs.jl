struct LazyHelp
    o::Any
    keys::Tuple{Vararg{String}}
end

LazyHelp(o) = LazyHelp(o, ())
LazyHelp(o, k::AbstractString) = LazyHelp(o, (k,))
LazyHelp(o, k1::AbstractString, k2::AbstractString) = LazyHelp(o, (k1, k2))
LazyHelp(o, s::Symbol) = LazyHelp(o, (string(s),))

function gendocstr(h::LazyHelp)
    py"""
    import inspect
    def get_signature(f):
       	try:
       		return str(inspect.signature(f))
       	except ValueError:
       		return ""
    """
    o = h.o
    for k in h.keys
        o = o[k]
    end
    fname = hasproperty(o, "__name__") ? o.__name__ : ""
    sig = hasproperty(o, "__call__") ? py"get_signature"(o) : ""
    fdoc = hasproperty(o, "__doc__") ? o.__doc__ : ""

    if isnothing(fdoc)
        return """
        $(fname)$(sig)
        """
    else
        return """
        $(fdoc)
        """
    end
end

function Base.Docs.catdoc(hs::LazyHelp...)
    Base.Docs.Text() do io
        for h in hs
            show(io, MIME"text/plain"(), h)
        end
    end
end

function Base.show(io::IO, ::MIME"text/plain", h::LazyHelp)
    docstr = gendocstr(h)
    print(io, docstr)
end

macro pyfunc(_pymod, _func)
    pymod = _pymod |> esc
    func = _func |> esc
    quote
        @doc LazyHelp($(pymod), nameof($(func)))
        function $(func)(args...; kwargs...)
            getproperty($(pymod), nameof($(func)))(args...; kwargs...)
        end
    end
end

macro pyclass(_pymod, _class)
    pymod = _pymod |> esc
    class = _class |> esc
    quote
        @doc LazyHelp($(pymod), nameof($(class)))
        struct $(class)
            pyobj::$(PyObject)
            function $(class)(args...; kwargs...)
                new(getproperty($(pymod), nameof($class))(args...; kwargs...))
            end
        end

        PyCall.PyObject(t::$(class)) = t.pyobj

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

        #=
        Extract the docstring of a method in a given class
        julia> using Kyulacs
        julia> state = QuantumState(4)
        help?> state.set_computational_basis
        set_computational_basis(self: qulacs.QuantumState, index: int) -> None

        Set state to computational basis
        =#
        function Base.Docs.Binding(t::$(class), s::Symbol)
            Base.Docs.Binding(getfield(t, :pyobj), s)
        end
    end
end
