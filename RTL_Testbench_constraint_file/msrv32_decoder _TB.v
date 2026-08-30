`timescale 1ns / 1ps

module msrv32_decoder_TB;

    // Testbench Inputs
    reg       trap_taken_in;
    reg       funct7_5_in;
    reg [6:0] opcode_in;
    reg [2:0] funct3_in;
    reg [1:0] iadder_out_1_to_0_in;

    // Testbench Outputs
    wire [2:0] wb_mux_sel_out;
    wire [2:0] imm_type_out;
    wire [2:0] csr_op_out;
    wire       mem_wr_req_out;
    wire [3:0] alu_opcode_out;
    wire [1:0] load_size_out;
    wire       load_unsigned_out;
    wire       alu_src_out;
    wire       iadder_src_out;
    wire       csr_wr_en_out;
    wire       rf_wr_en_out;
    wire       illegal_instr_out;
    wire       misaligned_load_out;
    wire       misaligned_store_out;
    wire       is_load_out;
    wire       is_store_out;

    // Instantiate Unit Under Test (UUT)
    msrv32_decoder uut (
        .trap_taken_in        (trap_taken_in),
        .funct7_5_in          (funct7_5_in),
        .opcode_in            (opcode_in),
        .funct3_in            (funct3_in),
        .iadder_out_1_to_0_in (iadder_out_1_to_0_in),
        .wb_mux_sel_out       (wb_mux_sel_out),
        .imm_type_out         (imm_type_out),
        .csr_op_out           (csr_op_out),
        .mem_wr_req_out       (mem_wr_req_out),
        .alu_opcode_out       (alu_opcode_out),
        .load_size_out        (load_size_out),
        .load_unsigned_out    (load_unsigned_out),
        .alu_src_out          (alu_src_out),
        .iadder_src_out       (iadder_src_out),
        .csr_wr_en_out        (csr_wr_en_out),
        .rf_wr_en_out         (rf_wr_en_out),
        .illegal_instr_out    (illegal_instr_out),
        .misaligned_load_out  (misaligned_load_out),
        .misaligned_store_out (misaligned_store_out),
        .is_load_out          (is_load_out),
        .is_store_out         (is_store_out)
    );

    initial begin
        // Initialize Inputs
        trap_taken_in        = 1'b0;
        funct7_5_in          = 1'b0;
        opcode_in            = 7'b0;
        funct3_in            = 3'b0;
        iadder_out_1_to_0_in = 2'b00;

        #10;

        // 1. Test R-Type ADD (opcode 0110011, funct3=000, funct7_5=0)
        $display("\n--- Test 1: R-Type ADD ---");
        opcode_in   = 7'b0110011;
        funct3_in   = 3'b000;
        funct7_5_in = 1'b0;
        #10;

        // 2. Test R-Type SUB (opcode 0110011, funct3=000, funct7_5=1)
        $display("--- Test 2: R-Type SUB ---");
        funct7_5_in = 1'b1;
        #10;

        // 3. Test I-Type ADDI (opcode 0010011, funct3=000, funct7_5=1)
        $display("--- Test 3: I-Type ADDI ---");
        opcode_in   = 7'b0010011;
        funct7_5_in = 1'b1; // Bit 3 of alu_opcode should stay 0 for ADDI
        #10;

        // 4. Test Load Aligned LW (opcode 0000011, funct3=010, addr=00)
        $display("--- Test 4: Aligned LW ---");
        opcode_in            = 7'b0000011;
        funct3_in            = 3'b010;
        iadder_out_1_to_0_in = 2'b00;
        #10;

        // 5. Test Load Misaligned LW (opcode 0000011, funct3=010, addr=10)
        $display("--- Test 5: Misaligned LW ---");
        iadder_out_1_to_0_in = 2'b10;
        #10;

        // 6. Test Store Aligned SW (opcode 0100011, funct3=010, addr=00)
        $display("--- Test 6: Aligned SW ---");
        opcode_in            = 7'b0100011;
        funct3_in            = 3'b010;
        iadder_out_1_to_0_in = 2'b00;
        #10;

        // 7. Test Store Trap Taken (SW with trap)
        $display("--- Test 7: Store with Trap ---");
        trap_taken_in = 1'b1;
        #10;
        trap_taken_in = 1'b0;

        // 8. Test Control / Branch BEQ (opcode 1100011)
        $display("--- Test 8: Branch BEQ ---");
        opcode_in = 7'b1100011;
        funct3_in = 3'b000;
        #10;

        // 9. Test U-Type LUI (opcode 0110111)
        $display("--- Test 9: LUI ---");
        opcode_in = 7'b0110111;
        #10;

        // 10. Test System / CSR Read-Write CSRRW (opcode 1110011, funct3=001)
        $display("--- Test 10: CSRRW ---");
        opcode_in = 7'b1110011;
        funct3_in = 3'b001;
        #10;

        // 11. Test Illegal Instruction
        $display("--- Test 11: Illegal Instruction ---");
        opcode_in = 7'b1111111;
        #10;

        $display("\nSimulation Completed Successfully.");
        $finish;
    end

    // Monitor key output signals
    initial begin
        $monitor("Time=%0tn | OP=%b | F3=%b | ALU_OP=%b | RF_WR=%b | CSR_WR=%b | MEM_WR=%b | ILL_INS=%b | MIS_LD=%b | MIS_ST=%b",
                 $time, opcode_in, funct3_in, alu_opcode_out, rf_wr_en_out, csr_wr_en_out, mem_wr_req_out, illegal_instr_out, misaligned_load_out, misaligned_store_out);
    end

endmodule