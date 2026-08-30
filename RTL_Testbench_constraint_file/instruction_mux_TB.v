
`timescale 1ns / 1ps

module instruction_mux_TB;

    // Inputs (driven by testbench)
    reg flush_in;
    reg [31:0] ms_riscv32_mp_instr_in;

    // Outputs (monitored from UUT)
    wire [6:0] opcode_out;
    wire [2:0] funct3_out;
    wire [6:0] funct7_out;
    wire [4:0] rs1addr_out;
    wire [4:0] rs2addr_out;
    wire [4:0] rdaddr_out;
    wire [11:0] csr_addr_out;
    wire [31:7] instr_out;

    // Instantiate Unit Under Test (UUT)
    instruction_mux uut (
        .flush_in(flush_in),
        .ms_riscv32_mp_instr_in(ms_riscv32_mp_instr_in),
        .opcode_out(opcode_out),
        .funct3_out(funct3_out),
        .funct7_out(funct7_out),
        .rs1addr_out(rs1addr_out),
        .rs2addr_out(rs2addr_out),
        .rdaddr_out(rdaddr_out),
        .csr_addr_out(csr_addr_out),
        .instr_out(instr_out)
    );

    initial begin
        // Case 1: Initialize inputs
        flush_in = 0;
        ms_riscv32_mp_instr_in = 32'h0000_0000;
        #10;

        // Case 2: Normal Instruction Execution (ADD x3, x1, x2 -> 32'h002081b3)
        flush_in = 0;
        ms_riscv32_mp_instr_in = 32'h002081b3;
        #10;

        // Case 3: Trigger Flush (Outputs must reflect NOP 32'h00000013)
        flush_in = 1;
        #10;

        // Case 4: Release Flush back to normal operation (ADDI x3, x0, 5 -> 32'h00500193)
        flush_in = 0;
        ms_riscv32_mp_instr_in = 32'h00500193;
        #10;

        $finish;
    end

endmodule
