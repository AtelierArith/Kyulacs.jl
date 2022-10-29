import Kyulacs

using Kyulacs: GeneralQuantumOperator, Observable, QuantumCircuit, QuantumState,
    ParametricQuantumCircuit
using Kyulacs: pyrange, print_configurations
using Kyulacs.Gate: CNOT, Y, merge
using Kyulacs.QulacsVis: circuit_drawer

using PyCall
using IOCapture

using Test

@testset "pyrange" begin
    N = 10
    numbers = []
    for i in pyrange(N)
        push!(numbers, i)
    end
    expected = 0:(N-1) |> collect
    @test numbers == expected
end

# display package config
Kyulacs.print_configurations()

@pyinclude("readme_example.py")

@testset "readme_example" begin
    state = QuantumState(3)
    seed = 0 # set random seed
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
    @test value == py"readme_example"()
end

# https://github.com/qulacs/qulacs/blob/main/python/test/test_qulacs.py
@testset "TestQuantumState" begin
    @testset "test_state_dim" begin
        # setup
        n = 4
        dim = 2^n
        state = QuantumState(n)

        # runtest
        v = state.get_vector()
        @test length(v) == dim
    end

    @testset "test_zero_state" begin
        # setup
        n = 4
        dim = 2^n
        state = QuantumState(n)

        # runtest
        state.set_zero_state()
        vector = state.get_vector()
        expected = let
            _expected = zeros(dim)
            _expected[begin] = 1.0
            _expected
        end
        @test vector ≈ expected
    end

    @testset "test_comp_basis" begin
        # setup
        n = 4
        dim = 2^n
        state = QuantumState(n)

        pos = Int(0b0101)
        state.set_computational_basis(pos)
        vector = state.get_vector()

        expected = let
            _expected = zeros(dim)
            _expected[begin+pos] = 1.0
            _expected
        end
        @test vector ≈ expected
    end
end

@testset "TestQuantumCircuit" begin
    # setup
    n = 4
    dim = 2^4
    state = QuantumState(n)
    circuit = QuantumCircuit(n)

    @testset "test_make_bell_state" begin
        circuit.add_H_gate(0)
        circuit.add_CNOT_gate(0, 1)
        state.set_zero_state()
        circuit.update_quantum_state(state)
        vector = state.get_vector()
        expected = let
            _expected = zeros(dim)
            _expected[begin+0] = sqrt(0.5)
            _expected[begin+3] = sqrt(0.5)
            _expected
        end
        @test vector ≈ expected
    end
end

@testset "TestObservable" begin
    @testset "test_get_matrix" begin
        @testset "Observable" begin
            n_qubits = 3
            obs = Observable(n_qubits)
            obs.add_operator(0.5, "Z 2")
            obs.add_operator(1.0, "X 0 X 1 X 2")
            obs.add_operator(1.0, "Y 1")
            obs.get_matrix()
            expected = ComplexF64[
                0.5+0.0im 0.0+0.0im 0.0-1.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im
                0.0+0.0im 0.5+0.0im 0.0+0.0im 0.0-1.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im
                0.0+1.0im 0.0+0.0im 0.5+0.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im
                0.0+0.0im 0.0+1.0im 0.0+0.0im 0.5+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im
                0.0+0.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im -0.5+0.0im 0.0+0.0im 0.0-1.0im 0.0+0.0im
                0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im -0.5+0.0im 0.0+0.0im 0.0-1.0im
                0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+1.0im 0.0+0.0im -0.5+0.0im 0.0+0.0im
                1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+1.0im 0.0+0.0im -0.5+0.0im
            ]
            @test obs.get_matrix().todense() ≈ expected
        end
        @testset "GeneralQuantumOperator" begin
            n_qubits = 3
            obs = GeneralQuantumOperator(n_qubits)
            obs.add_operator(0.5im, "Z 2")
            obs.add_operator(1.0, "X 0 X 1 X 2")
            obs.add_operator(1.0, "Y 1")
            expected = ComplexF64[
                0.0+0.5im 0.0+0.0im 0.0-1.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im
                0.0+0.0im 0.0+0.5im 0.0+0.0im 0.0-1.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im
                0.0+1.0im 0.0+0.0im 0.0+0.5im 0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im
                0.0+0.0im 0.0+1.0im 0.0+0.0im 0.0+0.5im 1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im
                0.0+0.0im 0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0-0.5im 0.0+0.0im 0.0-1.0im 0.0+0.0im
                0.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0-0.5im 0.0+0.0im 0.0-1.0im
                0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+1.0im 0.0+0.0im 0.0-0.5im 0.0+0.0im
                1.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+0.0im 0.0+1.0im 0.0+0.0im 0.0-0.5im
            ]
            @test obs.get_matrix().todense() ≈ expected
        end
    end
end

@testset "QulacsVis" begin
    nqubits = 2
    circuit = ParametricQuantumCircuit(nqubits)
    circuit.add_parametric_RY_gate(0, 0.0)
    circuit.add_parametric_RY_gate(1, 0.0)

    circuit.add_parametric_RY_gate(0, 0.0)
    circuit.add_CNOT_gate(0, 1)
    circuit.add_parametric_RY_gate(0, 0.0)

    c = IOCapture.capture() do
        circuit_drawer(circuit)
    end

    @show c
    
    out = c.output

    expected = """
       ___     ___             ___   
      |pRY|   |pRY|           |pRY|  
    --|   |---|   |-----●-----|   |--
      |___|   |___|     |     |___|  
       ___             _|_           
      |pRY|           |CX |          
    --|   |-----------|   |----------
      |___|           |___|          
    """
    @test out == expected
end
