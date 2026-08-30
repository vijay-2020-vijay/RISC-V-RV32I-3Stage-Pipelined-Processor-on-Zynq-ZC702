`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Machine Control Module (msrv32_machine_control)
// Handles FSM State Transitions, Interrupts, Exceptions, and Trap Returns
//////////////////////////////////////////////////////////////////////////////////

module machine_control (
    // Clock and Reset
    input         ms_riscv32_mp_clk_in,       // Clock input
    input         ms_riscv32_mp_rst_in,       // Reset input

    // Interrupt Requests
    input         ms_riscv32_mp_eirq_in,      // External Interrupt Request
    input         ms_riscv32_mp_tirq_in,      // Timer Interrupt Request
    input         ms_riscv32_mp_sirq_in,      // Software Interrupt Request

    // Exception Inputs from Decoder
    input         illegal_instr_in,           // Invalid/unimplemented instruction
    input         misaligned_load_in,         // Misaligned Load address
    input         misaligned_store_in,        // Misaligned Store address
    input         misaligned_instr_in,        // Misaligned Instruction Fetch address

    // Instruction Decoding Inputs
    input  [6:0]  opcode_in,                  // Opcode field (bits [6:0])
    input  [2:0]  funct3_in,                  // Funct3 field
    input  [6:0]  funct7_in,                  // Funct7 field
    input  [4:0]  rs1_addr_in,                // RS1 Address
    input  [4:0]  rs2_addr_in,                // RS2 Address
    input  [4:0]  rd_addr_in,                 // RD Address

    // Output Signals
    output reg    i_or_e_out,                 // 1: Interrupt, 0: Exception (mcause MSB)
    output reg [3:0] cause_out,               // Exception/Interrupt Cause Code
    output reg    instret_inc_out,            // Instruction Retired Counter Enable
    output reg    mie_clear_out,              // Clears MIE bit in mstatus
    output reg    mie_set_out,                // Sets MIE bit in mstatus (MRET)
    output reg    misaligned_expectetion_out, // Misaligned Access Exception Flag
    output reg    set_epc_out,                // Updates MEPC CSR
    output reg    set_cause_out,              // Updates MCAUSE CSR
    output reg    flush_out,                  // Pipeline Flush Signal
    output reg    trap_taken_out,             // Trap Taken Indicator
    output reg [1:0] pc_src_out,              // PC Source MUX Control Signal

    // CSR State Inputs
    input         meie_in,                    // M-mode External Interrupt Enable
    input         mtie_in,                    // M-mode Timer Interrupt Enable
    input         msie_in,                    // M-mode Software Interrupt Enable
    input         meip_in,                    // M-mode External Interrupt Pending
    input         mtip_in,                    // M-mode Timer Interrupt Pending
    input         msip_in                     // M-mode Software Interrupt Pending
);

    // Opcode Extraction [6:2]
    wire [4:0] opcode_6_to_2_in = opcode_in[6:2];

    // Control Logic Wires
    wire is_system       = (opcode_6_to_2_in == 5'b11100);
    wire funct3_zero     = (funct3_in == 3'b000);
    wire funct7_zero     = (funct7_in == 7'd0);
    wire funct7_mret     = (funct7_in == 7'b0011000);
    wire rs1_addr_zero   = (rs1_addr_in == 5'd0);
    wire rs2_addr_zero   = (rs2_addr_in == 5'd0);
    wire rd_zero         = (rd_addr_in == 5'd0);
    wire rs2_addr_mret   = (rs2_addr_in == 5'd2);
    wire rs2_addr_ebreak = (rs2_addr_in == 5'd1);

    // Interrupt Pending Logic
    wire eip = meie_in & (meip_in | ms_riscv32_mp_eirq_in);
    wire tip = mtie_in & (mtip_in | ms_riscv32_mp_tirq_in);
    wire sip = msie_in & (msip_in | ms_riscv32_mp_sirq_in);
    wire ip  = eip | sip | tip;

    // Exception Logic
    wire exception = illegal_instr_in | misaligned_instr_in | misaligned_load_in | misaligned_store_in;

    // Special Instructions Decoding
    wire mret   = is_system & funct7_mret & rs2_addr_mret & rs1_addr_zero & funct3_zero;
    wire ecall  = is_system & rs1_addr_zero & funct3_zero & rd_zero & funct7_zero & rs2_addr_zero;
    wire ebreak = is_system & rs1_addr_zero & funct3_zero & rd_zero & funct7_zero & rs2_addr_ebreak;

    wire mie_in = 1'b1;

    // Trap Detection Logic
    always @(*) begin
        if ((mie_in & ip) | (exception | ebreak))
            trap_taken_out = 1'b1;
        else
            trap_taken_out = 1'b0;
    end

    // FSM State Encoding
    parameter STATE_RESET       = 5'd0;
    parameter STATE_OPERATING   = 5'd1;
    parameter STATE_TRAP_TAKEN  = 5'd2;
    parameter STATE_TRAP_RETURN = 5'd3;
    parameter Ending_Program    = 5'd4;

    reg [4:0] curr_state, next_state;

    // FSM State Register Sequential Logic
    always @(posedge ms_riscv32_mp_clk_in) begin
        if (ms_riscv32_mp_rst_in)
            curr_state <= STATE_RESET;
        else
            curr_state <= next_state;
    end

    // FSM Next State Combinational Logic
    always @(*) begin
        case (curr_state)
            STATE_RESET: begin
                next_state = STATE_OPERATING;
            end

            STATE_OPERATING: begin
                if (trap_taken_out)
                    next_state = STATE_TRAP_TAKEN;
                else if (mret)
                    next_state = STATE_TRAP_RETURN;
                else if (ecall)
                    next_state = Ending_Program;
                else
                    next_state = STATE_OPERATING;
            end

            STATE_TRAP_TAKEN: begin
                next_state = STATE_OPERATING;
            end

            STATE_TRAP_RETURN: begin
                next_state = STATE_OPERATING;
            end

            Ending_Program: begin
                next_state = Ending_Program;
            end

            default: begin
                next_state = STATE_OPERATING;
            end
        endcase
    end

    // Misaligned Exception Registered Flag
    always @(posedge ms_riscv32_mp_clk_in) begin
        if (ms_riscv32_mp_rst_in)
            misaligned_expectetion_out <= 1'b0;
        else
            misaligned_expectetion_out <= misaligned_instr_in || misaligned_load_in || misaligned_store_in;
    end

    // Output Combinational Logic
    always @(*) begin
        // Default values to prevent latch creation across all branches
        pc_src_out      = 2'b00;
        instret_inc_out = 1'b0;
        flush_out       = 1'b0;
        set_epc_out     = 1'b0;
        set_cause_out   = 1'b0;
        mie_clear_out   = 1'b0;
        mie_set_out     = 1'b0;
        cause_out       = 4'b0000;
        i_or_e_out      = 1'b0;

        case (curr_state)
            STATE_RESET: begin
                pc_src_out      = 2'b00;
                instret_inc_out = 1'b0;
                flush_out       = 1'b1;
                set_epc_out     = 1'b0;
                set_cause_out   = 1'b0;
                mie_clear_out   = 1'b0;
                mie_set_out     = 1'b0;
                cause_out       = 4'b0000;
                i_or_e_out      = 1'b0;
            end

            STATE_OPERATING: begin
                pc_src_out      = 2'b11;
                flush_out       = 1'b0;
                instret_inc_out = 1'b1;
                set_epc_out     = 1'b0;
                set_cause_out   = 1'b0;
                mie_clear_out   = 1'b0;
                mie_set_out     = 1'b1;

                if (eip) begin
                    cause_out  = 4'b1011;
                    i_or_e_out = 1'b1;
                end else if (sip) begin
                    cause_out  = 4'b0011;
                    i_or_e_out = 1'b1;
                end else if (tip) begin
                    cause_out  = 4'b0111;
                    i_or_e_out = 1'b1;
                end else if (illegal_instr_in) begin
                    cause_out  = 4'b0010;
                    i_or_e_out = 1'b0;
                end else if (misaligned_instr_in) begin
                    cause_out  = 4'b0000;
                    i_or_e_out = 1'b0;
                end else if (ecall) begin
                    cause_out  = 4'b1011;
                    i_or_e_out = 1'b0;
                end else if (ebreak) begin
                    cause_out  = 4'b0011;
                    i_or_e_out = 1'b0;
                end else if (misaligned_store_in) begin
                    cause_out  = 4'b0110;
                    i_or_e_out = 1'b0;
                end else if (misaligned_load_in) begin
                    cause_out  = 4'b0100;
                    i_or_e_out = 1'b0;
                end
            end

            STATE_TRAP_TAKEN: begin
                pc_src_out      = 2'b10;
                instret_inc_out = 1'b0;
                flush_out       = 1'b1;
                set_epc_out     = 1'b1;
                set_cause_out   = 1'b1;
                mie_clear_out   = 1'b1;
                mie_set_out     = 1'b0;
            end

            STATE_TRAP_RETURN: begin
                pc_src_out      = 2'b01;
                flush_out       = 1'b1;
                instret_inc_out = 1'b0;
                set_epc_out     = 1'b0;
                set_cause_out   = 1'b0;
                mie_clear_out   = 1'b0;
                mie_set_out     = 1'b1;
            end

            Ending_Program: begin
                pc_src_out      = 2'b00;
                instret_inc_out = 1'b0;
                flush_out       = 1'b1;
                set_epc_out     = 1'b0;
                set_cause_out   = 1'b0;
                mie_clear_out   = 1'b0;
                mie_set_out     = 1'b0;
                cause_out       = 4'b0000;
                i_or_e_out      = 1'b0;
            end
        endcase
    end

endmodule