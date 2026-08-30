`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Immediate Address Adder Unit
//////////////////////////////////////////////////////////////////////////////////

module imm_adder (
    input  [31:0] pc_in,          // IN:  From reg_block_1 (Program Counter)
    input  [31:0] rs1_in,         // IN:  From Register File (Source register 1 value)
    input         iadder_src_in,  // IN:  From Decoder (0: pc_in for Branch/JAL, 1: rs1_in for JALR/Load/Store)
    input  [31:0] imm_in,         // IN:  From Immediate Generator
    output [31:0] iadder_imm_out  // OUT: Calculated target address
);

    // MUX select: 0 -> pc_in, 1 -> rs1_in
    wire [31:0] base_address = (iadder_src_in) ? rs1_in : pc_in;

    // Address calculation
    assign iadder_imm_out = base_address + imm_in;

endmodule