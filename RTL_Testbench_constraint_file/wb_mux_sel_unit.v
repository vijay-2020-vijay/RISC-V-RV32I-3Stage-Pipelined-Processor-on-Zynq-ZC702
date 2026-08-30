`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
//////////////////////////////////////////////////////////////////////////////////

module wb_mux_sel_unit (
    // Control Inputs
    input        alu_src_reg_in,       // From: Register block 2 (0: Immediate data, 1: RS2 register data)
    input [2:0]  wb_mux_sel_reg_in,    // From: Register block 2 (Selects write-back data source)

    // Data Inputs
    input [31:0] alu_result_in,        // From: ALU (Result produced by ALU)
    input [31:0] lu_output_in,         // From: Load Unit (Output of Load unit)
    input [31:0] imm_reg_in,           // From: Register block 2 (Immediate data for LUI)
    input [31:0] imm_iadder_reg2_in,    // From: Register block 2 (Sum of Immediate data and RS1/PC for AUIPC/JALR)
    input [31:0] csr_data_in,          // From: CSR file (Data Out port of CSR module)
    input [31:0] pc_plus_4_reg_in,     // From: Register block 2 (PC + 4 for JAL/JALR)
    input [31:0] rs2_reg_in,           // From: Register block 2 (RS2 register output)

    // Module Outputs
    output reg [31:0] wb_mux_out,            // To: Integer Register File (Data to be written)
    output     [31:0] alu_2nd_src_mux_out    // To: ALU (2nd source operand op_2_in)
);

    // ALU 2nd Source Multiplexer
    assign alu_2nd_src_mux_out = (alu_src_reg_in == 1'b1) ? rs2_reg_in : imm_reg_in;

    // Write-Back Multiplexer Selection
    always @* begin
        case (wb_mux_sel_reg_in)
            3'b000: wb_mux_out = alu_result_in;     // WB_ALU: ALU output (R-type, I-type)
            3'b001: wb_mux_out = lu_output_in;      // WB_LU: Load Unit output
            3'b010: wb_mux_out = imm_reg_in;        // WB_IMM: Immediate value (LUI)
            3'b011: wb_mux_out = imm_iadder_reg2_in; // WB_IADDER_OUT: Immediate Adder output (AUIPC)
            3'b100: wb_mux_out = csr_data_in;       // WB_CSR: CSR Read Data
            3'b101: wb_mux_out = pc_plus_4_reg_in;  // WB_PC_PLUS: PC + 4 (JAL, JALR)
            default: wb_mux_out = alu_result_in;    // Default: ALU Result
        endcase
    end

endmodule