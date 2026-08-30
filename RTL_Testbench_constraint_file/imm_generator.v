`timescale 1ns / 1ps    
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Immediate Generator Unit
//////////////////////////////////////////////////////////////////////////////////

module imm_generator (
    input  [31:7] instr_in,  // IN: Instruction bits [31:7]
    input  [2:0]  imm_type,  // IN: Control signal for immediate format select
    output reg [31:0] imm_out// OUT: Sign/Zero-extended 32-bit immediate output
);

    // Immediate decoding formats using full-width concatenations
    wire [31:0] i_type   = { {20{instr_in[31]}}, instr_in[31:20] };
    wire [31:0] s_type   = { {20{instr_in[31]}}, instr_in[31:25], instr_in[11:7] };
    wire [31:0] b_type   = { {20{instr_in[31]}}, instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0 };
    wire [31:0] u_type   = { instr_in[31:12], 12'h000 };
    wire [31:0] j_type   = { {12{instr_in[31]}}, instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0 };
    wire [31:0] csr_type = { 27'b0, instr_in[19:15] };

    // Immediate selection multiplexer
    always @(*) begin
        case (imm_type)
            3'b000, 
            3'b001, 
            3'b111:  imm_out = i_type;   // I-Type formats
            3'b010:  imm_out = s_type;   // S-Type format
            3'b011:  imm_out = b_type;   // B-Type format
            3'b100:  imm_out = u_type;   // U-Type format
            3'b101:  imm_out = j_type;   // J-Type format
            3'b110:  imm_out = csr_type; // CSR-Type format
            default: imm_out = 32'h0000_0000;
        endcase
    end

endmodule