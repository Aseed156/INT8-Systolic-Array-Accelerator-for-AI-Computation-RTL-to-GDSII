# INT8 Systolic Array Accelerator (RTL → GDSII)

This project implements a fully custom **INT8 Systolic Array-based Matrix Multiplication Accelerator**, designed and verified at the RTL level using SystemVerilog and taken through a complete **RTL-to-GDSII physical design flow** using open-source EDA tools.

The goal of this project is to demonstrate end-to-end digital ASIC design: from architecture definition, RTL design, functional verification, synthesis, place & route, timing closure, and final layout inspection.

---

## Project Overview

The accelerator is a **parameterized INT8 systolic array** designed for high-throughput matrix multiplication, commonly used in:
- AI/ML inference acceleration
- DSP workloads
- Edge computing hardware
- CNN/Transformer MAC operations

The design follows a **dataflow-oriented systolic architecture**, where each Processing Element (PE) performs MAC (Multiply-Accumulate) operations in a pipelined manner.

---

## Architecture

### Key Features:
- INT8 signed arithmetic (8-bit fixed-point)
- 2D Systolic Array of Processing Elements (PEs)
- Local data forwarding (no global memory bottleneck inside array)
- Fully pipelined MAC units
- Configurable array dimensions
- Input stationary / weight stationary mapping support (depending on configuration)

### Processing Element (PE):
Each PE performs:
ACC<=ACC+(A*B)  
and forwards data to neighboring PEs.

---

## Tools & Technologies Used

### RTL Design & Simulation
- **SystemVerilog** – RTL implementation of systolic array
- **ModelSim / QuestaSim (or alternative)** – Functional simulation

### Verification
- **ModelSim / QuestaSim** – Testbench-based verification
- **Self-checking testbenches**
- Golden reference model (C  model used for validation)

### High-Level Modeling
- **MATLAB / Python (NumPy)** – Floating-point reference model for correctness comparison

### Logic Synthesis
- **Yosys**
  - RTL synthesis to gate-level netlist
  - Technology mapping
  - Optimization (area + timing)

### FPGA Prototyping (optional validation)
- **Intel Quartus Prime**
  - FPGA synthesis and resource estimation
  - Timing analysis on FPGA target

### Formal / Simulation Acceleration
- **Verilator**
  - Fast cycle-accurate simulation
  - Used for large matrix test vectors

### Physical Design (RTL → GDSII)
- **OpenROAD**
  - Floorplanning
  - Placement
  - Clock Tree Synthesis (CTS)
  - Routing
  - Timing closure (STA)

### Layout Visualization
- **KLayout**
  - Final GDSII inspection
  - Layout debugging and layer analysis

---

## RTL-to-GDSII Flow

The complete ASIC design flow followed in this project:

### 1. RTL Design (SystemVerilog)
- Design of systolic array architecture
- Modular PE design
- Input/output buffering logic
- Top-level integration

### 2. Functional Verification
- Testbench-driven simulation
- Randomized matrix generation
- Output comparison with golden model
- Corner-case validation

### 3. High-Speed Simulation (Verilator)
- Large matrix multiplications
- Cycle-accurate performance testing
- Debugging pipeline stalls and data hazards

### 4. Synthesis (Yosys)
- RTL → Gate-level netlist
- Technology-independent optimization
- Area and timing reports generation

### 5. FPGA Mapping (Quartus - Optional)
- FPGA synthesis for validation
- Resource utilization estimation
- Timing feasibility checks

### 6. Physical Design (OpenROAD)
- Floorplanning of systolic array
- Placement optimization for PE locality
- Clock Tree Synthesis (CTS)
- Routing and congestion resolution
- Timing closure (STA-driven iterations)

### 7. GDSII Generation
- Final layout export in GDS format

### 8. Layout Verification (KLayout)
- Visual inspection of:
  - Standard cells
  - Routing congestion
  - Array structure
  - Clock distribution

---

## Performance Highlights

- Fully pipelined MAC operations per PE
- High throughput matrix multiplication engine
- Reduced memory bottleneck via local data propagation
- Scalable architecture (NxN systolic grid)
- Optimized routing for nearest-neighbor communication

---
