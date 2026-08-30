# RISC-V-RV32I-3Stage-Pipelined-Processor-on-Zynq-ZC702
3-stage pipelined RV32I RISC-V processor implemented in Verilog RTL and deployed on the Xilinx Zynq-7000 (ZC702) FPGA. Features Harvard memory architecture, operand forwarding, CSR-interrupt-aware stall handling, and per-instruction result verification. Bitstream generated, .xsa exported for Vitis. PS-PL integration &amp; Renode co-simulation .

Designed & Verified a 3-Stage Pipelined RV32I RISC-V Processor — Full RTL, Deployed on Zynq-7000 (ZC702)
Over the past few months, I built a complete 3-stage pipelined RISC-V (RV32I) processor from scratch in Verilog — from ISA-level architecture down to FPGA bitstream — and integrated it with the ARM Cortex-A9 (PS) on a Xilinx Zynq-7000 ZC702 platform.

Architecture The pipeline is split across 3 stages:

Stage 1 (Fetch/Decode): I-cache, Program Counter, Branch Unit, Immediate Generator, Store Unit, and full Instruction Decoder
Stage 2 (Execute): D-cache, ALU, Load Unit, CSR Unit, and Write-Back Mux Select logic
Stage 3 (Write-Back): Integer Register File + a custom Fwrite Module backed by Dual-Port BRAM that permanently logs the result status of every instruction

Key Engineering Challenges & Solutions

Critical Path & Timing: With only 3 pipeline stages, combinational depth per stage is high — the design closes timing at 50 MHz on the ZC702. Post-implementation reports show zero failing endpoints (WNS 0.458 ns) across 4500+ endpoints.
Structural Hazards: Solved by using separate Instruction and Data memories (Harvard architecture) instead of a single unified memory.
Memory Latency Trade-off: LUT RAM gives 0-clock read latency but is capacity-limited, so I-cache and D-cache content is mapped into Block RAM (1-clock read latency) to balance speed vs. size.
Data Hazards: Resolved using operand forwarding to avoid unnecessary stalls.
Control Hazards: A dedicated stall-insertion mechanism handles worst-case scenarios — including CSR-triggered interrupts arriving mid-pipeline.
Result Verification: Every executed instruction's result status is captured and permanently stored via a Dual-Port BRAM-based Fwrite module, enabling instruction-by-instruction correctness verification against a 400-line RISC-V assembly test program.

Validation The design was verified by running a 400+ line hand-crafted RV32I assembly program and cross-checking the register/result status after every instruction — a rigorous way to confirm functional correctness at the RTL level, beyond just waveform inspection.

What I'm sharing in the repo

Complete submodule-by-submodule RTL design process
Full block-level integration (single top module)
RISC-V ISA manual references used during design
Full RTL (.v) synthesized, implemented, and exported as a hardware platform (.xsa) after bitstream generation — ready to be used in Vivado/Vitis for SoC-level software development
Assembly test program + instruction-level result verification

🔮 What's next

Integrating the core with the Zynq Processing System (ARM Cortex-A9) for PS-PL communication, moving toward a complete SoC flow
Building a Verilator-based co-simulation model for Renode emulation, enabling PS + RISC-V (PL) integration for full-system, software-driven verification
