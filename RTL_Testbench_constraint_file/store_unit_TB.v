`timescale 1ns / 1ps
  
module store_unit_TB;

    // Testbench Inputs
    reg [1:0]  funct3_in;
    reg [31:0] iaddr_in;
    reg [31:0] rs2_in;
    reg        mem_wr_req_in;
    reg        ahb_ready_in;

    // Testbench Outputs
    wire [31:0] ms_riscv32_mp_dmdata_out;
    wire [31:0] ms_riscv32_mp_dmaddr_out;
    wire [3:0]  ms_riscv32_mp_dmwr_mask_out;
    wire        ms_riscv32_mp_dmwr_req_out;
    wire [1:0]  ahb_htrans_out;

    // Instantiate Unit Under Test (UUT)
    store_unit uut (
        .funct3_in                  (funct3_in),
        .iaddr_in                   (iaddr_in),
        .rs2_in                     (rs2_in),
        .mem_wr_req_in              (mem_wr_req_in),
        .ahb_ready_in               (ahb_ready_in),
        .ms_riscv32_mp_dmdata_out    (ms_riscv32_mp_dmdata_out),
        .ms_riscv32_mp_dmaddr_out    (ms_riscv32_mp_dmaddr_out),
        .ms_riscv32_mp_dmwr_mask_out (ms_riscv32_mp_dmwr_mask_out),
        .ms_riscv32_mp_dmwr_req_out  (ms_riscv32_mp_dmwr_req_out),
        .ahb_htrans_out             (ahb_htrans_out)
    );

    initial begin
        // Default Signal Initialization
        funct3_in     = 2'b00;
        iaddr_in      = 32'h0000_0000;
        rs2_in        = 32'h0000_0000;
        mem_wr_req_in = 1'b0;
        ahb_ready_in  = 1'b1;

        #10;

        // -------------------------------------------------------------
        // Test 1: Store Byte (SB - funct3 = 2'b00) Across All Offsets
        // -------------------------------------------------------------
        $display("--- Test 1: Store Byte (SB) ---");
        mem_wr_req_in = 1'b1;
        funct3_in     = 2'b00;
        rs2_in        = 32'hAAAA_BBCC; // LSB Byte is 0xCC

        // Offset 00 -> Mask: 0001, Data: 0x000000CC
        iaddr_in = 32'h1000_0000; #10;
        
        // Offset 01 -> Mask: 0010, Data: 0x0000CC00
        iaddr_in = 32'h1000_0001; #10;
        
        // Offset 10 -> Mask: 0100, Data: 0x00CC0000
        iaddr_in = 32'h1000_0002; #10;
        
        // Offset 11 -> Mask: 1000, Data: 0xCC000000
        iaddr_in = 32'h1000_0003; #10;

        // -------------------------------------------------------------
        // Test 2: Store Half-word (SH - funct3 = 2'b01)
        // -------------------------------------------------------------
        $display("--- Test 2: Store Half-word (SH) ---");
        funct3_in = 2'b01;
        rs2_in    = 32'h1234_5678; // Lower Half-word is 0x5678

        // Lower Half (iaddr[1] = 0) -> Mask: 0011, Data: 0x00005678
        iaddr_in = 32'h2000_0000; #10;
        
        // Upper Half (iaddr[1] = 1) -> Mask: 1100, Data: 0x56780000
        iaddr_in = 32'h2000_0002; #10;

        // -------------------------------------------------------------
        // Test 3: Store Word (SW - funct3 = 2'b10)
        // -------------------------------------------------------------
        $display("--- Test 3: Store Word (SW) ---");
        funct3_in = 2'b10;
        rs2_in    = 32'hDEAD_BEEF;
        
        // Full Word -> Mask: 1111, Data: 0xDEADBEEF
        iaddr_in  = 32'h3000_0004; #10;

        // -------------------------------------------------------------
        // Test 4: AHB Bus Ready Low (Stall Condition)
        // -------------------------------------------------------------
        $display("--- Test 4: AHB Not Ready Stall ---");
        ahb_ready_in = 1'b0; #10; // HTRANS must drop to 2'b00 (IDLE)
        ahb_ready_in = 1'b1; #10; // HTRANS returns to 2'b10 (NONSEQ)

        // -------------------------------------------------------------
        // Test 5: Address Alignment Verification
        // -------------------------------------------------------------
        $display("--- Test 5: Address Word-Alignment ---");
        // Unaligned address ending in 0x07 must output aligned 0x04
        iaddr_in = 32'h4000_0007; #10;

        $display("\nSimulation Completed.");
        $finish;
    end

    // Waveform Monitor
    initial begin
        $monitor("Time=%0tn | READY=%b | FUNCT3=%b | ADDR_IN=%h | ADDR_OUT=%h | DATA_OUT=%h | MASK=%b | HTRANS=%b",
                 $time, ahb_ready_in, funct3_in, iaddr_in, ms_riscv32_mp_dmaddr_out, ms_riscv32_mp_dmdata_out, ms_riscv32_mp_dmwr_mask_out, ahb_htrans_out);
    end

endmodule
