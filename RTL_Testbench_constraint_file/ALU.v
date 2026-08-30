`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V 32-Bit ALU Implementation
//////////////////////////////////////////////////////////////////////////////////

module ALU (
    // Inputs
    input  [31:0] op_1_in,     // From: Register block 2 (first operand)
    input  [31:0] op_2_in,     // From: Write-back MUX (second operand)
    input  [3:0]  opcode_in,   // From: Register block 2 (driven by funct7 and funct3)

    // Output
    output reg [31:0] result_out // To: Write-back MUX (result of requested operation)
);

    // Parallel intermediate operation results
    wire [31:0] op_add;
    wire [31:0] op_sub;
    reg  [31:0] op_slt;
    wire [31:0] op_sltu;
    wire [31:0] op_and;
    wire [31:0] op_or;
    wire [31:0] op_xor;
    wire [31:0] op_sll;
    wire [31:0] op_srl;
    wire [31:0] op_sra;

    // 1. Addition & Subtraction
    assign op_add = op_1_in + op_2_in;
    assign op_sub = op_1_in - op_2_in;

    // 2. Signed Comparison (SLT) - Original Logic
    always @* begin
        if (op_1_in[31] == op_2_in[31]) begin
            if (op_1_in[31] == 1'b0) begin
                if (op_1_in[30:0] < op_2_in[30:0])
                    op_slt = 32'h0000_0001;
                else
                    op_slt = 32'h0000_0000;
            end else begin
                if (op_1_in[30:0] > op_2_in[30:0])
                    op_slt = 32'h0000_0001;
                else
                    op_slt = 32'h0000_0000;
            end
        end else if (op_1_in[31] == 1'b1) begin
            op_slt = 32'h0000_0001;
        end else begin
            op_slt = 32'h0000_0000;
        end
    end

    // 3. Unsigned Comparison (SLTU)
    assign op_sltu = (op_1_in < op_2_in) ? 32'h0000_0001 : 32'h0000_0000;

    // 4. Bitwise Logical Operations
    assign op_and = op_1_in & op_2_in;
    assign op_or  = op_1_in | op_2_in;
    assign op_xor = op_1_in ^ op_2_in;

    // 5. Shift Operations
    assign op_sll = op_1_in << op_2_in[4:0];
    assign op_srl = op_1_in >> op_2_in[4:0];
    assign op_sra = $signed(op_1_in) >>> op_2_in[4:0];

    // 6. Multiplexer Output Selection
    always @* begin
        case (opcode_in)
            4'b0000: result_out = op_add;  // ALU_ADD
            4'b1000: result_out = op_sub;  // ALU_SUB
            4'b0010: result_out = op_slt;  // ALU_SLT
            4'b0011: result_out = op_sltu; // ALU_SLTU
            4'b0111: result_out = op_and;  // ALU_AND
            4'b0110: result_out = op_or;   // ALU_OR
            4'b0100: result_out = op_xor;  // ALU_XOR
            4'b0001: result_out = op_sll;  // ALU_SLL
            4'b0101: result_out = op_srl;  // ALU_SRL
            4'b1101: result_out = op_sra;  // ALU_SRA
            default: result_out = op_add;  // Default fallback
        endcase
    end

endmodule