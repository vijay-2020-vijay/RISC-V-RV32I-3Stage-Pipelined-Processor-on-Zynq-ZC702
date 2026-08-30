`timescale 1ns / 1ps

module ALU_TB;

    // Testbench Inputs
    reg [31:0] op_1_in;
    reg [31:0] op_2_in;
    reg [3:0]  opcode_in;

    // Testbench Output
    wire [31:0] result_out;

    // Instantiate Unit Under Test (UUT)
    ALU uut (
        .op_1_in   (op_1_in),
        .op_2_in   (op_2_in),
        .opcode_in (opcode_in),
        .result_out(result_out)
    );

    initial begin
        // Initialize Inputs
        op_1_in   = 32'h0000_0000;
        op_2_in   = 32'h0000_0000;
        opcode_in = 4'b0000;

        #10;

        // 1. ALU_ADD (4'b0000)
        op_1_in = 32'h0000_0005; op_2_in = 32'h0000_000A; opcode_in = 4'b0000; #10;

        // 2. ALU_SUB (4'b1000)
        op_1_in = 32'h0000_0020; op_2_in = 32'h0000_0005; opcode_in = 4'b1000; #10;

        // 3. ALU_SLT (4'b0010) - Signed Comparison (-5 < 10 -> True)
        op_1_in = 32'hFFFF_FFFB; op_2_in = 32'h0000_000A; opcode_in = 4'b0010; #10;

        // 4. ALU_SLTU (4'b0011) - Unsigned Comparison (0xFFFFFFFB > 0x0000000A -> False)
        op_1_in = 32'hFFFF_FFFB; op_2_in = 32'h0000_000A; opcode_in = 4'b0011; #10;

        // 5. ALU_AND (4'b0111)
        op_1_in = 32'hF0F0_FFFF; op_2_in = 32'h0F0F_1234; opcode_in = 4'b0111; #10;

        // 6. ALU_OR (4'b0110)
        op_1_in = 32'hF000_0000; op_2_in = 32'h0000_FFFF; opcode_in = 4'b0110; #10;

        // 7. ALU_XOR (4'b0100)
        op_1_in = 32'hAAAA_5555; op_2_in = 32'hFFFF_FFFF; opcode_in = 4'b0100; #10;

        // 8. ALU_SLL (4'b0001) - Shift Left Logical
        op_1_in = 32'h0000_0001; op_2_in = 32'h0000_0004; opcode_in = 4'b0001; #10;

        // 9. ALU_SRL (4'b0101) - Shift Right Logical
        op_1_in = 32'h8000_0000; op_2_in = 32'h0000_0004; opcode_in = 4'b0101; #10;

        // 10. ALU_SRA (4'b1101) - Shift Right Arithmetic (Sign Extension preserved)
        op_1_in = 32'h8000_0000; op_2_in = 32'h0000_0004; opcode_in = 4'b1101; #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0tn | OPCODE=%b | OP1=%h | OP2=%h | RESULT=%h",
                 $time, opcode_in, op_1_in, op_2_in, result_out);
    end

endmodule
