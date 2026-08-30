`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////
//This module decodes RISC-V instructions and generates various control signals required by the processor pipeline.
(* suppress_message = "Synth 8-7129, Synth 8-7080, Synth 8-7052" *)
module  msrv32_decoder (
    input        trap_taken_in,//(comming from mechine_control)//when trap occure,normal execution is interrupted//
    //When high, indicates a trap has occurred and normal execution should be interrupted.
    input  [6:0] funct7_in,//bit 5 of the instraction_field//helps to distinguish between sub and add (comming from the instraction decoder) 
    input  [6:0] opcode_in,//determines the type of instraction(R,I...)(cpmming from instraction _decoder also)
    input  [2:0] funct3_in,//instractin_subtype helps to identify the exact instraction like(LW,LH,LB)that set
    input  [31:0]imm_iadder_in,//this is LSB bit of address result used to cheak if the memorey address is miss_alignment for load/store operation

    output reg [2:0] wb_mux_sel_out,// selects the data to be written in the integer_Register_File(to Register block 2)
    output reg[2:0] imm_type_out,//immediate type of selector(I_type,S_type,B_type,U_type,J_type etc)(to immediate generetor)
    output reg[2:0] csr_op_out,//csr_operation type//selects the operations to be performed by the csr register file (read,write,sel,clear)(to reg block 2)
    output reg mem_wr_req_out,//memorey write request :high when the instraction is (SW,SB,sH)(goes to store unit)
    output reg [3:0]alu_opcode_out,//selects the alu operation to be performed(to register block 2)
    output reg [1:0]load_size_out,//indicates the word size of the load instractions( to register block 2)
    output reg load_unsigned_out,//high is the load instraction is unsigned(LBU,LHU)(to reg block 2)
    output reg alu_src_out,//select the alu's 2nd operand(0:register operand and 1: immediate operand)(goes to reg block 2)
    output reg iadder_src_out,//selects the 2nd operand of  instraction address adder: 0:pc and 1=rs1 //(goes to immediate adder)
    output reg csr_wr_en_out,//enablw signal for writting to the csr file //controls the wr_en input of csr file(to register block 2)
    output reg rf_wr_en_out,//controls the wr_en input of integer register file (to reg block 2)
    output reg illegal_instr_out,//when set high indicates that an invalid or not implemented instraction was featched from memorey(goes to mechine control)
    output reg misaligned_load_out,//high if a load address violates alignment rule (lw or non word allignment address)
    output reg misaligned_store_out,//when high indicates an attempt to read data in disagrument with memorey allignment rules(to mechine control)
    output  is_load_out,
    output  is_store_out,
    output  unused_sink_De
    
);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// ---------- Instruction Type Detection ----// 
/////Internal wire declarations
/////////////////////////////////////unusedbit/////////////////////////
// Corrected for all 36 unused input bits (36-bit bus, index [35:0]):
wire [35:0] unused_bit;
assign unused_bit = {funct7_in[6], funct7_in[4:0], imm_iadder_in[31:2]};
assign unused_sink_De = &unused_bit;
//////////////////////////////////////////////////////////////////////
wire funct7_5_in;
wire[1:0] iadder_out_1_to_0_in;
assign funct7_5_in =funct7_in[5];
assign iadder_out_1_to_0_in=imm_iadder_in[1:0];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire is_load, is_store, is_branch, is_jal, is_jalr,is_misc_mem,is_csr;
wire is_lui, is_auipc, is_op_imm, is_op, is_system,is_valid;
assign is_load   = (opcode_in == 7'b0000011);///opcode for load instraction
assign is_store  = (opcode_in == 7'b0100011);///opcode for store instraction
assign is_branch = (opcode_in == 7'b1100011);///opcode for branch instraction
assign is_jal    = (opcode_in == 7'b1101111);///opcode for jal instraction
assign is_jalr   = (opcode_in == 7'b1100111);///opcode for jalr instraction
assign is_lui    = (opcode_in == 7'b0110111);///opcode for lui instraction
assign is_auipc  = (opcode_in == 7'b0010111);///opcode for auipc instraction
assign is_op_imm = (opcode_in == 7'b0010011);///opcode for op_imm instraction
assign is_op     = (opcode_in == 7'b0110011);///opcode for op instraction
assign is_system = (opcode_in == 7'b1110011);///opcode for system instraction///this is also opcode of the csr instraction
assign is_misc_mem =(opcode_in == 7'b0001111);///opcode for misc_mem instraction
assign is_valid  = is_load | is_store | is_branch | is_jal | is_jalr |
                   is_lui | is_auipc | is_op_imm | is_op | is_system | is_misc_mem ;
                   
assign is_csr = is_system & (funct3_in[2] | funct3_in[1]| funct3_in[2]);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire is_addi,is_slti,is_sltiu,is_andi,is_xori,is_ori;
wire is_add,is_slt,is_sltu,is_and,is_xor,is_or;
wire valid1;
assign is_add=(funct3_in==3'b000);
assign is_slt=(funct3_in==3'b010);
assign is_sltu=(funct3_in==3'b011);
assign is_and=(funct3_in==3'b111);
assign is_or=(funct3_in==3'b110);
assign is_xor=(funct3_in==3'b100);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign is_addi=(is_add &  is_op_imm);
assign is_slti=(is_slt &  is_op_imm);
assign is_sltiu=(is_sltu &  is_op_imm);
assign is_andi=(is_and &  is_op_imm);
assign is_ori=(is_or &  is_op_imm);
assign is_xori=(is_xor &  is_op_imm); 
//////////////////////a) ALU opcode generation////////////////////////////////////////////////////////////////////////
always @(*) begin
    alu_opcode_out[2:0] = funct3_in;///captureing 3 bit from funct3
    alu_opcode_out[3]   = funct7_5_in & ~(is_addi |is_slti| is_sltiu |is_andi |is_ori| is_xori) ;
end
///////////////////////(b) Load size_out and load_unsigned_out//////////////////////////////////////////////////////////
always @(*) begin
    load_size_out     = funct3_in[1:0];
    load_unsigned_out = funct3_in[2];
end
/////////////////////c) ALU source select//alu_src_out ///////////////////////////////////////////////////////////////
always @(*) begin
    alu_src_out = opcode_in[5];
end
////////////////////d) Immediate adder source///iadder_src_out//////////////////////////////////////////////////////
always @(*) begin
    iadder_src_out = is_load | is_store | is_jalr;
end
/////////////////////e) CSR write enable/////////////////////////////////////////////////////////////////////////////
always @(*) begin
    csr_wr_en_out = is_csr;
end
////////////////////(f) Register file write enable///////////////////////////////////////////////////////////////////
always @(*) begin
    rf_wr_en_out = is_lui | is_auipc | is_jal | is_jalr |
                   is_op | is_op_imm | is_load | is_csr;
end
////////////////////g) Writeback mux select// wb_mux_sel_out///////////////////////////////////////////////////////////////////////
always @(*) begin
    wb_mux_sel_out[0] = is_load | is_jalr | is_jal | is_auipc ;
    wb_mux_sel_out[1] = is_lui | is_auipc;
    wb_mux_sel_out[2] = is_jalr | is_jal |  is_csr;
    
end
/////////////////////h) Immediate type selection/////////////////////////////////////////////////////////////////////
always @(*) begin
    imm_type_out[0] = is_op_imm | is_load | is_jalr | is_jal | is_branch  ;
    imm_type_out[1] = is_store | is_branch |  is_csr;
    imm_type_out[2] =  is_lui | is_auipc | is_jal | is_csr;
end
//////////////////// i) CSR operation signal// csr_op_out////////////////////////////////////////////////////////////
always @(*) begin
    csr_op_out = funct3_in;
end
//////////////////// j) Illegal instruction detection/// illegal_instr_out///////////////////////////////////////////
always @(*) begin
    illegal_instr_out = ~is_valid;
end
///////////////////// k) Misaligned access checks///////////////////////////////////////////////////////////////////
wire mal_word, mal_half;
assign mal_word = (funct3_in == 3'b010) && ( iadder_out_1_to_0_in != 2'b00);  // word access must be aligned
assign mal_half = (funct3_in == 3'b001) && (iadder_out_1_to_0_in[0] != 1'b0); // halfword must be even address
always @(*) begin
    misaligned_load_out  = (mal_word | mal_half) & is_load;
    misaligned_store_out = (mal_word | mal_half) & is_store;
end
////////////////////l) Memory write request///mem_wr_req_out/////////////////////////////////////////////////////////
always @(*) begin
    mem_wr_req_out = is_store & ~trap_taken_in & ~mal_word & ~mal_half;
end
assign is_load_out=is_load;
assign is_store_out=is_store;

endmodule
////////////////////////////////////////////////////////////////////////