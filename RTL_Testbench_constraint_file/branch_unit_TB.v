`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////
////////////
///////////////////////////////////////////////////////////////////
module branch_unit_TB;

    // Inputs (driven by testbench)
    reg [31:0] rs1_in;
    reg [31:0] rs2_in;
    reg [4:0] opcode_6_to_2_in;
    reg [2:0] funct3_in;

    // Output (monitored from UUT)
    wire branch_taken_out;

    // Instantiate Unit Under Test (UUT)
    branch_unit uut (
        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .opcode_6_to_2_in(opcode_6_to_2_in),
        .funct3_in(funct3_in),
        .branch_taken_out(branch_taken_out)
    );

    initial begin
        // Initialize inputs
        rs1_in = 32'd0;
        rs2_in = 32'd0;
        opcode_6_to_2_in = 5'b00000;
        funct3_in = 3'b000;
        #10;

        // Case 1: BEQ (Equal registers -> branch taken)
        rs1_in = 32'd10;
        rs2_in = 32'd10;
        opcode_6_to_2_in = 5'b11000;
        funct3_in = 3'b000;
        #10;

        // Case 2: BNE (Unequal registers -> branch taken)
        rs2_in = 32'd20;
        funct3_in = 3'b001;
        #10;

        // Case 3: BLT Signed (rs1 = -5, rs2 = +5 -> branch taken)
        rs1_in = 32'hFFFF_FFFB; // -5
        rs2_in = 32'h0000_0005; // +5
        funct3_in = 3'b100;
        #10;

        // Case 4: JAL instruction (Unconditional Jump -> branch taken)
        opcode_6_to_2_in = 5'b11011;
        #10;

        // Case 5: Normal non-branch opcode (ALU instruction -> branch NOT taken)
        opcode_6_to_2_in = 5'b01100;
        #10;

        $finish;
    end

endmodule
