`timescale 1ns / 1ps

module load_unit1_TB;

    // Testbench Inputs
    reg        ahb_resp_in;
    reg [31:0] ms_riscv32_mp_dmdata_in;
    reg [1:0]  iadder_out_1_to_0_in;
    reg        load_unsigned_in;
    reg [1:0]  load_size_in;
    reg        clk;

    // Testbench Output
    wire [31:0] lu_output_out;

    // Instantiate Unit Under Test (UUT)
    load_unit1 uut (
        .ahb_resp_in            (ahb_resp_in),
        .clk                    (clk),
        .ms_riscv32_mp_dmdata_in(ms_riscv32_mp_dmdata_in),
        .iadder_out_1_to_0_in   (iadder_out_1_to_0_in),
        .load_unsigned_in       (load_unsigned_in),
        .load_size_in           (load_size_in),
        .lu_output_out          (lu_output_out)
    );

    // Clock Generation: 100 MHz (10ns Period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk                    = 0;
        ahb_resp_in            = 1'b0;
        ms_riscv32_mp_dmdata_in= 32'h80A5_FE82;
        iadder_out_1_to_0_in   = 2'b00;
        load_unsigned_in       = 1'b0;
        load_size_in           = 2'b00;

        #10;

        // 1. Signed Byte Load (LB) - Offset 00 (Byte 0x82 -> Negative, Sign Extended)
        @(posedge clk);
        load_size_in         <= 2'b00;
        load_unsigned_in     <= 1'b0;
        iadder_out_1_to_0_in <= 2'b00;

        // 2. Unsigned Byte Load (LBU) - Offset 00 (Byte 0x82 -> Zero Extended)
        @(posedge clk);
        load_unsigned_in     <= 1'b1;

        // 3. Signed Byte Load (LB) - Offset 01 (Byte 0xFE -> Sign Extended)
        @(posedge clk);
        load_unsigned_in     <= 1'b0;
        iadder_out_1_to_0_in <= 2'b01;

        // 4. Signed Half-Word Load (LH) - Offset 0 (Half 0xFE82 -> Sign Extended)
        @(posedge clk);
        load_size_in         <= 2'b01;
        iadder_out_1_to_0_in <= 2'b00;

        // 5. Unsigned Half-Word Load (LHU) - Offset 2 (Half 0x80A5 -> Zero Extended)
        @(posedge clk);
        load_unsigned_in     <= 1'b1;
        iadder_out_1_to_0_in <= 2'b10;

        // 6. Word Load (LW)
        @(posedge clk);
        load_size_in         <= 2'b10;

        #20;
        $finish;
    end

    // Monitor Output Dynamics
    initial begin
        $monitor("Time=%0tn | SIZE=%b | UNSIGNED=%b | OFFSET=%b | MEM_DATA=%h | LU_OUT=%h",
                 $time, load_size_in, load_unsigned_in, iadder_out_1_to_0_in, ms_riscv32_mp_dmdata_in, lu_output_out);
    end

endmodule
