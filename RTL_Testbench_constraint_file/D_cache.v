
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Data Cache / Memory (BRAM Inferred)
// Continuous Synchronous Read with Conditional Byte-Masked Write
//////////////////////////////////////////////////////////////////////////////////

module D_cache #(
    parameter ADD_WIDTH = 18,
    parameter DEPTH     = (2**ADD_WIDTH)/4
)(
    input         clk,            // System clock
    input         reset,          // System reset
    input  [31:0] addr,           // Memory address
    output reg [31:0] rdata,      // Memory read data output (1-clock delay)
    input  [3:0]  wen,            // Byte-wise write enable mask
    input  [31:0] wdata,          // Memory write payload
    output        unused_sink_Dc  // Bit-sink for unused address bits
);

    // Memory array
    (* ram_style = "block" *)reg [31:0] mem1 [0:DEPTH-1];

    // Initialize memory contents
    initial $readmemh("D:/verilog22/project_1RISCV_3stage_RV32I/I_and_D_cache_memorey/data_memory.hex", mem1);

    // Address extraction (Word-aligned address)
    wire [ADD_WIDTH-3:0] mem_add = addr[ADD_WIDTH-1:2];

    // --------------------------------------------------------------------------
    // Combinational Write-Data Byte Masking
    // --------------------------------------------------------------------------
    wire [31:0] wdata1;
    assign wdata1[31:24] = (wen[3]) ? wdata[31:24] : rdata[31:24];
    assign wdata1[23:16] = (wen[2]) ? wdata[23:16] : rdata[23:16];
    assign wdata1[15: 8] = (wen[1]) ? wdata[15: 8] : rdata[15: 8];
    assign wdata1[ 7: 0] = (wen[0]) ? wdata[ 7: 0] : rdata[ 7: 0];

    // --------------------------------------------------------------------------
    // Synchronous Read and Write Logic (1-Clock Delay)
    // --------------------------------------------------------------------------
    always @(posedge clk) begin
        // Read happens continuously every clock cycle
        rdata <= mem1[mem_add];

        // Write happens ONLY when reset is inactive AND at least one byte enable is active
        if (!reset && (wen != 4'b0000)) begin
            mem1[mem_add] <= wdata1;
        end
    end

    // ------------------ Sink Unused Address Bits ------------------ //
    wire [19:0] unused_bit1 = {addr[31:18], addr[1:0]};
    assign unused_sink_Dc = &unused_bit1;

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////