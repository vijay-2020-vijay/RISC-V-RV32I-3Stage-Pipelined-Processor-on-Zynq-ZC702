`timescale 1ns / 1ps  

module msrv32_integer_file_TB;

    // Testbench Inputs
    reg         ms_riscv32_mp_clk_in;
    reg         ms_riscv32_mp_rst_in;
    reg  [4:0]  rs_1_addr_in;
    reg  [4:0]  rs_2_addr_in;
    reg  [4:0]  rd_addr_in;
    reg         wr_en_in;
    reg  [31:0] rd_in;

    // Testbench Outputs
    wire [31:0] rs_1_out;
    wire [31:0] rs_2_out;

    // Instantiate the Unit Under Test (UUT)
    msrv32_integer_file uut (
        .ms_riscv32_mp_clk_in (ms_riscv32_mp_clk_in),
        .ms_riscv32_mp_rst_in (ms_riscv32_mp_rst_in),
        .rs_1_addr_in         (rs_1_addr_in),
        .rs_2_addr_in         (rs_2_addr_in),
        .rd_addr_in           (rd_addr_in),
        .wr_en_in             (wr_en_in),
        .rd_in                (rd_in),
        .rs_1_out             (rs_1_out),
        .rs_2_out             (rs_2_out)
    );

    // Clock Generation: 100 MHz (10ns period)
    always #5 ms_riscv32_mp_clk_in = ~ms_riscv32_mp_clk_in;

    initial begin
        // Initialize Inputs
        ms_riscv32_mp_clk_in = 0;
        ms_riscv32_mp_rst_in = 0;
        rs_1_addr_in         = 5'd0;
        rs_2_addr_in         = 5'd0;
        rd_addr_in           = 5'd0;
        wr_en_in             = 1'b0;
        rd_in                = 32'h0;

        // 1. Synchronous Reset Test
        #10;
        ms_riscv32_mp_rst_in = 1'b1;
        #10;
        ms_riscv32_mp_rst_in = 1'b0;
        
        // Verify Stack Pointer (x2 / sp) initialization to 0x0002_F000
        #5;
        rs_1_addr_in = 5'd2; // x2
        rs_2_addr_in = 5'd5; // General register x5 (should be 0)
        #5;

        // 2. Standard Write & Read Back Test
        @(posedge ms_riscv32_mp_clk_in);
        rd_addr_in = 5'd5;
        rd_in      = 32'hDEAD_BEEF;
        wr_en_in   = 1'b1;

        @(posedge ms_riscv32_mp_clk_in);
        wr_en_in   = 1'b0;
        rs_1_addr_in = 5'd5; // Read back x5

        // 3. Write-to-Zero Register Test (x0 must remain 0)
        @(posedge ms_riscv32_mp_clk_in);
        rd_addr_in = 5'd0;
        rd_in      = 32'hFFFF_FFFF;
        wr_en_in   = 1'b1;
        wr_en_in   = 1'b1;

        @(posedge ms_riscv32_mp_clk_in);
        wr_en_in     = 1'b0;
        rs_1_addr_in = 5'd0; // Should read 32'h0000_0000

        // 4. Write Bypass / Data Forwarding Test (Same Cycle Read & Write)
        @(posedge ms_riscv32_mp_clk_in);
        rd_addr_in   = 5'd10;
        rd_in        = 32'h1234_5678;
        rs_1_addr_in = 5'd10; // Requesting x10 during active write
        rs_2_addr_in = 5'd5;  // Requesting stored register x5
        wr_en_in     = 1'b1;

        #2; // Allow combinational logic to propagate
        // rs_1_out forwards rd_in immediately due to write-bypass

        @(posedge ms_riscv32_mp_clk_in);
        wr_en_in = 1'b0;

        #20;
        $finish;
    end

    // Waveform Monitor
    initial begin
        $monitor("Time=%0tn | RST=%b | WR_EN=%b | RD_ADDR=x%0d RD_IN=%h | RS1_ADDR=x%0d RS1_OUT=%h | RS2_ADDR=x%0d RS2_OUT=%h",
                 $time, ms_riscv32_mp_rst_in, wr_en_in, rd_addr_in, rd_in, rs_1_addr_in, rs_1_out, rs_2_addr_in, rs_2_out);
    end

endmodule
