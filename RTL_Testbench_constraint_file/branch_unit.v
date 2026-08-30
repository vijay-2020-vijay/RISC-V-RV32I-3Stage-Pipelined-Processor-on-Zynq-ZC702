`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Branch and Jump Evaluation Unit
//////////////////////////////////////////////////////////////////////////////////

module branch_unit (
    input  [31:0] rs1_in,           // From Register File (Operand 1)
    input  [31:0] rs2_in,           // From Register File (Operand 2)
    input  [6:0]  opcode_in,        // Opcode (bits [6:0])
    input  [2:0]  funct3_in,        // Funct3 (bits [14:12])
    output reg    branch_taken_out, // High if branch/jump is taken
    output        unused_sink_br    // Sink for unused opcode bits [1:0]
);

    wire [4:0] opcode_6_to_2_in = opcode_in[6:2];

    always @* begin
        // Default assignment to guarantee zero latches
        branch_taken_out = 1'b0;

        if (opcode_6_to_2_in == 5'b11_000) begin // Branch Instructions
            case (funct3_in)
                3'b000: begin // BEQ
                    branch_taken_out = (rs1_in == rs2_in);
                end

                3'b001: begin // BNE
                    branch_taken_out = (rs1_in != rs2_in);
                end

                3'b100: begin // BLT (Signed comparison)
                    if (rs1_in[31] == rs2_in[31]) begin
                        if (rs1_in[31] == 1'b0) begin
                            branch_taken_out = (rs1_in[30:0] < rs2_in[30:0]);
                        end else begin
                            branch_taken_out = (rs1_in[30:0] > rs2_in[30:0]);
                        end
                    end else begin
                        branch_taken_out = (rs1_in[31] == 1'b1);
                    end
                end

                3'b101: begin // BGE (Signed comparison)
                    if (rs1_in[31] == rs2_in[31]) begin
                        if (rs1_in[31] == 1'b0) begin
                            branch_taken_out = (rs1_in[30:0] >= rs2_in[30:0]); // Fixed: Includes equality
                        end else begin
                            branch_taken_out = (rs1_in[30:0] <= rs2_in[30:0]); // Fixed: Includes equality
                        end
                    end else begin
                        branch_taken_out = (rs1_in[31] == 1'b0);
                    end
                end

                3'b110: begin // BLTU (Unsigned comparison)
                    branch_taken_out = (rs1_in < rs2_in);
                end

                3'b111: begin // BGEU (Unsigned comparison)
                    branch_taken_out = (rs1_in >= rs2_in);
                end

                default: branch_taken_out = 1'b0;
            endcase
        end 
        else if (opcode_6_to_2_in == 5'b11011) begin // JAL
            branch_taken_out = 1'b1;
        end 
        else if (opcode_6_to_2_in == 5'b11001) begin // JALR
            branch_taken_out = 1'b1;
        end 
        else begin
            branch_taken_out = 1'b0;
        end
    end

    // Sink unused lower 2 bits of opcode_in to eliminate synthesis warnings
    wire [1:0] unused_opcode = opcode_in[1:0];
    assign unused_sink_br    = &unused_opcode;

endmodule