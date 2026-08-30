`timescale 1ns / 1ps

module BRAM_test_TB;

    // Inputs to DUT
    reg clk;
    reg reset;
    reg [13:0] addra;
    reg [13:0] addrb;
    reg [31:0] dina;
    reg [31:0] dinb;
    reg ena;
    reg enb;
    reg wea;
    reg web;

    // Outputs from DUT
    wire [31:0] douta;
    wire [31:0] doutb;

    // Testbench tracking variables
    integer cycle_count;

    // Instantiate the Device Under Test (DUT)
    BRAM_Letency_test dut (
        .clk(clk),
        .reset(reset),
        .addra(addra),
        .addrb(addrb),
        .dina(dina),
        .dinb(dinb),
        .ena(ena),
        .enb(enb),
        .wea(wea),
        .web(web),
        .douta(douta),
        .doutb(doutb)
    );

    // 1. Clock Generation (100 MHz -> 10ns Period)
    always #5 clk = ~clk;

    // 2. Cycle Counter for tracking execution in console logs
    always @(posedge clk) begin
        if (reset)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    // 3. Test Stimulus Sequence
    initial begin
        // Initialize Inputs
        clk   = 0;
        reset = 1;
        addra = 14'h0000;
        addrb = 14'h0000;
        dina  = 32'h0;
        dinb  = 32'h0;
        ena   = 0;
        enb   = 0;
        wea   = 0;
        web   = 0;

        // Hold Reset for 20 ns (2 clock cycles)
        #20;
        
        // De-assert Reset
        reset = 0;
        #10;

        // Enable Port A in READ mode (wea = 0)
        // This will cause addr_porta to start auto-incrementing from 0
        @(posedge clk);
        ena = 1'b1;
        wea = 1'b0;

        // Let the sequential reads run for 15 clock cycles
        repeat (15) @(posedge clk);

        // Stop reading
        ena = 1'b0;
        #20;

        $display("--------------------------------------------------");
        $display("Latency Test Completed.");
        $display("--------------------------------------------------");
        $finish;
    end

    // 4. Console Monitor to measure latency cycle-by-cycle
    initial begin
        $display("Time(ns) | Cycle | Reset | ENA | Address_PortA | Data_OutA");
        $display("-----------------------------------------------------------");
        
        // Display values on every rising edge of clock
        forever @(posedge clk) begin
            #1; // Small delta delay to allow registers to update
            $display("%8t | %5d |   %b   |  %b  |     0x%04h    | 0x%08h", 
                     $time, cycle_count, reset, ena, dut.addr_porta, douta);
        end
    end

endmodule