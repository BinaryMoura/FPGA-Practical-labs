# What is an FPGA?

## Definition

**FPGA** (Field-Programmable Gate Array) is a semiconductor device that can be reprogrammed to implement various digital circuits and functions. Unlike ASICs (Application-Specific Integrated Circuits), which are fixed-function devices manufactured for a specific purpose, FPGAs offer unparalleled flexibility and adaptability. Designers can modify the functionality of the device even after it has been manufactured and deployed in the field.

This reprogrammability makes FPGAs an attractive option for:
- **Rapid prototyping** - Quickly test and validate design concepts
- **Proof-of-concept development** - Demonstrate feasibility before committing to ASIC production
- **Applications with evolving requirements** - Adapt to changing standards or protocols

## Architecture

At the heart of an FPGA lies a matrix of **programmable logic blocks** and **programmable interconnects**. This architecture enables the implementation of digital circuits ranging from simple logic gates to complex digital signal processing systems.

![FPGA Architecture](images/fpga-architecture.svg)

*Figure 1: FPGA architecture showing CLBs (Configurable Logic Blocks), I/O blocks, and programmable interconnects*

An FPGA consists of three fundamental building blocks:

1. **Configurable Logic Blocks (CLBs)** - The basic computational units that implement digital logic
2. **Interconnect Architecture** - Programmable routing that connects the blocks
3. **Input/Output Blocks** - Interfaces for connecting to external devices

### Configurable Logic Block (CLB) Structure

Each CLB contains the essential components for building digital circuits:

![CLB Structure](images/fpga-clb-structure.svg)

*Figure 2: Internal structure of a Configurable Logic Block*

The CLB consists of three essential elements:

- **LUT (Look-Up Table)** - Implements combinational logic functions by storing truth tables
- **Flip-Flop** - Stores state for sequential logic operations  
- **Multiplexer** - Selects between combinational (LUT) or registered (Flip-Flop) output

### Gate-Level Implementation

![CLB Gate-Level Detail](images/clb-gate-level.svg)

*Figure 3: Detailed gate-level view of CLB components*

The diagram above shows how each CLB component works at the logic gate and mathematical level:

**1. LUT (Look-Up Table)**
- Mathematically: A LUT with *n* inputs implements any Boolean function of *n* variables
- A 2-input LUT is a 4×1 memory: `Output = Memory[2×A + B]`
- Gate equivalent: Can implement AND, OR, XOR, or any truth table
- Example: AND gate stored at addresses: mem[0]=0, mem[1]=0, mem[2]=0, mem[3]=1

**2. D Flip-Flop**
- Mathematical model: `Q(t+1) = D(t)` when clock rises (▲)
- Stores 1 bit of state synchronously
- Characteristic equation: Next state equals input at the clock edge
- Output only changes on the rising edge of CLK

**3. 2:1 Multiplexer**
- Boolean equation: `Out = (¬Select · LUT_Out) + (Select · FF_Out)`
- Selects between:
  - S=0: Combinational path (direct LUT output)
  - S=1: Registered path (flip-flop output)
- Controlled by a configuration bit programmed into the FPGA

**4. Complete CLB**
- Unified equation: `CLB_Out = Config ? FF(LUT(Inputs), CLK) : LUT(Inputs)`
- Enables both combinational and sequential logic in one unit

### Interconnects

The interconnects provide the routing infrastructure that links logic blocks together. This network of wires and programmable switches enables:

- Flexible connections between any logic blocks
- Implementation of larger and more complex circuits
- Signal routing with minimal delay and power consumption

## FPGA vs ASIC Comparison

| Aspect | FPGA | ASIC |
|--------|------|------|
| Functionality | Reprogrammable | Fixed after fabrication |
| Development Time | Weeks to months | Months to years |
| Upfront Cost | Low (no NRE) | Very High (expensive masks) |
| Unit Cost (High Volume) | Higher | Lower |
| Flexibility | Can be updated in the field | Cannot be changed |
| Performance | Good | Optimized for specific function |
| Power Consumption | Moderate | Optimized and lower |

## Key Advantages

FPGAs provide several compelling benefits that make them suitable for a wide range of applications:

- **Design Flexibility** - Modify functionality without fabricating new silicon
- **Faster Time-to-Market** - Skip the lengthy and expensive ASIC manufacturing process
- **Lower Risk** - Fix bugs and add features after deployment
- **Parallel Processing** - Execute multiple operations simultaneously for high throughput
- **Deterministic Latency** - Predictable timing behavior for real-time systems

## Common Applications

FPGAs are widely deployed across industries where performance, flexibility, and rapid development are critical:

- **Telecommunications** - Base stations, network processing, protocol handling
- **Automotive** - ADAS, sensor fusion, ECU prototyping
- **Aerospace and Defense** - Radar systems, secure communications, avionics
- **Data Centers** - Acceleration of AI/ML workloads, SmartNICs, video transcoding
- **Industrial Automation** - Real-time control systems, robotics, motor drives
- **Test and Measurement** - High-speed data acquisition, signal processing

---
*Next: [02-basic-verilog.md](02-basic-verilog.md)*
