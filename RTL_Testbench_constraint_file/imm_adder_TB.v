`timescale 1ns / 1ps

module imm_adder_TB;

    // Inputs (driven by testbench)
    reg [31:0] pc_in;
    reg [31:0] rs1_in;
    reg iadder_src_in;
    reg [31:0] imm_in;

    // Output (monitored from UUT)
    wire [31:0] iadder_out;

    // Instantiate Unit Under Test (UUT)
    imm_adder uut (
        .pc_in(pc_in),
        .rs1_in(rs1_in),
        .iadder_src_in(iadder_src_in),
        .imm_in(imm_in),
        .iadder_out(iadder_out)
    );

    initial begin
        // Initialize inputs
        pc_in  = 32'h0000_0200;
        rs1_in = 32'h0000_1000;
        imm_in = 32'h0000_0004;
        
        // Case 1: Select PC source (iadder_src_in = 0) -> Expected iadder_out = 32'h0000_0204 (Branch/JAL)
        iadder_src_in = 0;
        #10;

        // Case 2: Select RS1 source (iadder_src_in = 1) -> Expected iadder_out = 32'h0000_1004 (JALR/Load/Store)
        iadder_src_in = 1;
        #10;

        // Case 3: Test with negative offset (-4 in two's complement) using PC source
        imm_in = 32'hFFFF_FFFC; 
        iadder_src_in = 0;
        #10;

        $finish;
    end

endmodule
