# [Kyulacs.jl](https://github.com/AtelierArith/Kyulacs.jl)

[![Build Status](https://github.com/AtelierArith/Kyulacs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/AtelierArith/Kyulacs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://AtelierArith.github.io/Kyulacs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://AtelierArith.github.io/Kyulacs.jl/dev)

Unofficial Julia interface for [qulacs](https://github.com/qulacs/qulacs).

# Prerequisites

1. Install Python and `qulacs` via

```console
$ pip3 install qulacs
```

2. Install Julia. If you're Julian, you can skip this step.

```console
$ pip3 install jill # A cross-platform installer for Pythonista
$ jill install 1.7
```

After that you're supposed to add `${HOME}/.local/bin` to your `$PATH` environment variable. You'll see the result below:

```console
$ which julia
$ ~/.local/bin/julia
$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.7.1 (2021-12-22)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> println("Hello")
Hello

julia> exit()
```

3. Install PyCall

```conosle
$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.7.1 (2021-12-22)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> ENV["PYTHON"] = Sys.which("python3")
julia> using Pkg; Pkg.add("PyCall")
```

Having trouble with the error messages `ImportError: No module named site`? Did you install Python via `pyenv` or `asdf`? Please re-install or install another Python again with `CONFIGURE_OPTS="--enable-shared"` option. Namely run one of the following:

```
$ CONFIGURE_OPTS="--enable-shared" pyenv 3.8.11
$ CONFIGURE_OPTS="--enable-shared" asdf install python 3.8.11
```

4. Install Kyulacs.jl

```conosle
$ git clone https://github.com/AtelierArith/Kyulacs.jl.git
$ cd Kyulacs.jl
$ julia --project=@. -e 'using Pkg; Pkg.instantiate()'
$ julia --project=@. -e 'using Pkg; Pkg.test()'
```

# How to use

Let's assume you've written a Python code which is similar to [Python sample code](https://github.com/qulacs/qulacs#python-sample-code) given by qulacs.

```python
# examples/readme_example.py
from qulacs import Observable, QuantumCircuit, QuantumState
from qulacs.gate import Y, CNOT, merge

state = QuantumState(3)
seed = 0  # set random seed
state.set_Haar_random_state(seed)

circuit = QuantumCircuit(3)
circuit.add_X_gate(0)
merged_gate = merge(CNOT(0, 1), Y(1))
circuit.add_gate(merged_gate)
circuit.add_RX_gate(1, 0.5)
circuit.update_quantum_state(state)

observable = Observable(3)
observable.add_operator(2.0, "X 2 Y 1 Z 0")
observable.add_operator(-3.0, "Z 2")
value = observable.get_expectation_value(state)
# 0.2835596510287872
print(value)

```

You can try this code out of the box even if you are not familiar with quantum computing.

```conosle
$ cd /path/to/this/repository
$ julia --project=@. examples/readme_example.jl
0.2835596510287872
```

In Julia, we can achieve the same functionality with `Kyulacs` package.

```julia
# examples/readme_example.jl
using Kyulacs: Observable, QuantumCircuit, QuantumState
using Kyulacs.Gate: CNOT, Y, merge

state = QuantumState(3)
seed = 0  # set random seed
state.set_Haar_random_state(seed)

circuit = QuantumCircuit(3)
circuit.add_X_gate(0)
merged_gate = merge(CNOT(0, 1), Y(1))
circuit.add_gate(merged_gate)
circuit.add_RX_gate(1, 0.5)
circuit.update_quantum_state(state)

observable = Observable(3)
observable.add_operator(2.0, "X 2 Y 1 Z 0")
observable.add_operator(-3.0, "Z 2")
value = observable.get_expectation_value(state)
# 0.2835596510287872
println(value)

```

Have a try!!!

```console
$ cd /path/to/this/repository
$ julia --project=@. examples/readme_example.jl
0.2835596510287872
```

These are pretty much the same thing. In fact, `diff` tells these are almost same.

```console
$ diff readme_example.py readme_example.jl
1,3c1,3
< # readme_example.py
< from qulacs import Observable, QuantumCircuit, QuantumState
< from qulacs.gate import Y, CNOT, merge
---
> # readme_example.jl
> using Kyulacs: Observable, QuantumCircuit, QuantumState
> using Kyulacs.Gate: CNOT, Y, merge
21c21
< print(value)
---
> println(value)
```

# Code Design

When you want migrate your code from Python to Julia, the following table may help you:

Python  | Julia
------------- | -------------
`from qulacs.circuit import something` | `using Kyulacs.Gate: something`
`from qulacs.gate import something` | `using Kyulacs.Gate: something`
`from qulacs.observable import something` | `using Kyulacs.ObservableFunctions: something`
`from qulacs.quantum_operator import something` | `using Kyulacs.QuantumOperator: something`
`from qulacs.state import something` | `using Kyulacs.State: something`

If you feel `using Kyulacs.ObservableFunctions` is too exaggerated. Please send your feedback/idea to [our issue tracker](https://github.com/AtelierArith/Kyulacs.jl/issues).

# GPU API

`using Kyulacs.GPU` will export `StateVectorGpu` and `QuantumStateGpu` that wraps `qulacs.StateVectorGpu` and `qulacs.QuantumStateGpu` respectively.


# Appendix

## Docker

```console
$ git clone https://github.com/AtelierArith/Kyulacs.jl.git
$ cd Kyulacs.jl
$ make && make test
$ make build-gpu && make test-gpu # for gpu version
```

## Blog post

- [Zenn: (Japanese blog post)](https://zenn.dev/terasakisatoshi/articles/983a7401524251)

# Sponsorship

If you want to see more of our work, consider sponsoring us via [Github sponsors](https://github.com/sponsors/terasakisatoshi).

