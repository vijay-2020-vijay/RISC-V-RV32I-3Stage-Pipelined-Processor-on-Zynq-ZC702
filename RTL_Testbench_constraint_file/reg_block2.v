`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2024 00:30:33  
// Design Name: 
// Module Name: reg_block2   
// Project Name: msrv32
// Target Devices: 
// Tool Versions: 
// Description: Pipeline Register Stage 2 (ID/EX to EX/WB buffer)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 
module reg_block2 (
    // System Clock & Reset
    input ms_riscv32_mp_clk_in,        // From: Global Clock Controller
    input ms_riscv32_mp_rst_in,        // From: Global Reset Controller

    // Data & Address Inputs
    input [4:0]  rd_addr_in,           // From: Instruction Decoder (rd field, bits [11:7])
    input [11:0] csr_addr_in,          // From: Instruction Decoder / Instruction Mux (bits [31:20])
    input [31:0] rs1_in,               // From: Integer Register File (rs1 read data)
    input [31:0] rs2_in,               // From: Integer Register File (rs2 read data)
    input [31:0] pc_in,                // From: Reg Block 1 / Instruction Fetch Stage
    input [31:0] pc_plus_4_in,         // From: PC Adder Unit (PC + 4)
    input        branch_taken_in,      // From: Branch/Jump Resolution Unit
    input [31:0] imm_iadder_in,            // From: Immediate/Instruction Address Adder (iadder)
    input [31:0] imm_in,               // From: Immediate Generator (msrv32_imm_generator)

    // Control Signal Inputs
    input [3:0]  alu_opcode_in,        // From: Instruction Decoder (msrv32_decoder)
    input [1:0]  load_size_in,         // From: Instruction Decoder (msrv32_decoder)
    input        load_unsigned_in,     // From: Instruction Decoder (msrv32_decoder)
    input        alu_src_in,           // From: Instruction Decoder (msrv32_decoder)
    input        csr_wr_en_in,         // From: Instruction Decoder (msrv32_decoder)
    input        rf_wr_en_in,          // From: Instruction Decoder (msrv32_decoder)
    input [2:0]  wb_mux_sel_in,        // From: Instruction Decoder (msrv32_decoder)
    input [2:0]  csr_op_in,            // From: Instruction Decoder (msrv32_decoder)

    // Registered Data & Address Outputs
    output reg [4:0]  rd_addr_reg_out,    // To: Integer Register File (write address port) / Writeback Mux
    output reg [11:0] csr_addr_reg_out,   // To: CSR Register File (csr_addr port)
    output reg [31:0] rs1_reg_out,        // To: ALU (operand 1) / CSR File (csr_wdata)
    output reg [31:0] rs2_reg_out,        // To: ALU (operand 2) / Store Unit (store data)
    output reg [31:0] pc_reg_out,         // To: Machine Control / PC Mux (EPC handling)
    output reg [31:0] pc_plus_4_reg_out,  // To: Writeback Mux (return address for JAL/JALR)
    output reg [31:0] imm_iadder_reg2_out, // To: Load-Store Unit (Data Memory Address) / PC Mux / Decoder (misalignment check)
    output reg [31:0] imm_reg_out,        // To: ALU Mux (immediate operand) / Writeback Mux

    // Registered Control Signal Outputs
    output reg [3:0]  alu_opcode_reg_out,    // To: Arithmetic Logic Unit (msrv32_alu)
    output reg [1:0]  load_size_reg_out,     // To: Load Unit (msrv32_load_unit)
    output reg        load_unsigned_reg_out, // To: Load Unit (msrv32_load_unit)
    output reg        alu_src_reg_out,       // To: ALU 2nd Operand Selection Mux
    output reg        csr_wr_en_reg_out,     // To: Write Enable Generator (msrv32_wr_en_generator)
    output reg        rf_wr_en_reg_out,      // To: Write Enable Generator (msrv32_wr_en_generator)
    output reg [2:0]  wb_mux_sel_reg_out,    // To: Writeback Selection Mux (msrv32_wb_mux_sel)
    output reg [2:0]  csr_op_reg_out        // To: CSR Register File (csr_op port)
   
);

    always @(posedge ms_riscv32_mp_clk_in or posedge ms_riscv32_mp_rst_in) begin
        if (ms_riscv32_mp_rst_in == 1'b1) begin
            rd_addr_reg_out       <= 5'b00000;
            csr_addr_reg_out      <= 12'h000;
            rs1_reg_out           <= 32'h0000_0000;
            rs2_reg_out           <= 32'h0000_0000;
            pc_reg_out            <= 32'h0000_0000;
            pc_plus_4_reg_out     <= 32'h0000_0000;
            imm_iadder_reg2_out    <= 32'h0000_0000;
            alu_opcode_reg_out    <= 4'b0000;
            load_size_reg_out     <= 2'b00;
            load_unsigned_reg_out <= 1'b0;
            alu_src_reg_out       <= 1'b0;
            csr_wr_en_reg_out     <= 1'b0;
            rf_wr_en_reg_out      <= 1'b0;
            wb_mux_sel_reg_out    <= 3'b000;
            csr_op_reg_out        <= 3'b000;
            imm_reg_out           <= 32'h0000_0000;
  
        end
        else begin
            rd_addr_reg_out       <= rd_addr_in;
            csr_addr_reg_out      <= csr_addr_in;
            rs1_reg_out           <= rs1_in;
            rs2_reg_out           <= rs2_in;
            pc_reg_out            <= pc_in;
            pc_plus_4_reg_out     <= pc_plus_4_in;
            imm_iadder_reg2_out[31:1] <= imm_iadder_in[31:1];
            alu_opcode_reg_out    <= alu_opcode_in;
            alu_src_reg_out       <= alu_src_in;
            csr_wr_en_reg_out     <= csr_wr_en_in;
            rf_wr_en_reg_out      <= rf_wr_en_in;
            wb_mux_sel_reg_out    <= wb_mux_sel_in;
            csr_op_reg_out        <= csr_op_in;
            imm_reg_out           <= imm_in;
 
            load_size_reg_out     <= load_size_in;
            load_unsigned_reg_out <= load_unsigned_in;
 
 

            // Target alignment logic for branch jumps (forces LSB bit 0 to 0 on branch taken)
            if (branch_taken_in == 1'b1)
                imm_iadder_reg2_out[0] <= 1'b0;
            else
                imm_iadder_reg2_out[0] <= imm_iadder_in[0];
        end
    end

endmodule