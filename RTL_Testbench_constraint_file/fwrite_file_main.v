`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
////////////////////// fwrite_file (Annotated Signal Sources) //////////////////////

module fwrite_file_main (

    input        clk,               // System clock
    input        reset,             // System reset
    input        rd_en,             // Write enable signal after decode (decoder -> rf_wr_en_out1)
    input  [4:0] rd_add,            // Destination register address (decoder -> rd_add)
    input [31:0] pc,                // Current instruction PC (PC mux -> pc_out1 / pc_in)
    input        is_load,           // Load instruction signal (decoder -> is_load)
    input        is_store,          // Store instruction signal (decoder -> is_store)
    input        load_unsignned_in, // Unsigned load flag (load unit -> load_unsignned_in)
    input  [1:0] load_size_in,      // Load data size selection [1:0] (load unit -> load_size_in)
    input [31:0] mem_radd,          // Memory read address (write-back mux -> iadder_out_reg_out1)
    input  [2:0] funct3_in1,         // Store type funct3 bits [1:0] (store unit -> funct3_in)
    input [31:0] mem_wadd,          // Memory write address (store unit / execution stage -> mem_wadd)
    input [31:0] mem_wdata,         // Memory write data payload (store unit / RF -> mem_wdata)
    input        wrd_en1,           // Writeback register write enable (WB stage -> wrd_en1)
    input  [4:0] wrd_add1,          // Writeback register destination address (WB stage -> wrd_add1)
    input [31:0] wrd_data1          // Writeback data payload (WB stage -> wrd_data1)///
);
wire [1:0] funct3_in;
reg [31:0]  wrd_data11 ;
///////////////////////////////////////////////////
reg [31:0]count_x;
///////////////////////////////////////////////////////////////////////////////////
/// this section of block bring a special treatment ///for lbu instraction////////
///////////////////////////////////////////////////////////////////////////////////
always @(*) begin
    if(load_size_in == 2'd0 && load_unsignned_in==1'b1 && mem_wadd[1:0]==2'd0) begin
       //wrd_data11 ={ 24'd0, wrd_data1[7:0] };
     wrd_data11=wrd_data1;
    end
    else begin
       wrd_data11=wrd_data1;
    end
end
///////////////////////////////////////////////////////////////////////////////////////////


assign funct3_in=funct3_in1[1:0];
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

    // ------------------ Reg Status Write Registers (Simulation Only) ------------------ //
    reg        reg_rd_en;    always @(posedge clk) reg_rd_en   <= rd_en;
    reg  [4:0] reg_rd_add;   always @(posedge clk) reg_rd_add  <= rd_add;
    /////////////////////////////////////////////////////////////////////////////////////////
    reg [31:0] reg_pc;       always @(posedge clk) begin
                                     if(reset)begin
                                          count_x<=32'd2;
                                     end
                                     else begin
                                          reg_pc <= pc;
                                          count_x<=count_x+1;
                                    end    
                             end        
    /////////////////////////////////////////////////////////////////////////////////////////
    reg  [2:0] reg_mem_ren;  always @(posedge clk) reg_mem_ren <= mem_ren;
    reg  [2:0] reg_mem_wen;  always @(posedge clk) reg_mem_wen <= mem_wen;

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

    // ------------------ File Logging Initialization ------------------ //
    integer write_file;
    initial begin
        write_file = $fopen("D:/verilog22/project_1RISCV_3stage_RV32I/Result_status.txt", "w");
        // write_file = $fopen("C:/Xilinx/reg_status_hw_3stage_32kb.txt", "w");
        $fdisplay(write_file, "pc        (rd rd  wdata   ) (wen wadd     wdata    | radd    )");
        $fclose(write_file);
    end

    wire [4:0] wire_rd_add = reg_rd_add[4:0];
    wire       vrd_en      = reg_rd_en & (wire_rd_add != 5'd0);

    // RISC-V ABI Register Name Decoding
    wire [23:0] reg_name = (wire_rd_add == 5'd01) ? " ra" : (wire_rd_add == 5'd02) ? " sp" : (wire_rd_add == 5'd03) ? " gp" : (wire_rd_add == 5'd04) ? " tp"
                         : (wire_rd_add == 5'd05) ? " t0" : (wire_rd_add == 5'd06) ? " t1" : (wire_rd_add == 5'd07) ? " t2" : (wire_rd_add == 5'd08) ? " s0"
                         : (wire_rd_add == 5'd09) ? " s1" : (wire_rd_add == 5'd10) ? " a0" : (wire_rd_add == 5'd11) ? " a1" : (wire_rd_add == 5'd12) ? " a2"
                         : (wire_rd_add == 5'd13) ? " a3" : (wire_rd_add == 5'd14) ? " a4" : (wire_rd_add == 5'd15) ? " a5" : (wire_rd_add == 5'd16) ? " a6"
                         : (wire_rd_add == 5'd17) ? " a7" : (wire_rd_add == 5'd18) ? " s2" : (wire_rd_add == 5'd19) ? " s3" : (wire_rd_add == 5'd20) ? " s4"
                         : (wire_rd_add == 5'd21) ? " s5" : (wire_rd_add == 5'd22) ? " s6" : (wire_rd_add == 5'd23) ? " s7" : (wire_rd_add == 5'd24) ? " s8"
                         : (wire_rd_add == 5'd25) ? " s9" : (wire_rd_add == 5'd26) ? "s10" : (wire_rd_add == 5'd27) ? "s11" : (wire_rd_add == 5'd28) ? " t3"
                         : (wire_rd_add == 5'd29) ? " t4" : (wire_rd_add == 5'd30) ? " t5" : (wire_rd_add == 5'd31) ? " t6" :                      "  0";

    // ------------------ Runtime File Append ------------------ //
    always @(posedge clk) begin
        if (vrd_en) begin
            write_file = $fopen("D:/verilog22/project_1RISCV_3stage_RV32I/Result_status.txt", "a");
            
            $fdisplay(write_file, "%h (%02d %s %h) (%b %h %h | %h)", reg_pc, wire_rd_add, reg_name, wrd_data11, 3'd0, 32'd0, 32'd0, reg_mem_radd);
            
            $fclose(write_file);
        end else if (reg_mem_wen != 3'b000) begin
            write_file = $fopen("D:/verilog22/project_1RISCV_3stage_RV32I/Result_status.txt", "a");
            $fdisplay(write_file, "%h (%02d %s %h) (%b %h %h | %h)", reg_pc, 0, "000", 32'd0, reg_mem_wen, reg_mem_wadd, reg_mem_wdata, reg_mem_radd);
            $fclose(write_file);
        end
    end

endmodule







/*
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
// 167-bit Record Construction:
    // Bit Range       | Field Name       | Width
    // ----------------|------------------|-------
    // [167 : 136]     | reg_pc           | 32-bit
    // [135 : 131]     | wire_rd_add      |  5-bit
    // [130 :  99]     | wrd_data11       | 32-bit
    // [ 98 :  96]     | reg_mem_wen      |  3-bit
    // [ 95 :  64]     | reg_mem_wadd     | 32-bit
    // [ 63 :  32]     | reg_mem_wdata    | 32-bit
    // [ 31 :   0]     | reg_mem_radd     | 32-bit (total = 168 bits)

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
    input  [31:0] wrd_data1,          // Writeback data payload
    output  unused_sink_fr
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
    reg [2:0] reg_mem_wen; always @(posedge clk) reg_mem_wen <= mem_wen;

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

    wire [4:0] wire_rd_add = reg_rd_add[4:0];
    wire       vrd_en      = reg_rd_en & (wire_rd_add != 5'd0);

    // ------------------ BRAM Port A Control & Formatting ------------------ //
    reg [9:0]  bram_addr_a;
    reg         bram_we_a;
    reg [167:0] bram_din_a;

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
            bram_din_a = {reg_pc, wire_rd_add, wrd_data11, 3'b000, 32'd0, 32'd0, reg_mem_radd};
        end else if (reg_mem_wen != 3'b000) begin
            bram_we_a  = 1'b1;
            bram_din_a = {reg_pc, 5'd0, 32'd0, reg_mem_wen, reg_mem_wadd, reg_mem_wdata, reg_mem_radd};
        end else begin
            bram_we_a  = 1'b0;
            bram_din_a = 168'd0;
        end
    end

    // ------------------ Dual-Port BRAM Instantiation ------------------ //
    wire [167:0] douta_unused;
    wire [167:0] doutb_unused;

    blk_mem_gen_0 bram1 (
        // Port A (Used strictly for logged status writes)
        .clka  (clk),
        .ena   (1'b1),
        .wea   (bram_we_a),
        .addra (bram_addr_a),
        .dina  (bram_din_a),
        .douta (douta_unused),

        // Port B (Unused, tied off)
        .clkb  (clk),
        .enb   (1'b0),
        .web   (1'b0),
        .addrb (10'd0),
        .dinb  (168'd0),
        .doutb (doutb_unused)
    );


// ------------------ Unused Bits Sinking ------------------  t avoid the synthesis warning//
    // Collecting all unused input bits, registers, and BRAM outputs
    wire [377:0] unused_bit = {
        wrd_en1,           // 1 bit
        wrd_add1,          // 5 bits
        funct3_in1[2],     // 1 bit
        count_x,           // 32 bits
        reg_mem_ren,       // 3 bits
        douta_unused,      // 168 bits
        doutb_unused       // 168 bits -> Wait: total = 378 bits
    };

    assign unused_sink_fr = &unused_bit;

endmodule
*/