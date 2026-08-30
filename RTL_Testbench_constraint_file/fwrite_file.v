`timescale 1ns / 1ps     

///////////////////////////////////////////////////////////////////////////////////////////////////
////////Read this contains very carefully .you can understand more clean away////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////the objective of fwrite_file and fwrite_file-_main is same .to print the result .\
///for simmuletion purpose fwrite_file_main is ok , it would generate .text file where the all register
//and data memorey  status  of each instraction will be printed on the .text file/// this  module fwrite_file_main
// is not synthesisable ///
/// to make synthesisable we have used dualport Bram inside the fwrte_file , here eacch and every location of 
///Bram cntains 168bit ///like this fllowing away tt is stored in to the system///////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
// 172-bit Record Construction:
    // Bit Range       | Field Name       | Width
    // ----------------|------------------|-------
    // [171 : 140]     | reg_pc           | 32-bit
    // [139 : 132]     | wire_rd_add      |  8-bit
    // [131 : 100]     | wrd_data11       | 32-bit
    // [99  :  96]     | reg_mem_wen      | 4 bit
    // [95 :  64]     | reg_mem_wadd      | 32-bit
    // [63 :  32]     | reg_mem_wdata     | 32-bit
    // [ 31 :   0]     | reg_mem_radd     | 32-bit (total = 172 bits)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
module fwrite_file (
    input        clk,               // System clock
    input        reset,             // System reset
    input        rd_en,             // Write enable signal after decode
    input  [4:0] rd_add,            // Destination register address
    input [31:0] pc,                // Current instruction PC
    input        is_load,           // Load instruction signal
    input        is_store,          // Store instruction signal
    input        load_unsignned_in, // Unsigned load flag
    input  [1:0] load_size_in,      // Load data size selection [1:0]
    input [31:0] mem_radd,          // Memory read address
    input  [2:0] funct3_in1,        // Store type funct3 bits [1:0]
    input [31:0] mem_wadd,          // Memory write address
    input [31:0] mem_wdata,         // Memory write data payload
    input        wrd_en1,           // Writeback register write enable
    input  [4:0] wrd_add1,          // Writeback register destination address
    input  [31:0] wrd_data1,        // Writeback data payload
    output  unused_sink_fr,
    output  [139:0]result_status    // described at the above tale/////here we have taken only 171:32
    ////because certain limitetion of I/O pins in zynq_7000 ZC702 FPGA board///so its size should be 140 bit ok 
);

    // ------------------ Internal Wires & Registers ------------------ //
    wire [1:0] funct3_in;
    reg [31:0] wrd_data11;
    reg [31:0] count_x;

    // Special treatment block for lbu instruction
    always @(*) begin
        if (load_size_in == 2'd0 && load_unsignned_in == 1'b1 && mem_wadd[1:0] == 2'd0) begin
            wrd_data11 = wrd_data1;
        end else begin
            wrd_data11 = wrd_data1;
        end
    end

    assign funct3_in = funct3_in1[1:0];

    // ------------------ Memory Read Enable Derivation ------------------ //
    wire [2:0] mem_ren;
    assign mem_ren[0] = ((load_size_in == 2'b00) && (is_load == 1'b1)) ? 1'b1 : 1'b0; // Byte load
    assign mem_ren[1] = ((load_size_in == 2'b01) && (is_load == 1'b1)) ? 1'b1 : 1'b0; // Half-word load
    assign mem_ren[2] = (((load_size_in == 2'b10) || (load_size_in == 2'b11)) && (is_load == 1'b1)) ? 1'b1 : 1'b0; // Word load

    // ------------------ Memory Write Enable Derivation ------------------ //
    wire [2:0] mem_wen;
    assign mem_wen[0] = ((funct3_in == 2'b00) && (is_store == 1'b1)) ? 1'b1 : 1'b0; // Byte store
    assign mem_wen[1] = ((funct3_in == 2'b01) && (is_store == 1'b1)) ? 1'b1 : 1'b0; // Half-word store
    assign mem_wen[2] = (((funct3_in == 2'b10) || (funct3_in == 2'b11)) && (is_store == 1'b1)) ? 1'b1 : 1'b0; // Word store

    // ------------------ Reg Status Write Registers ------------------ //
    reg       reg_rd_en;   always @(posedge clk) reg_rd_en   <= rd_en;
    reg [4:0] reg_rd_add;  always @(posedge clk) reg_rd_add  <= rd_add;

    reg [31:0] reg_pc;
    always @(posedge clk) begin
        if (reset) begin
            count_x <= 32'd2;
        end else begin
            reg_pc  <= pc;
            count_x <= count_x + 1'b1;
        end
    end

    reg [2:0] reg_mem_ren; always @(posedge clk) reg_mem_ren <= mem_ren;
    reg [3:0] reg_mem_wen; always @(posedge clk) reg_mem_wen <= {1'b0,mem_wen};

    reg [31:0] reg_mem_radd; 
    always @(posedge clk) begin
        if (mem_ren != 3'b000)
            reg_mem_radd <= mem_radd;
        else
            reg_mem_radd <= 32'd0;
    end

    reg [31:0] reg_mem_wadd; 
    always @(posedge clk) begin
        if (mem_wen != 3'b000)
            reg_mem_wadd <= mem_wadd;
        else
            reg_mem_wadd <= 32'd0;
    end

    reg [31:0] reg_mem_wdata; 
    always @(posedge clk) begin
        if (mem_wen[0]) begin
            case (mem_wadd[1:0])
                2'b00: reg_mem_wdata <= {24'd0, mem_wdata[7:0]};
                2'b01: reg_mem_wdata <= {24'd0, mem_wdata[15:8]};
                2'b10: reg_mem_wdata <= {24'd0, mem_wdata[23:16]};
                2'b11: reg_mem_wdata <= {24'd0, mem_wdata[31:24]};
            endcase
        end else if (mem_wen[1]) begin
            if (mem_wadd[1] == 1'b1)
                reg_mem_wdata <= {16'd0, mem_wdata[31:16]};
            else
                reg_mem_wdata <= {16'd0, mem_wdata[15:0]};
        end else if (mem_wen[2]) begin
            reg_mem_wdata <= mem_wdata;
        end else begin
            reg_mem_wdata <= 32'd0;
        end
    end

    wire [7:0] wire_rd_add = {3'd0,reg_rd_add[4:0]};
    wire       vrd_en      = reg_rd_en & (wire_rd_add != 8'd0);

    // ------------------ BRAM Port A Control & Formatting ------------------ //
    reg [9:0]  bram_addr_a;
    reg         bram_we_a;
    reg [171:0] bram_din_a;

    // Address Counter to log successive records sequentially into BRAM
    always @(posedge clk) begin
        if (reset) begin
            bram_addr_a <= 10'd0;
        end else if (bram_we_a) begin
            bram_addr_a <= bram_addr_a + 1'b1;
        end
    end

    // 168-bit Full Data Packing
    always @(*) begin
        if (vrd_en) begin
            bram_we_a  = 1'b1;
            bram_din_a = {reg_pc, wire_rd_add, wrd_data11, 4'b0000, 32'd0, 32'd0, reg_mem_radd};
        end else if (reg_mem_wen != 4'b0000) begin
            bram_we_a  = 1'b1;
            bram_din_a = {reg_pc, 8'd0, 32'd0, reg_mem_wen, reg_mem_wadd, reg_mem_wdata, reg_mem_radd};
        end else begin
            bram_we_a  = 1'b0;
            bram_din_a = 172'd0;
        end
    end

    // ------------------ Dual-Port BRAM Instantiation ------------------ //
    wire [171:0] douta_portA;
    wire [171:0] doutb_unused;

    blk_mem_gen_0 bram1 (
        // Port A (Used strictly for logged status writes)
        .clka  (clk),
        .ena   (1'b1),
        .wea   (bram_we_a),
        .addra (bram_addr_a),
        .dina  (bram_din_a),
        .douta (douta_portA),

        // Port B (Unused, tied off)
        .clkb  (clk),
        .enb   (1'b0),
        .web   (1'b0),
        .addrb (10'd0),
        .dinb  (172'd0),
        .doutb (doutb_unused)
    );


// ------------------ Unused Bits Sinking ------------------  t avoid the synthesis warning//
 // Collecting all unused input bits, registers, and BRAM outputs
    wire [245:0] unused_bit = {
        wrd_en1,           // 1 bit
        wrd_add1,          // 5 bits
        funct3_in1[2],     // 1 bit
        count_x,           // 32 bits
        reg_mem_ren,       // 3 bits
        doutb_unused,      // 172 bits -> Wait: total = 210 bits
        douta_portA[31:0]
    };

    assign unused_sink_fr = &unused_bit;
    assign result_status  = douta_portA[171:32];

endmodule