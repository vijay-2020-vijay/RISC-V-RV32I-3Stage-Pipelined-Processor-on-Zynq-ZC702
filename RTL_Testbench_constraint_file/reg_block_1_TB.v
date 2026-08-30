`timescale 1ns / 1ps

module reg_block_1_TB;

    // Inputs (driven by testbench)
    reg [31:0] PC_mux_in;
    reg ms_riscv32_clk;
    reg ms_riscv32_rst;

    // Outputs (monitored from UUT)
    wire [31:0] pc_out;

    // Instantiate Unit Under Test (UUT)
    reg_block_1 uut (
        .PC_mux_in(PC_mux_in),
        .ms_riscv32_clk(ms_riscv32_clk),
        .ms_riscv32_rst(ms_riscv32_rst),
        .pc_out(pc_out)
    );

    // Clock generation (10ns period -> toggles every 5ns)
    always #5 ms_riscv32_clk = ~ms_riscv32_clk;

    initial begin
        // Initialize Clock & Test Inputs
        ms_riscv32_clk = 0;
        ms_riscv32_rst = 1;              // Active-High reset applied
        PC_mux_in = 32'h0000_1000;
        #10;                            // Wait for clock edge -> pc_out should load boot address 32'h0000_0200

        // Case 1: Release reset & load first PC address
        ms_riscv32_rst = 0;
        PC_mux_in = 32'h0000_0204;
        #10;                            // Wait for clock edge -> pc_out becomes 32'h0000_0204

        // Case 2: Load next PC address (PC + 4)
        PC_mux_in = 32'h0000_0208;
        #10;                            // Wait for clock edge -> pc_out becomes 32'h0000_0208

        // Case 3: Test Reset pulse again
        ms_riscv32_rst = 1;
        #10;                            // Reset active -> pc_out resets back to 32'h0000_0200

        $finish;
    end

endmodule
