# readme_example.py
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
