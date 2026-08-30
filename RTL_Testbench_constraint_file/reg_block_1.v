`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
////
/////////////////////////////////////////////////////////////////////////////////

module reg_block_1(
    input [31:0] PC_mux_in,     // IN:  From PC Mux (Next PC logic: PC+4, Branch, Trap, or Jalr target)
    input ms_riscv32_clk,       // IN:  From Clock Controller / System Clock
    input ms_riscv32_rst,       // IN:  From Reset Controller (Active-High Reset)
    output reg [31:0] pc_out    // OUT: To Instruction Memory (fetch unit) and PC Adder / Pipeline Stage
);
    
    always @(posedge ms_riscv32_clk)
    begin
        if (ms_riscv32_rst == 0) begin
            pc_out  <= PC_mux_in; 

            
        end  
                   // Normal state: Latches next address selected by PC Mux
        else if (ms_riscv32_rst == 1)begin
            pc_out <= 32'h0000_0010;    // Reset state: Loads initial RISC-V boot address (0x00000010)

        end     
    end
    
endmodule