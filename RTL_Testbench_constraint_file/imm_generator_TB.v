`timescale 1ns / 1ps

module imm_generator_TB;

    // Inputs to UUT (driven by testbench)
    reg [31:7] instr_in;
    reg [2:0] imm_type;

    // Output from UUT (monitored)
    wire [31:0] imm_out;

    // Instantiate the Immediate Generator module
    imm_generator uut (
        .instr_in(instr_in),
        .imm_type(imm_type),
        .imm_out(imm_out)
    );

    initial begin
        // Initialize inputs
        instr_in = 25'b0;
        imm_type = 3'b000;
        #10;

        // Test 1: I-Type Immediate (imm_type = 3'b001)
        // Set instr_in[31:20] = 12'hFFF (-1 sign-extended)
        instr_in = 25'h1FF_FFFF; 
        imm_type = 3'b001;
        #10;

        // Test 2: S-Type Immediate (imm_type = 3'b010)
        // Combine imm[11:5] (instr_in[31:25]) and imm[4:0] (instr_in[11:7])
        instr_in = 25'h1F0_00F0;
        imm_type = 3'b010;
        #10;

        // Test 3: B-Type Immediate (imm_type = 3'b011)
        instr_in = 25'h100_0080;
        imm_type = 3'b011;
        #10;

        // Test 4: U-Type Immediate (imm_type = 3'b100)
        // Upper 20 bits shifted (instr_in[31:12])
        instr_in = 25'h123_4500;
        imm_type = 3'b100;
        #10;

        // Test 5: J-Type Immediate (imm_type = 3'b101)
        instr_in = 25'h1AB_CD00;
        imm_type = 3'b101;
        #10;

        // Test 6: CSR-Type Immediate (imm_type = 3'b110)
        // Zero-extended 5-bit zimm from instr_in[19:15]
        instr_in = 25'h007_C000;
        imm_type = 3'b110;
        #10;

        $finish;
    end

endmodule
