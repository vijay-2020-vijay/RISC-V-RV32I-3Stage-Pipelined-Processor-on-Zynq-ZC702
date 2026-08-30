`timescale 1ns / 1ps  

module machine_control_TB;

    // Clock and Reset
    reg clk;
    reg rst;

    // External Interrupt Requests
    reg eirq_in;
    reg tirq_in;
    reg sirq_in;

    // Exception Inputs
    reg illegal_instr_in;
    reg misaligned_load_in;
    reg misaligned_store_in;
    reg misaligned_instr_in;

    // Instruction Fields
    reg [4:0] opcode_6_to_2_in;
    reg [2:0] funct3_in;
    reg [6:0] funct7_in;
    reg [4:0] rs1_addr_in;
    reg [4:0] rs2_addr_in;
    reg [4:0] rd_addr_in;

    // CSR State Inputs
    reg meie_in;
    reg mtie_in;
    reg msie_in;
    reg meip_in;
    reg mtip_in;
    reg msip_in;

    // Outputs
    wire       i_or_e_out;
    wire [3:0] cause_out;
    wire       instret_inc_out;
    wire       mie_clear_out;
    wire       mie_set_out;
    wire       misaligned_expectetion_out;
    wire       set_epc_out;
    wire       set_cause_out;
    wire       flush_out;
    wire       trap_taken_out;
    wire [1:0] pc_src_out;

    // Instantiate Unit Under Test (UUT)
    machine_control uut (
        .ms_riscv32_mp_clk_in       (clk),
        .ms_riscv32_mp_rst_in       (rst),
        .ms_riscv32_mp_eirq_in      (eirq_in),
        .ms_riscv32_mp_tirq_in      (tirq_in),
        .ms_riscv32_mp_sirq_in      (sirq_in),
        .illegal_instr_in           (illegal_instr_in),
        .misaligned_load_in         (misaligned_load_in),
        .misaligned_store_in        (misaligned_store_in),
        .misaligned_instr_in        (misaligned_instr_in),
        .opcode_6_to_2_in           (opcode_6_to_2_in),
        .funct3_in                  (funct3_in),
        .funct7_in                  (funct7_in),
        .rs1_addr_in                (rs1_addr_in),
        .rs2_addr_in                (rs2_addr_in),
        .rd_addr_in                 (rd_addr_in),
        .i_or_e_out                 (i_or_e_out),
        .cause_out                  (cause_out),
        .instret_inc_out            (instret_inc_out),
        .mie_clear_out              (mie_clear_out),
        .mie_set_out                (mie_set_out),
        .misaligned_expectetion_out (misaligned_expectetion_out),
        .set_epc_out                (set_epc_out),
        .set_cause_out              (set_cause_out),
        .flush_out                  (flush_out),
        .trap_taken_out             (trap_taken_out),
        .pc_src_out                 (pc_src_out),
        .meie_in                    (meie_in),
        .mtie_in                    (mtie_in),
        .msie_in                    (msie_in),
        .meip_in                    (meip_in),
        .mtip_in                    (mtip_in),
        .msip_in                    (msip_in)
    );

    // Clock Generation (100 MHz -> 10ns Period)
    always #5 clk = ~clk;

    // Task to reset all inputs to default values
    task reset_inputs;
        begin
            eirq_in             = 1'b0;
            tirq_in             = 1'b0;
            sirq_in             = 1'b0;
            illegal_instr_in    = 1'b0;
            misaligned_load_in  = 1'b0;
            misaligned_store_in = 1'b0;
            misaligned_instr_in = 1'b0;
            opcode_6_to_2_in    = 5'b00000;
            funct3_in           = 3'b000;
            funct7_in           = 7'b0000000;
            rs1_addr_in         = 5'd0;
            rs2_addr_in         = 5'd0;
            rd_addr_in          = 5'd0;
            meie_in             = 1'b1;
            mtie_in             = 1'b1;
            msie_in             = 1'b1;
            meip_in             = 1'b0;
            mtip_in             = 1'b0;
            msip_in             = 1'b0;
        end
    endtask

    initial begin
        // Initialize Signals
        clk = 0;
        rst = 1;
        reset_inputs();

        // Hold Reset
        #20;
        rst = 0;
        #10;

        // 1. Normal Operation Mode
        $display("\n--- Test 1: Normal Operating State ---");
        opcode_6_to_2_in = 5'b01100; // Normal R-Type Opcode
        #10;

        // 2. External Interrupt Trigger (EIRQ)
        $display("--- Test 2: External Interrupt (EIRQ) ---");
        eirq_in = 1'b1;
        #10; 
        eirq_in = 1'b0;
        #10;

        // 3. Trap Return (MRET Instruction)
        $display("--- Test 3: Trap Return (MRET) ---");
        opcode_6_to_2_in = 5'b11100;   // System Opcode
        funct7_in        = 7'b0011000; // MRET funct7
        rs2_addr_in      = 5'd2;       // MRET rs2
        rs1_addr_in      = 5'd0;
        funct3_in        = 3'b000;
        #10;
        reset_inputs();
        #10;

        // 4. Illegal Instruction Exception
        $display("--- Test 4: Illegal Instruction Exception ---");
        illegal_instr_in = 1'b1;
        #10;
        illegal_instr_in = 1'b0;
        #10;

        // 5. ECALL Instruction Exception
        $display("--- Test 5: ECALL Instruction ---");
        opcode_6_to_2_in = 5'b11100;
        funct7_in        = 7'b0000000;
        rs2_addr_in      = 5'd0;
        rs1_addr_in      = 5'd0;
        rd_addr_in       = 5'd0;
        funct3_in        = 3'b000;
        #10;
        reset_inputs();
        #10;

        // 6. Misaligned Store Access Exception
        $display("--- Test 6: Misaligned Store ---");
        misaligned_store_in = 1'b1;
        #10;
        misaligned_store_in = 1'b0;
        #10;

        $display("\nSimulation Complete.");
        $finish;
    end

    // Monitor Output Dynamics
    initial begin
        $monitor("Time=%0tn | State=%b | TRAP_TAKEN=%b | FLUSH=%b | PC_SRC=%b | CAUSE=%b | I_OR_E=%b | SET_EPC=%b",
                 $time, uut.curr_state, trap_taken_out, flush_out, pc_src_out, cause_out, i_or_e_out, set_epc_out);
    end

endmodule