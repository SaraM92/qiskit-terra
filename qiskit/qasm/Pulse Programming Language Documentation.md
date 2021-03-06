# 0001- RFC - Pulse Programming Language

| **Status**        | **Proposed** |
|:------------------|:---------------------------------------------|
| **RFC #**         | 1                                       |
| **Authors**       | Thomas Alexander (talexander@ibm.com), Anastasia Marchenkova (a.marchenkova@gmail.com), Sara Metwalli (sara@keio.jp), Shin Nishio (parton@sfc.wide.ad.jp), Maika Takita (mtakita@us.ibm.com), Ryo Wakizaka (suibaka@gmail.com)    |
| **Deprecates**    | Qiskit Terra, OpenQASM                |
| **Submitted**     | 2019-11-20                                   |
| **Updated**       | 2019-11-21                                 |


## Summary
Pulse programming in Qiskit is currently implemented as in-memory IR. Design a language and implement a parser/grammar using a standard Python package (see what QASM is using for example) for pulse programming that may be interpreted to form a pulse schedule.

## Motivation
- Improve the process of measuring and creating quantum gates, and hence quantum circuits.
- Enable the users to express quantum circuits completely and solely using pulses
- Improve the hardware set implementation of the gates.
- Increase the number of parallel operations that can performed on the quantum device.

## User Benefit
- Qiskit and QASM user who want a pulse-level control of the quantum device.
- Users will be able to express their circuits directly using pulses (or as gates represented in pulses).
- Creates a new set of new object types (pulse, frame change, acquire, and delay) that allows the expression of any circuit using pulses.
- More control over the creation and measurement of quantum circuits in OpenQASM and Qiskit Terra.


## Design Proposal
The pulse module in Qiskit allows scheduling of pulse instructions absolutely in time. A pulse schedule is a basic block of pulse instructions. We implement a low-level language integrated in OpenQASM that maps simply to the in-memory pulse IR and generates an interpreter that outputs pulse schedules.


### Introducing New Concepts
We introduce an approach to express any given quantum circuit using pulse to enable pulse-level control of the backend quantum device.  
This is done via introducing the following types to QASM:
- Channel: This represents the actual channel which the pulse run through in the specified backend device.
- Pulse: An object representing a pulse (contains a list of real and complex samples that define the pulse shape).
- Play: Plays a pulse onto a given channel.
- Acquire: Acquires data from a given channel. 
- Measure: measure the value of a pulse after it passes the digitizer to obtain its value (0 or 1).
- Barrier: A method of aligning different channels.
- Delay: A more low level barrier to wait that waits for a certain duration before the next instruction.


### Quantum Teleportation Using The Proposed Approach
Alice wants to send quantum information to Bob. Specifically, suppose she wants to send the state  |ψ\UTF{27E9}=α|0\UTF{27E9}+β|1\UTF{27E9}  to Bob. This entails passing on information about  α  and  β  to Bob.

There exists a theorem in quantum mechanics which states that you cannot simply make an exact copy of an unknown quantum state. This is known as the no-cloning theorem. As a result of this we can see that Alice can't simply generate a copy of  |ψ\UTF{27E9}  and give the copy to Bob. Copying a state is only possible with a classical computation.

However, by taking advantage of two classical bits and entanglement, Alice can transfer the state  |ψ\UTF{27E9}  to Bob. We call this teleportation as at the end Bob will have  |ψ\UTF{27E9}  and Alice won't anymore.

We implemented teleportation using our approach as follows:
```json

# quantum teleportation example after
//quantum teleportation example after

OPENQASM 3.0;
include "qelib1.inc";
qreg q[3];
creg c[3];

// declare channels
dch d0;
dch d1;
uch uch0;
mch m0;
mch m1;

framechange(-0.1) d0;
play x90p_q0 d0;
framechange(-0.3) d0;
play x90m_q0 d0;
framechange(-0.2) d0;


h q[1];
cx q[1],q[2];

barrier q;

framechange(pi/2) d0;
play ym_d0 d0;
play x90p_d1 d1;
ch_barrier d0, d1, uch0;
play cR90p_d1 d1;
ch_barrier d0, d1, uch0;
play xp_d0 d0;
ch_barrier d0, d1, uch0;
play cR90m_d1 d1;

h q[0];

play m_m0 m0;
acquire a0 c[0];

play m_m1 m1;
acquire a0 c[1];

if(c0==1) z q[2];
if(c1==1) play xp_d2 d2;

play m_m2 m2;
acquire a0 c[2];

```


## Detailed Design
### QASM Syntax of The Proposed Concepts

```
# THESE GATES ARE BASED ON THE alt_almaden BACKEND
# pulses are defined for specific devices, or user can add their own

gate u3(theta, phi, lambda) a {
	framechange(-lambda) d0;
	play X90p_q0 d0;
	framechange(-theta) d0;
	play X90m_q0 d0;
	framechange(-phi) d0;
}

gate u3(theta, phi, lambda) a {
	framechange(-lambda) d1;
	play X90p_q1 d1;
	framechange(-theta) d1;
	play X90m_q1 d1;
	framechange(-phi) d1;
}

gate u2(phi, lambda) a {
	framechange(-lambda) d0;
	play Y90p_q0 d0;
	framechange(-phi) d0;
}

gate u1(lambda) a {
	framechange(-lambda) d0;
}

gate x a {
	play Xp_d0 d0;
}

gate id a {
	play QId_d0 d0;
}

gate measure a {
	play M_m0 m0;
	acquire m0 creg[0];
	acquire m1 creg[1];
	acquire m2 creg[2]; # continue on for all qubits ...
}

gate cx a, b {
	framechange(pi/2) d0;
	play Ym_d0 d0;
	play X90p_d1 d1;
	ch_barrier d0, d1, u0;
	play CR90p_d1 d1;
	ch_barrier d0, d1, u0;
	play Xp_d0 d0;
	ch_barrier d0, d1, u0;
	play CR90m_d1 d
}

```

### Grammar

We add this additional grammar to OpenQASM. 

```json
<statement> := …
              | <pop>
              | …
              | ch_barrier <anylist>;
<chdecl> := uch <id> | ach <id> | dch <id> | mch <id>
<pulsedecl> := pulse <id> <explist>
<goplist> := …
             | <pop>
             | <goplist> <pop>
<pop> :=   framechange(<explist>) <argument>; (* t0, phase / ch *)
         | play <argument>;  
         | pv(<explist>) <argument>;  (* t0,val(complex value) / ch *)
         | acquire(<explist>) <argument> <argument> <argument>;
           (* t0, duration / qubits, memory_slot, register_slot in this order *)
         | delay(<explist>) <argument>; (* duration / channel *)
         | ch_barrier <argument>; (* channels *)         
         | <id> <anylist>;
         | <id>() <anylist>;
         | <id>(<explist>) <anylist>;

```


## Alternative Approaches
One alternative approach to the problem is to implement the pulse-control independently of the QASM and then compile them together to achieve the same results. One reason to do this is that the pulse control can then stand independently from QASM and we have new, cleaner code from the learnings from the gate model. However, it would make combining pulse and gate definitions more difficult in the converter and scheduler and may touch more code. 

## Questions
1. Can we merge pulse and gate schedules together in the in memory representation?
2. Is the best to extend to current lexer and parser or start from scratch for speed and efficiency of the new mixed gate and pulse paradigm?
3. What standard should we set for pulse samples?

## Future Extensions
- Add support for automatically getting pulse samples names from specific backends
- Metadata for specific backends 
Currently, the implementation of gates is backend-specific. To eliminate this, we can implement backend variables on a separate file and use that file as a guide to gate creation.
- Extend delay to get timing information from pulse 
