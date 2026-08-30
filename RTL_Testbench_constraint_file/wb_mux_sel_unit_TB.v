`timescale 1ns / 1ps

module wb_mux_sel_unit_TB;

    // Testbench Inputs
    reg        alu_src_reg_in;
    reg [2:0]  wb_mux_sel_reg_in;
    reg [31:0] alu_result_in;
    reg [31:0] lu_output_in;
    reg [31:0] imm_reg_in;
    reg [31:0] iadder_out_reg_in;
    reg [31:0] csr_data_in;
    reg [31:0] pc_plus_4_reg_in;
    reg [31:0] rs2_reg_in;

    // Testbench Outputs
    wire [31:0] wb_mux_out;
    wire [31:0] alu_2nd_src_mux_out;

    // Instantiate Unit Under Test (UUT)
    wb_mux_sel_unit uut (
        .alu_src_reg_in     (alu_src_reg_in),
        .wb_mux_sel_reg_in  (wb_mux_sel_reg_in),
        .alu_result_in      (alu_result_in),
        .lu_output_in       (lu_output_in),
        .imm_reg_in         (imm_reg_in),
        .iadder_out_reg_in  (iadder_out_reg_in),
        .csr_data_in        (csr_data_in),
        .pc_plus_4_reg_in   (pc_plus_4_reg_in),
        .rs2_reg_in         (rs2_reg_in),
        .wb_mux_out         (wb_mux_out),
        .alu_2nd_src_mux_out(alu_2nd_src_mux_out)
    );

    initial begin
        // Initialize Test Inputs with distinct pattern values
        alu_src_reg_in    = 1'b0;
        wb_mux_sel_reg_in = 3'b000;
        alu_result_in     = 32'h1111_1111;
        lu_output_in      = 32'h2222_2222;
        imm_reg_in        = 32'h3333_3333;
        iadder_out_reg_in = 32'h4444_4444;
        csr_data_in       = 32'h5555_5555;
        pc_plus_4_reg_in  = 32'h6666_6666;
        rs2_reg_in        = 32'h7777_7777;

        #10;

        // -------------------------------------------------------------
        // Test 1: ALU 2nd Source MUX Selection
        // -------------------------------------------------------------
        $display("--- Test 1: ALU 2nd Source MUX ---");
        alu_src_reg_in = 1'b0; #10; // Selects imm_reg_in (32'h3333_3333)
        alu_src_reg_in = 1'b1; #10; // Selects rs2_reg_in (32'h7777_7777)

        // -------------------------------------------------------------
        // Test 2: Write-Back MUX Selection (wb_mux_sel_reg_in)
        // -------------------------------------------------------------
        $display("--- Test 2: Write-Back MUX ---");
        wb_mux_sel_reg_in = 3'b000; #10; // 000: WB_ALU        -> 32'h1111_1111
        wb_mux_sel_reg_in = 3'b001; #10; // 001: WB_LU         -> 32'h2222_2222
        wb_mux_sel_reg_in = 3'b010; #10; // 010: WB_IMM        -> 32'h3333_3333
        wb_mux_sel_reg_in = 3'b011; #10; // 011: WB_IADDER_OUT -> 32'h4444_4444
        wb_mux_sel_reg_in = 3'b100; #10; // 100: WB_CSR        -> 32'h5555_5555
        wb_mux_sel_reg_in = 3'b101; #10; // 101: WB_PC_PLUS    -> 32'h6666_6666
        wb_mux_sel_reg_in = 3'b110; #10; // Default Case      -> 32'h1111_1111

        $display("\nSimulation Completed.");
        $finish;
    end

    // Monitor Output Dynamics
    initial begin
        $monitor("Time=%0tn | ALU_SRC=%b | WB_SEL=%b | ALU_2ND_OUT=%h | WB_MUX_OUT=%h",
                 $time, alu_src_reg_in, wb_mux_sel_reg_in, alu_2nd_src_mux_out, wb_mux_out);
    end

endmodule