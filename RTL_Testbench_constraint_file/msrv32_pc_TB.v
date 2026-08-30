`timescale 1ns / 1ps

module pc_TB;

    // Inputs
    reg rst_in;
    reg [1:0] pc_src_in;
    reg [31:0] pc_in;
    reg [31:0] epc_in;
    reg [31:0] trap_address_in;
    reg branch_taken_in;
    reg [31:1] iadder_in;
    reg ahb_ready_in;

    // Outputs
    wire [31:0] iadder_out;
    wire [31:0] pc_plus_4_out;
    wire misaligned_instr_logic_out;
    wire [31:0] pc_mux_out;

    // Instantiate the module
    msrv32_pc uut (
        .rst_in(rst_in),
        .pc_src_in(pc_src_in),
        .pc_in(pc_in),
        .epc_in(epc_in),
        .trap_address_in(trap_address_in),
        .branch_taken_in(branch_taken_in),
        .iadder_in(iadder_in),
        .ahb_ready_in(ahb_ready_in),
        .iadder_out(iadder_out),
        .pc_plus_4_out(pc_plus_4_out),
        .misaligned_instr_logic_out(misaligned_instr_logic_out),
        .pc_mux_out(pc_mux_out)
    );

    initial begin
        // Test 1: Reset state
        $display("TEST 1: Reset State");
        rst_in = 1'b0;
        pc_src_in = 2'b00;
        pc_in = 32'h00000000;
        epc_in = 32'h00000000;
        trap_address_in = 32'h00000000;
        branch_taken_in = 1'b0;
        iadder_in = 31'h00000000;
        ahb_ready_in = 1'b1;
        #10;
        $display("iadder_out = %h, pc_mux_out = %h\n", iadder_out, pc_mux_out);

        // Test 2: PC+4 (no branch)
        $display("TEST 2: PC+4 (No Branch)");
        pc_src_in = 2'b11;
        pc_in = 32'h00000200;
        branch_taken_in = 1'b0;
        #10;
        $display("pc_plus_4_out = %h, pc_mux_out = %h\n", pc_plus_4_out, pc_mux_out);

        // Test 3: Branch taken
        $display("TEST 3: Branch Taken");
        branch_taken_in = 1'b1;
        iadder_in = 31'h00000150;
        #10;
        $display("pc_mux_out = %h, misaligned = %b\n", pc_mux_out, misaligned_instr_logic_out);

        // Test 4: EPC selection
        $display("TEST 4: EPC Selection");
        pc_src_in = 2'b01;
        epc_in = 32'h00000100;
        #10;
        $display("pc_mux_out = %h\n", pc_mux_out);

        // Test 5: Trap address selection
        $display("TEST 5: Trap Address Selection");
        pc_src_in = 2'b10;
        trap_address_in = 32'h00000050;
        #10;
        $display("pc_mux_out = %h\n", pc_mux_out);

        // Test 6: AHB not ready
        $display("TEST 6: AHB Not Ready");
        ahb_ready_in = 1'b0;
        pc_src_in = 2'b11;
        pc_in = 32'h00000204;
        #10;
        $display("iadder_out = %h\n", iadder_out);

        $finish;
    end

endmodule
