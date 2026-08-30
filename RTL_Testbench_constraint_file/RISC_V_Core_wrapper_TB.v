`timescale 1ns / 1ps    
      
module RISC_V_Core_wrapper_TB;
    // ------------------ Clock (100 MHz -> 10 ns Period) ------------------
    reg ms_riscv32_clk_0;
    initial begin
        ms_riscv32_clk_0 = 1'b0;
        forever #5 ms_riscv32_clk_0 = ~ms_riscv32_clk_0;
    end

    // ------------------ Input Regs & Output Wires ------------------
    reg         ms_riscv32_rst_0;
    reg         ms_riscv32_mp_hready_in_0;
    reg         ms_riscv32_mp_instr_hready_in_0;
    reg         ms_riscv32_mp_eirq_in_0;
    reg         ms_riscv32_mp_sirq_in_0;
    reg         ms_riscv32_mp_tirq_in_0;
   

    wire        mie_out_0;
    wire [1:0]  ms_riscv32_mp_data_htrans_out_0;
    wire        ms_riscv32_mp_dmwr_req_out_0;
    wire        unused_out1_0;
    wire [139:0]result_status_0;

    // ------------------ DUT Instantiation ------------------
    RISC_V_Core_wrapper uut (
        .mie_out_0                      (mie_out_0),
        .ms_riscv32_clk_0               (ms_riscv32_clk_0),
        .ms_riscv32_mp_data_htrans_out_0(ms_riscv32_mp_data_htrans_out_0),
        .ms_riscv32_mp_dmwr_req_out_0   (ms_riscv32_mp_dmwr_req_out_0),
        .ms_riscv32_mp_eirq_in_0        (ms_riscv32_mp_eirq_in_0),
        .ms_riscv32_mp_hready_in_0      (ms_riscv32_mp_hready_in_0),
        .ms_riscv32_mp_instr_hready_in_0(ms_riscv32_mp_instr_hready_in_0),
        .ms_riscv32_mp_sirq_in_0        (ms_riscv32_mp_sirq_in_0),
        .ms_riscv32_mp_tirq_in_0        (ms_riscv32_mp_tirq_in_0),
        .ms_riscv32_rst_0               (ms_riscv32_rst_0),
        .unused_out1_0                  (unused_out1_0),
        .result_status_0                (result_status_0)
        
    );
/*
    // ------------------ Real-time Counter ------------------
    always @(posedge ms_riscv32_clk_0) begin
        if (ms_riscv32_rst_0)
            real_time_in_0 <= 64'd0;
        else
            real_time_in_0 <= real_time_in_0 + 1'b1;
    end
*/
    // ------------------ Simple Stimulus ------------------
    initial begin
        // Default Inputs
        ms_riscv32_rst_0                = 1'b1;/// assereted active high reset
        ms_riscv32_mp_hready_in_0       = 1'b1;/// Data_bus ready
        ms_riscv32_mp_instr_hready_in_0 = 1'b1;///instraction bus ready
        ms_riscv32_mp_eirq_in_0         = 1'b0;/// External IRQ ready
        ms_riscv32_mp_sirq_in_0         = 1'b0;/// software IRQ ready
        ms_riscv32_mp_tirq_in_0         = 1'b0;/// Timmer IRQ ready
        // Reset Pulse
        #100;
        ms_riscv32_rst_0 = 1'b0;

        // Run Simulation
        #100000;  
        $finish;  
    end

endmodule   
