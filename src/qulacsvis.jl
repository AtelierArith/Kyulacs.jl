module QulacsVis

using PyCall
using Reexport

import ..@pyfunc
import ..@pyclass

qulacsvis = PyNULL()

module Visualization

using PyCall

import ..@pyfunc
import ..@pyclass

visualization = PyNULL()

const visualization_classes = [
    :CircuitParser,
    :LatexSourceGenerator,
    :MPLCircuitlDrawer,
    :TextCircuitDrawer,
]

const visualization_functions = [
    :circuit_drawer,
]

for class in visualization_classes
    @eval begin
        @pyclass visualization $(class)
        export $(class)
    end
end

for func in visualization_functions
    @eval begin
        @pyfunc visualization $(func)
        export $(func)
    end
end

function __init__()
    copy!(visualization, pyimport("qulacsvis.visualization"))
end

end # module Visualization

@reexport using .Visualization

function __init__()
    copy!(qulacsvis, pyimport("qulacsvis"))
end

end # module QulacsVis
