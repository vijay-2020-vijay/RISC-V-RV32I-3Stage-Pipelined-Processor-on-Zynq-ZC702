`timescale 1ns / 1ps
  
module msrv32_wr_en_generator_TB;

    // Testbench Inputs
    reg flush_in;
    reg rf_wr_en_reg_in;
    reg csr_wr_en_reg_in;

    // Testbench Outputs
    wire wr_en_integer_file_out;
    wire wr_en_csr_file_out;

    // Instantiate the Unit Under Test (UUT)
    msrv32_wr_en_generator uut (
        .flush_in               (flush_in),
        .rf_wr_en_reg_in        (rf_wr_en_reg_in),
        .csr_wr_en_reg_in       (csr_wr_en_reg_in),
        .wr_en_integer_file_out (wr_en_integer_file_out),
        .wr_en_csr_file_out     (wr_en_csr_file_out)
    );

    initial begin
        // 1. Initial State: Normal pass-through (flush = 0)
        flush_in         = 1'b0;
        rf_wr_en_reg_in  = 1'b1;
        csr_wr_en_reg_in = 1'b0;
        #10;

        // 2. Normal Operation: Both enables active (flush = 0)
        rf_wr_en_reg_in  = 1'b1;
        csr_wr_en_reg_in = 1'b1;
        #10;

        // 3. Pipeline Flush Asserted: Outputs must be forced to 0 regardless of inputs
        flush_in         = 1'b1;
        rf_wr_en_reg_in  = 1'b1;
        csr_wr_en_reg_in = 1'b1;
        #10;

        // 4. Flush active with zero inputs
        rf_wr_en_reg_in  = 1'b0;
        csr_wr_en_reg_in = 1'b0;
        #10;

        // 5. De-assert Flush: Normal operation resumes
        flush_in         = 1'b0;
        rf_wr_en_reg_in  = 1'b0;
        csr_wr_en_reg_in = 1'b1;
        #10;

        $finish;
    end

    // Monitor Output Dynamics
    initial begin
        $monitor("Time=%0tn | FLUSH=%b | RF_WR_IN=%b CSR_WR_IN=%b | INT_FILE_OUT=%b CSR_FILE_OUT=%b",
                 $time, flush_in, rf_wr_en_reg_in, csr_wr_en_reg_in, wr_en_integer_file_out, wr_en_csr_file_out);
    end

endmodule