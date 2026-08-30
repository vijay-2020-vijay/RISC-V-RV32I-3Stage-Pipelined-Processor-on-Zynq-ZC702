# RISC-V-RV32I-3Stage-Pipelined-Processor-on-Zynq-ZC702

A 3-stage pipelined RV32I RISC-V processor implemented in Verilog RTL and deployed on the Xilinx Zynq-7000 (ZC702) FPGA. Features a Harvard memory architecture, operand forwarding, CSR-interrupt-aware stall handling, and per-instruction result verification. Bitstream generated and `.xsa` exported for Vitis — PS-PL integration and Renode co-simulation are next steps.

---

##  Download Full Project

All source files, testbench, assembly program, results, and reference material are packaged together for anyone who wants to run this on their own system.

**[ Download Full Project (Google Drive)](https://drive.google.com/file/d/1jkIeF5M_d4cmj3Kb4_aSepdQTVc1jhhW/view?usp=sharing)**

---

##  Overview

Designed and verified a 3-stage pipelined RV32I RISC-V processor — full RTL, deployed on Zynq-7000 (ZC702).

Built from scratch in Verilog over several months — from ISA-level architecture down to FPGA bitstream — this project covers every stage of RTL development: submodule design, integration, functional verification, timing closure, and hardware export for SoC-level development.

---

## 🏗️ Architecture

The processor pipeline is organized into 3 stages:

| Stage | Function | Key Modules |
|-------|----------|-------------|
| **Stage 1** | Fetch / Decode | I-cache, Program Counter, Branch Unit, Immediate Generator, Store Unit, Instruction Decoder |
| **Stage 2** | Execute | D-cache, ALU, Load Unit, CSR Unit, Write-Back Mux Select logic |
| **Stage 3** | Write-Back | Integer Register File, Fwrite Module (Dual-Port BRAM result logging) |

---

## ⚙️ Key Engineering Challenges & Solutions

- **Critical Path & Timing** — With only 3 pipeline stages, combinational depth per stage is high. The design closes timing at **50 MHz** on the ZC702, with post-implementation reports showing **zero failing endpoints** (WNS: 0.458 ns) across 4500+ endpoints.
- **Structural Hazards** — Resolved using separate Instruction and Data memories (Harvard architecture) instead of a unified memory.
- **Memory Latency Trade-off** — LUT RAM offers 0-clock read latency but is capacity-limited, so I-cache and D-cache content is mapped into Block RAM (1-clock read latency) to balance speed and size.
- **Data Hazards** — Resolved using operand forwarding to avoid unnecessary stalls.
- **Control Hazards** — A dedicated stall-insertion mechanism handles worst-case scenarios, including CSR-triggered interrupts arriving mid-pipeline.
- **Result Verification** — Every executed instruction's result status is captured and permanently stored via a Dual-Port BRAM-based Fwrite module, enabling instruction-by-instruction correctness verification.

---

##  Validation

The design was verified by running a **400+ line hand-crafted RV32I assembly program** and cross-checking the register/result status after every instruction — a rigorous way to confirm functional correctness at the RTL level, beyond waveform inspection alone.

---

##  Repository Structure

| Folder / File | Description |
|---|---|
| `Accurate_Result_status/` | Instruction-by-instruction register and result verification logs |
| `Assembley_program_code/` | 400+ line RV32I assembly test program used for validation |
| `I_and_D_cache_memorey_Hex_file/` | Instruction and Data cache memory initialization (HEX) files |
| `RTL_Testbench_constraint_file/` | RTL source files, testbench, and FPGA constraint (.xdc) files |
| `Experimental_Screenshort_images/` | Simulation, synthesis, and implementation screenshots |
| `RISC_V_Important_referance_note_books/` | RISC-V ISA manual and design reference material used during development |
| `RISC_V_Core_wrapper.xsa` | Exported hardware platform (post-bitstream) for Vivado/Vitis SoC-level development |
| `README.md` | Project documentation |

---

## Architecture & Implementation Visuals

![Block Diagram of full complete architechture](Experimental_Screenshort_images/Screenshot%20%284416%29.png)
![state_wise_rTL_block](Experimental_Screenshort_images/ChatGPT%20Image%20Aug%2031%2C%202026%2C%2001_14_35%20AM.png)
![project_summery](Experimental_Screenshort_images/Screenshot%20%284454%29.png)
![simmuletion](Experimental_Screenshort_images/Screenshot%20%284471%29.png)
![Routing & placement](Experimental_Screenshort_images/Screenshot%20%284460%29.png)
![Assembly Program (400+ lines)](Experimental_Screenshort_images/Screenshot%20%284421%29.png)
![Instruction-wise Result Status Verification](Experimental_Screenshort_images/Screenshot%20%284423%29.png)




##  What's Included

- Complete submodule-by-submodule RTL design
- Full block-level integration (single top module)
- RISC-V ISA manual references used during design
- Full RTL (.v) synthesized, implemented, and exported as a hardware platform (`.xsa`) after bitstream generation — ready for Vivado/Vitis SoC-level software development
- Assembly test program with instruction-level result verification

---

##  What's Next

- Integrating the core with the Zynq Processing System (ARM Cortex-A9) for PS-PL communication, moving toward a complete SoC flow
- Building a Verilator-based co-simulation model for Renode emulation, enabling PS + RISC-V (PL) integration for full-system, software-driven verification

---

## 👤 Author

Rabisankar Maity VLSI M.Tech Graduate, IIT Guwahati — AIR 318 in GATE EC Feel free to connect, raise issues, or fork this project for your own experiments
