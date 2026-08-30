`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
////UART////  
module uart(
    input clk_100MHz,                  // 100MHz System clock (from Top Level / Clock Generator)
    input reset,                       // System reset (from Top Level / Reset Controller)
    input [7:0] din,                   // 8-bit input data to transmit (from Memory-Mapped Bus / Core Output Port)
    input vdin,                        // Valid data input enable (from Bus Controller / Core Write Enable)
    output dout                        // Serial UART TX output stream (to External Pin / Serial Interface)
);
     
    reg [31:0] count1;
    always@(posedge clk_100MHz) begin
        if      (count1<10415) count1 <= count1+1;
        else                   count1 <= 0;
    end
     
    reg clk_9600Hz;
    always@(posedge clk_100MHz) begin
        if      (count1==5209) clk_9600Hz <= 1;
        else if (count1==   1) clk_9600Hz <= 0;
    end
     
    // ------------------ FIFO ------------------------
     
    reg [7:0] ram [1023:0];
     
    reg [9:0] wadd;
    always@(posedge clk_100MHz) if (reset) wadd <= 0; else if (vdin ) wadd <= wadd + 1 ;
     
    always@(posedge clk_100MHz) if (vdin) ram[wadd] <= din;
     
    reg [9:0] radd;
    initial radd <= 0;
     
    wire rready; assign rready = (wadd>radd) ? 1 : 0 ;
     
    reg [3:0] count;
    always@(posedge clk_9600Hz) begin
        if      (reset   ) count <= 9;
        else if (count<9 ) count <= count + 1;
        else if (rready  ) count <= 0;
    end
     
    always@(posedge clk_9600Hz) begin
        if      (reset              ) radd <= 0;
        else if (count==9 && rready) radd <= radd + 1;
    end
     
    wire vdtx; assign vdtx = (count==0) ? 1 : 0 ;
     
    reg [7:0] dtx;
    always@(posedge clk_9600Hz) begin
        if (count==9 && rready) dtx <= ram[radd];
    end
     
    // ------------------ UART signal ------------------------
     
    reg        data_tx;
    reg [7:0] data   ;
    reg [4:0] state  ;
    always@(posedge clk_9600Hz) begin
        case(state)
        4'd0 :  if (vdtx ) begin state <= 1; data_tx <= 0; data <= dtx; end
                else       begin state <= 0; data_tx <= 1; data <= 0;   end
                
        4'd1 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 2; data_tx <= data[0]; end
                
        4'd2 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 3; data_tx <= data[1]; end
                
        4'd3 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 4; data_tx <= data[2]; end
                
        4'd4 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 5; data_tx <= data[3]; end
                
        4'd5 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 6; data_tx <= data[4]; end
                
        4'd6 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 7; data_tx <= data[5]; end
                
        4'd7 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 8; data_tx <= data[6]; end
                
        4'd8 :  if (reset) begin state <= 0; data_tx <= 1; end 
                else       begin state <= 9; data_tx <= data[7]; end
                
        4'd9 :    begin state <= 0; data_tx <= 1; end
                
        default : begin state <= 0; data_tx <= 1; end
        endcase
    end
     
    assign dout = data_tx ;
     
     
    integer write_sim_output;
    initial write_sim_output = $fopen("C:/Users/Backup/Downloads/output/uart_hw.txt","w");
    always@(posedge clk_100MHz) begin
        if (vdin) begin                  
            write_sim_output = $fopen("C:/Users/Backup/Downloads/output/uart_hw.txt","a");
            $fwrite(write_sim_output, "%c", din );
            $fclose(write_sim_output);
        end
    end
     
endmodule
