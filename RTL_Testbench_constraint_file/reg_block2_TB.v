`timescale 1ns / 1ps
   
module reg_block2_TB;

    // Testbench Inputs
    reg        clk;
    reg        rst;
    reg  [4:0]  rd_addr_in;
    reg  [11:0] csr_addr_in;
    reg  [31:0] rs1_in;
    reg  [31:0] rs2_in;
    reg  [31:0] pc_in;
    reg  [31:0] pc_plus_4_in;
    reg         branch_taken_in;
    reg  [31:0] iadder_in;
    reg  [3:0]  alu_opcode_in;
    reg  [1:0]  load_size_in;
    reg         load_unsigned_in;
    reg         alu_src_in;
    reg         csr_wr_en_in;
    reg         rf_wr_en_in;
    reg  [2:0]  wb_mux_sel_in;
    reg  [2:0]  csr_op_in;
    reg  [31:0] imm_in;

    // Testbench Outputs
    wire [4:0]  rd_addr_reg_out;
    wire [11:0] csr_addr_reg_out;
    wire [31:0] rs1_reg_out;
    wire [31:0] rs2_reg_out;
    wire [31:0] pc_reg_out;
    wire [31:0] pc_plus_4_reg_out;
    wire [31:0] iadder_out_reg_out;
    wire [3:0]  alu_opcode_reg_out;
    wire [1:0]  load_size_reg_out;
    wire        load_unsigned_reg_out;
    wire        alu_src_reg_out;
    wire        csr_wr_en_reg_out;
    wire        rf_wr_en_reg_out;
    wire [2:0]  wb_mux_sel_reg_out;
    wire [2:0]  csr_op_reg_out;
    wire [31:0] imm_reg_out;

    // Instantiate Unit Under Test (UUT)
    reg_block2 uut (
        .ms_riscv32_mp_clk_in  (clk),
        .ms_riscv32_mp_rst_in  (rst),
        .rd_addr_in            (rd_addr_in),
        .csr_addr_in           (csr_addr_in),
        .rs1_in                (rs1_in),
        .rs2_in                (rs2_in),
        .pc_in                 (pc_in),
        .pc_plus_4_in          (pc_plus_4_in),
        .branch_taken_in       (branch_taken_in),
        .iadder_in             (iadder_in),
        .alu_opcode_in         (alu_opcode_in),
        .load_size_in          (load_size_in),
        .load_unsigned_in      (load_unsigned_in),
        .alu_src_in            (alu_src_in),
        .csr_wr_en_in          (csr_wr_en_in),
        .rf_wr_en_in           (rf_wr_en_in),
        .wb_mux_sel_in         (wb_mux_sel_in),
        .csr_op_in             (csr_op_in),
        .imm_in                (imm_in),
        .rd_addr_reg_out       (rd_addr_reg_out),
        .csr_addr_reg_out      (csr_addr_reg_out),
        .rs1_reg_out           (rs1_reg_out),
        .rs2_reg_out           (rs2_reg_out),
        .pc_reg_out            (pc_reg_out),
        .pc_plus_4_reg_out     (pc_plus_4_reg_out),
        .iadder_out_reg_out    (iadder_out_reg_out),
        .alu_opcode_reg_out    (alu_opcode_reg_out),
        .load_size_reg_out     (load_size_reg_out),
        .load_unsigned_reg_out (load_unsigned_reg_out),
        .alu_src_reg_out       (alu_src_reg_out),
        .csr_wr_en_reg_out     (csr_wr_en_reg_out),
        .rf_wr_en_reg_out      (rf_wr_en_reg_out),
        .wb_mux_sel_reg_out    (wb_mux_sel_reg_out),
        .csr_op_reg_out        (csr_op_reg_out),
        .imm_reg_out           (imm_reg_out)
    );

    // Clock Generation: 100 MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk             = 0;
        rst             = 1;
        rd_addr_in      = 5'd0;
        csr_addr_in     = 12'h0;
        rs1_in          = 32'h0;
        rs2_in          = 32'h0;
        pc_in           = 32'h0;
        pc_plus_4_in    = 32'h0;
        branch_taken_in = 1'b0;
        iadder_in       = 32'h0;
        alu_opcode_in   = 4'b0;
        load_size_in    = 2'b0;
        load_unsigned_in= 1'b0;
        alu_src_in      = 1'b0;
        csr_wr_en_in    = 1'b0;
        rf_wr_en_in     = 1'b0;
        wb_mux_sel_in   = 3'b0;
        csr_op_in       = 3'b0;
        imm_in          = 32'h0;

        // 1. Asynchronous/Synchronous Reset Test
        #15;
        rst = 0;
        #10;

        // 2. Normal Pipeline Latch Test
        @(posedge clk);
        rd_addr_in       <= 5'd15;
        csr_addr_in      <= 12'h300;
        rs1_in           <= 32'hAAAA_BBBB;
        rs2_in           <= 32'hCCCC_DDDD;
        pc_in            <= 32'h0000_1000;
        pc_plus_4_in     <= 32'h0000_1004;
        branch_taken_in  <= 1'b0;
        iadder_in        <= 32'h0000_1005; // Note LSB = 1
        alu_opcode_in    <= 4'b0010;
        load_size_in     <= 2'b10;
        load_unsigned_in <= 1'b1;
        alu_src_in       <= 1'b1;
        csr_wr_en_in     <= 1'b1;
        rf_wr_en_in      <= 1'b1;
        wb_mux_sel_in    <= 3'b010;
        csr_op_in        <= 3'b001;
        imm_in           <= 32'h0000_00FF;

        // 3. Branch Taken LSB Masking Test
        @(posedge clk);
        // Verify register contents updated on cycle edge
        branch_taken_in  <= 1'b1;           // Set branch taken
        iadder_in        <= 32'h0000_2005;  // LSB is 1, but must be forced to 0

        @(posedge clk);
        branch_taken_in  <= 1'b0;

        #20;
        $finish;
    end

    // Waveform Monitor
    initial begin
        $monitor("Time=%0tn | RST=%b | PC_OUT=%h | IADDER_IN=%h | BR_TAKEN=%b | IADDER_OUT=%h | RF_WR=%b",
                 $time, rst, pc_reg_out, iadder_in, branch_taken_in, iadder_out_reg_out, rf_wr_en_reg_out);
    end

endmodule