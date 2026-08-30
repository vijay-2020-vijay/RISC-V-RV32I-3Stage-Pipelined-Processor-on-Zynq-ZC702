`timescale 1ns / 1ps           
////////////////////////////////////////////////////////////////////////////////////
////////////// cache memory //////////////////
////////////////////////////////////////////////////////////////////////////////////

module I_cache (
       input clk,                          // System clock (from Top Level / Clock Gen)
       input reset,                        // System reset (from Top Level / Reset Controller)
       input  [31:0] iadder_in,                 // Instruction address (from PC / Fetch Stage -> pc_out)
       output reg [31:0] rdata,             // Fetched instruction data (to Decode Stage / Instruction Register -> instr_out)
       output unused_sink_ic
       
);   
(* ram_style = "block" *) reg [31:0] mem [0:512];//// we have chosen this because we have an assembley program of  450 machine instraction 
initial $readmemh("D:/verilog22/project_1RISCV_3stage_RV32I/I_and_D_cache_memorey/I_cach_h_10_boot_address.hex",mem); // for sever
//initial $readmemh("D:/RISC V/memor.hex",mem);
/////////////////////////////////////////////////////////////////////////////////////////////////////
//// ----------------------        Read Channel        -------------------- ////
   
    wire [0:8] mem_add;
    assign   mem_add = iadder_in[10:2];
    always@(posedge clk) begin
      if   (reset) begin
            rdata   <=32'd0;
      end
      else  begin
            rdata  <= mem[mem_add];
      end        
    end
    
 // Sink unused input address bits to eliminate Synth 8-7129 warnings
    wire [22:0] unused_addr = {iadder_in[31:11], iadder_in[1:0]};
    assign      unused_sink_ic = &unused_addr;   
    
endmodule