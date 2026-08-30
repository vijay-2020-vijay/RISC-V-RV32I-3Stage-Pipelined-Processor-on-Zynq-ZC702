`timescale 1ns / 1ps    
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
module msrv32_integer_file (
    input         ms_riscv32_mp_clk_in, // From Clock Generator / System Clock
    input         ms_riscv32_mp_rst_in, // From Reset Generator / System Reset
    input  [4:0]  rs_1_addr_in,         // From Instruction Mux
    input  [4:0]  rs_2_addr_in,         // From Instruction Mux
    input  [4:0]  rgb2_rd_addr_reg_out,           // From reg_block_2
    input         wr_en_in,             // From wr_en_generator
    input  [31:0] wb_mux_sel_rd_in,                // From Wb_mux
    output [31:0] rs_1_out,             // To reg_block_2, immediate_adder & branch_unit
    output [31:0] rs_2_out,              // To reg_block_2, store_unit & branch_unit,
    input         load_unsigned_reg2_in,
    input  [1:0]  load_size_reg2_in,
    input  [31:0] imm_iadder_reg2_in,
    output unused_sink_in 
    
);
reg  [31:0] wb_mux_sel_rd_in1;
always @(*)begin
//// this conditions is only for lbu instraction///////////////
       if(load_unsigned_reg2_in==1'b1 && load_size_reg2_in == 2'd0 && imm_iadder_reg2_in[1:0]==2'd0) begin
                //wb_mux_sel_rd_in1={24'd0,wb_mux_sel_rd_in[7:0]};
                wb_mux_sel_rd_in1=wb_mux_sel_rd_in;
       end
       else begin
                wb_mux_sel_rd_in1=wb_mux_sel_rd_in;
       end
end




    reg [31:0] reg_file [31:0];
    integer i;

    // Synchronous Write & Reset Logic
    always @(posedge ms_riscv32_mp_clk_in) begin
        if (ms_riscv32_mp_rst_in) begin
            for (i = 0; i < 32; i = i + 1) begin
                if (i == 2)
                    reg_file[i] <= 32'h0002_F000; // Initial Stack Pointer (x2 / sp)
                else
                    reg_file[i] <= 32'h0000_0000;
            end
        end else if (wr_en_in && (rgb2_rd_addr_reg_out != 5'b00000)) begin
            reg_file[rgb2_rd_addr_reg_out] <= wb_mux_sel_rd_in1;
        end
    end

    // Asynchronous Read with Forwarding (Write-Bypass) Logic
    assign rs_1_out = (wr_en_in && (rs_1_addr_in == rgb2_rd_addr_reg_out) && (rgb2_rd_addr_reg_out != 5'b00000)) 
                      ? wb_mux_sel_rd_in1
                      : reg_file[rs_1_addr_in];

    assign rs_2_out = (wr_en_in && (rs_2_addr_in == rgb2_rd_addr_reg_out) && (rgb2_rd_addr_reg_out!= 5'b00000)) 
                      ? wb_mux_sel_rd_in1
                      : reg_file[rs_2_addr_in];
                      
                      
   // Sink unused input ports & upper address bits to clear Vivado warnings
    assign unused_sink_in = load_unsigned_reg2_in ^ (|load_size_reg2_in) ^ (|imm_iadder_reg2_in);                   
                      

endmodule
