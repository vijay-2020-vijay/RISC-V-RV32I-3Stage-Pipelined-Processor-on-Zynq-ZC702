`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Store Unit Module
// Positional Byte Lane Alignment, Write Masks & AHB Data Interface
//////////////////////////////////////////////////////////////////////////////////

module store_unit (
    // Inputs from Pipeline / Core Logic
    input  [2:0]  funct3_in1,                     // Instruction Decoder (funct3[2:0] field)
    input  [31:0] imm_iaddr_in,                   // Target Store Address from ALU/Adder
    input  [31:0] rs2_in,                         // Source Data Register 2
    input         mem_wr_req_in,                  // Memory Write Request Enable
    input         ms_riscv32_mp_instr_hready_in,  // AHB Bus Ready Signal

    // Outputs to Memory / Bus Interface
    output reg [31:0] ms_riscv32_mp_dmdata_out,     // Positioned Data Output to Bus
    output reg [31:0] ms_riscv32_mp_dmaddr_out,     // 32-bit Word-aligned Target Address
    output reg [3:0]  ms_riscv32_mp_dmwr_mask_out,  // Byte Write Enable Mask Signals
    output reg        ms_riscv32_mp_dmwr_req_out,   // Data Memory Write Request Output
    output reg [1:0]  ms_riscv32_mp_data_htrans_out,// AHB HTRANS status (2'b00 IDLE, 2'b10 NONSEQ)
    output            unused_st                     // Sink for unused bit funct3_in1[2]
);

    // Extract relevant store size bits: 2'b00 (SB), 2'b01 (SH), 2'b10 (SW)
    wire [1:0] funct3_in = funct3_in1[1:0];

    always @(*) begin
        // Default Bus Values (IDLE state & zero masks)
        ms_riscv32_mp_data_htrans_out = 2'b00;
        ms_riscv32_mp_dmdata_out       = 32'h0000_0000;
        ms_riscv32_mp_dmwr_mask_out    = 4'b0000;

        if (ms_riscv32_mp_instr_hready_in == 1'b1) begin
            case (funct3_in)
                // ---------------------------------------------------------
                // 2'b00: Store Byte (SB)
                // ---------------------------------------------------------
                2'b00: begin
                    ms_riscv32_mp_data_htrans_out = 2'b10; // NONSEQ transfer
                    case (imm_iaddr_in[1:0])
                        2'b00: begin
                            ms_riscv32_mp_dmdata_out    = {24'h000000, rs2_in[7:0]};
                            ms_riscv32_mp_dmwr_mask_out = {3'b000, mem_wr_req_in};
                        end
                        2'b01: begin
                            ms_riscv32_mp_dmdata_out    = {16'h0000, rs2_in[7:0], 8'h00};
                            ms_riscv32_mp_dmwr_mask_out = {2'b00, mem_wr_req_in, 1'b0};
                        end
                        2'b10: begin
                            ms_riscv32_mp_dmdata_out    = {8'h00, rs2_in[7:0], 16'h0000};
                            ms_riscv32_mp_dmwr_mask_out = {1'b0, mem_wr_req_in, 2'b00};
                        end
                        2'b11: begin
                            ms_riscv32_mp_dmdata_out    = {rs2_in[7:0], 24'h000000};
                            ms_riscv32_mp_dmwr_mask_out = {mem_wr_req_in, 3'b000};
                        end
                    endcase
                end

                // ---------------------------------------------------------
                // 2'b01: Store Half-Word (SH)
                // ---------------------------------------------------------
                2'b01: begin
                    ms_riscv32_mp_data_htrans_out = 2'b10; // NONSEQ transfer
                    if (imm_iaddr_in[1] == 1'b0) begin
                        ms_riscv32_mp_dmdata_out    = {16'h0000, rs2_in[15:0]};
                        ms_riscv32_mp_dmwr_mask_out = {2'b00, {2{mem_wr_req_in}}};
                    end else begin
                        ms_riscv32_mp_dmdata_out    = {rs2_in[15:0], 16'h0000};
                        ms_riscv32_mp_dmwr_mask_out = {{2{mem_wr_req_in}}, 2'b00};
                    end
                end

                // ---------------------------------------------------------
                // 2'b10: Store Word (SW)
                // ---------------------------------------------------------
                2'b10: begin
                    ms_riscv32_mp_data_htrans_out = 2'b10; // NONSEQ transfer
                    ms_riscv32_mp_dmdata_out       = rs2_in;
                    ms_riscv32_mp_dmwr_mask_out    = {4{mem_wr_req_in}};
                end

                default: begin
                    ms_riscv32_mp_data_htrans_out = 2'b00;
                    ms_riscv32_mp_dmdata_out       = 32'h0000_0000;
                    ms_riscv32_mp_dmwr_mask_out    = 4'b0000;
                end
            endcase
        end

        // Align target address to 32-bit word boundary (clear lower 2 bits)
        ms_riscv32_mp_dmaddr_out   = {imm_iaddr_in[31:2], 2'b00};

        // Pass write request straight through
        ms_riscv32_mp_dmwr_req_out = mem_wr_req_in;
    end

    // Sink unused top bit of funct3_in1 to clear Vivado Synth 8-7129 warnings
    assign unused_st = funct3_in1[2];

endmodule