`timescale 1ns / 1ps  
//////////////////////////////////////////////////////////////////////////////////

module BRAM_Letency_test(
       input clk,
       input reset,
       input [13:0]addra,addrb,
       input [31:0]dina,dinb,
       input ena,enb,
       input wea,web,
       output [31:0]douta, doutb
    );
 /////////// we will test only the letency of Bram port A ; specially for zynq 7000 series FPGA///ok
reg  [10:0]count ;
reg [13:0]addr_porta,addr_portb;
blk_mem_gen_0  bram1 
    (.addra(addr_porta),.clka(clk),.dina(dina),
     .douta(douta),.ena(ena), .wea(wea),
     .addrb(addr_portb),.clkb(clk),.dinb(dinb),
     .doutb(doutb),.enb(enb), .web(web)
);
    
always @(posedge clk)begin
        if(reset)begin
           count<=0;
           addr_porta<=addra;
        end
        else begin
           if(ena == 1'b1  && wea==1'b0)begin
              addr_porta<=addr_porta+1;
           end
           
        
        end
        
end  
 
endmodule
