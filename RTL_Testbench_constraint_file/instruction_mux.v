`timescale 1ns / 1ps  
//////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////


module instruction_mux(
    input flush_in,                        // IN:  From Machine Control / Pipeline Controller (forces NOP 32'h00000013 on pipeline flush)
    input [31:0] ms_riscv32_mp_instr_in,   // IN:  From Core Instruction Input / Instruction Memory
    output [6:0] opcode_out,               // OUT: To Decoder and Machine Control (Opcode bits [6:0])
    output [2:0] funct3_out,               // OUT: To Store Unit, Decoder, Branch Unit, and Machine Control (funct3 bits [14:12])
    output [6:0] funct7_out,               // OUT: 5th bit to Decoder, and Machine Control (funct7 bits [31:25])
    output [4:0] rs1addr_out,              // OUT: To Integer Register File and Machine Control (Source 1 address bits [19:15])
    output [4:0] rs2addr_out,              // OUT: To Integer Register File and Machine Control (Source 2 address bits [24:20])
    output [4:0] rdaddr_out,               // OUT: To Machine Control and reg_block_2 (Destination address bits [11:7])
    output [11:0] csr_addr_out,            // OUT: To reg_block_2 for CSR read/write/modify (CSR address bits [31:20])
    output [31:7] instr_out                // OUT: To Immediate Generator (Instruction slice [31:7])
    );

reg [31:0] instr_value;

always @*
begin

if(flush_in == 1)
    instr_value = 32'h0000_0013;           // When flush is HIGH: Forces NOP instruction (addi x0, x0, 0)
else
    instr_value = ms_riscv32_mp_instr_in;  // When flush is LOW: Passes incoming instruction from core memory

end    
    
   assign opcode_out   = instr_value[6:0];
   assign funct3_out   = instr_value[14:12];
   assign funct7_out   = instr_value[31:25];
   assign csr_addr_out = instr_value[31:20]; 
   assign rs1addr_out  = instr_value[19:15];
   assign rs2addr_out  = instr_value[24:20];
   assign rdaddr_out   = instr_value[11:7];
   assign instr_out    = instr_value[31:7];
    
endmodule   