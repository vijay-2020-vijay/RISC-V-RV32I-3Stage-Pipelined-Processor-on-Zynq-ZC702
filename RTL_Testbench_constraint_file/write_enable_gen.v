`timescale 1ns / 1ps      
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
module msrv32_wr_en_generator (
    input  flush_in,               // From machine control
    input  rf_wr_en_reg_in,        // From Reg Block 2
    input  csr_wr_en_reg_in,       // From Reg Block 2
    output reg wr_en_integer_file_out, // To integer file
    output reg wr_en_csr_file_out      // To csr_file
);


always @(*)begin
          if(flush_in == 1'b0)begin
             wr_en_integer_file_out = rf_wr_en_reg_in;
             wr_en_csr_file_out     = csr_wr_en_reg_in;
          end
          else begin
            wr_en_integer_file_out=1'b0;
            wr_en_csr_file_out    =1'b0;
          end

end
 
endmodule