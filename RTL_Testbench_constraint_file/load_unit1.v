
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Load Unit (Combinational Byte/Half-word alignment & Sign/Zero extension)
//////////////////////////////////////////////////////////////////////////////////

module load_unit1 (
    // Data & Instruction Inputs
   // input clk1,
    input  [31:0] ms_riscv32_mp_dmdata_in,   // Raw data from Memory (32-bit word)
    input  [31:0] imm_iadder_in,              // Memory address offset
    input         load_unsigned_in,          // 0: Sign Extension, 1: Zero Extension
    input  [1:0]  load_size_in,              // 00: Byte, 01: Half-word, 10/11: Word

    // Module Outputs
    output reg [31:0] lu_output_out,         // Processed load data output
    output            unused_sink_lo         // Sink for unused address bits [31:2]
);

    wire [1:0] iadder_out_1_to_0_in = imm_iadder_in[1:0];

    always @(*) begin
        case (load_size_in)
            // ---------------------------------------------------------
            // 2'b00: Byte Load (LB / LBU)
            // ---------------------------------------------------------
            2'b00: begin
                case (iadder_out_1_to_0_in)
                    2'b00: begin
                        lu_output_out[7:0] = ms_riscv32_mp_dmdata_in[7:0];
                        if (load_unsigned_in == 1'b0)
                            lu_output_out[31:8] = {24{ms_riscv32_mp_dmdata_in[7]}};
                        else
                            lu_output_out[31:8] = 24'h000000;
                    end

                    2'b01: begin
                        lu_output_out[7:0] = ms_riscv32_mp_dmdata_in[15:8];
                        if (load_unsigned_in == 1'b0)
                            lu_output_out[31:8] = {24{ms_riscv32_mp_dmdata_in[15]}};
                        else
                            lu_output_out[31:8] = 24'h000000;
                    end

                    2'b10: begin
                        lu_output_out[7:0] = ms_riscv32_mp_dmdata_in[23:16];
                        if (load_unsigned_in == 1'b0)
                            lu_output_out[31:8] = {24{ms_riscv32_mp_dmdata_in[23]}};
                        else
                            lu_output_out[31:8] = 24'h000000;
                    end

                    2'b11: begin
                        lu_output_out[7:0] = ms_riscv32_mp_dmdata_in[31:24];
                        if (load_unsigned_in == 1'b0)
                            lu_output_out[31:8] = {24{ms_riscv32_mp_dmdata_in[31]}};
                        else
                            lu_output_out[31:8] = 24'h000000;
                    end
                endcase
            end

            // ---------------------------------------------------------
            // 2'b01: Half-Word Load (LH / LHU)
            // ---------------------------------------------------------
            2'b01: begin
                if (iadder_out_1_to_0_in[1] == 1'b0) begin
                    lu_output_out[15:0] = ms_riscv32_mp_dmdata_in[15:0];
                    if (load_unsigned_in == 1'b0)
                        lu_output_out[31:16] = {16{ms_riscv32_mp_dmdata_in[15]}};
                    else
                        lu_output_out[31:16] = 16'h0000;
                end else begin
                    lu_output_out[15:0] = ms_riscv32_mp_dmdata_in[31:16];
                    if (load_unsigned_in == 1'b0)
                        lu_output_out[31:16] = {16{ms_riscv32_mp_dmdata_in[31]}};
                    else
                        lu_output_out[31:16] = 16'h0000;
                end
            end

            // ---------------------------------------------------------
            // 2'b10 / 2'b11: Word Load (LW)
            // ---------------------------------------------------------
            2'b10, 2'b11: begin
                lu_output_out = ms_riscv32_mp_dmdata_in;
            end
        endcase
    end

    // Sink unused upper 30 address bits to eliminate Vivado Synth 8-7129 warnings
    wire [29:0] unused_addr = imm_iadder_in[31:2];
    assign unused_sink_lo   = &unused_addr;

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////