`timescale 1ns / 1ps

module PL_DDR_BRAM (
    // System Signals
    input  wire        clk,
    input  wire        rst_n,

    // PS Control Inputs (from AXI GPIO / PS)
    input  wire        DDR_BRAM0_W,    // Step 1: Trigger DDR -> BRAM0 transfer phase
    input  wire        BRAM0_BRAM1_w,  // Step 2: Trigger PL processing (BRAM0 -> BRAM1)
    input  wire        BRAM1_DDR_W,    // Step 3: Trigger BRAM1 -> DDR transfer phase
    input  wire        BRAM1_DDR_W_com,
    input  wire        restar_process,

    // PL Status Outputs (to AXI GPIO / PS)
    output reg         trans_out,               // High during ANY active transmission phase
    output reg         DDR_BRAM0_trans_com_out,
    output reg         BRAM0_BRAM1_trans_com_out,
    output reg         comple_transaction_out,  // High when entire end-to-end workflow finishes
    output reg         transaction_finish_out,
    output wire        unused_out,

    // BRAM0 Port B Interface (Read Input Data)
    output reg [31:0]  bram0_addrb,
    output wire        bram0_clkb,
    output reg [31:0]  bram0_dinb,   // Unused (read-only)
    input  wire[31:0]  bram0_doutb,  // Data read from BRAM0
    output reg         bram0_enb,
    output reg         bram0_rstb,
    output reg [3:0]   bram0_web,    // Read-only (4'h0)

    // BRAM1 Port B Interface (Write Output Data)
    output reg [31:0]  bram1_addrb,
    output wire        bram1_clkb,
    output reg [31:0]  bram1_dinb,   // Data to write to BRAM1
    input  wire[31:0]  bram1_doutb,  // Unused (write-only)
    output reg         bram1_enb,
    output reg         bram1_rstb,
    output reg [3:0]   bram1_web     // Write byte enables (4'hF)
);

reg [2:0] state;
// Change this line from 256 to 512 (256 * 2)
localparam total_data = 10'd512;
localparam s0=3'd0; localparam s1=3'd1; localparam s2=3'd2;
localparam s3=3'd3; localparam s4=3'd4; localparam s5=3'd5;

reg [9:0] data_count;
assign bram0_clkb = clk;
assign bram1_clkb = clk;
assign unused_out = &bram1_doutb;  // Unused assignment wrapper

always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state                     <= s0; 
            trans_out                 <= 1'b0;  
            DDR_BRAM0_trans_com_out   <= 1'b0;
            BRAM0_BRAM1_trans_com_out <= 1'b0;
            comple_transaction_out    <= 1'b0;
            transaction_finish_out    <= 1'b0;
            
            bram0_addrb               <= 32'd0;
            bram0_dinb                <= 32'd0;
            bram0_enb                 <= 1'b0;
            bram0_rstb                <= 1'b0;
            bram0_web                 <= 4'h0;

            bram1_addrb               <= 32'd0;
            bram1_dinb                <= 32'd0;
            bram1_enb                 <= 1'b0;
            bram1_rstb                <= 1'b0;
            bram1_web                 <= 4'h0;

            data_count                <= 10'd0;
        end else begin
            case (state)
            s0: begin // Waiting for DDR -> BRAM0 transfer acknowledgment
               comple_transaction_out    <= 1'b0;
               DDR_BRAM0_trans_com_out   <= 1'b0;
               BRAM0_BRAM1_trans_com_out <= 1'b0;
               bram0_enb                 <= 1'b0;
               bram1_enb                 <= 1'b0;
               bram1_web                 <= 4'h0;
               
               if (DDR_BRAM0_W == 1'b1) begin  
                  trans_out               <= 1'b1;
                  DDR_BRAM0_trans_com_out <= 1'b0;
                  state                   <= s0;
               end
               else begin
                  trans_out               <= 1'b0;
                  DDR_BRAM0_trans_com_out <= 1'b1;
                  state                   <= s1;
               end   
            end     
            
            s1: begin // Ready for BRAM0 -> BRAM1 Processing
               if (BRAM0_BRAM1_w == 1'b1) begin
                  trans_out               <= 1'b1;
                  DDR_BRAM0_trans_com_out <= 1'b0;
                  bram0_enb  <= 1'b1;  bram0_web  <= 4'h0;  bram0_rstb <= 1'b0;   
                  bram0_dinb <= 32'd0;
                  bram1_enb  <= 1'b1;  bram1_web  <= 4'h0;  bram1_rstb <= 1'b0;  // Start disabled until pipeline catches up
                  bram1_dinb <= 32'd0;
                  data_count <= 10'd0;
                  bram0_addrb<= 32'h0000_0000;
                  bram1_addrb<= 32'h0000_0000;
                  state      <= s2; 
               end
               else begin
                  state      <= s1; 
               end
            end

            s2: begin // Pipelined 32-bit Processing (BRAM0 Port B -> BRAM1 Port B)
               if (data_count == 10'd0) begin
                   bram0_addrb <= 32'h0000_0000;
                   bram1_addrb <= 32'h0000_0000;
                   bram0_enb   <= 1'b1;
                   bram1_enb   <= 1'b1;
                   bram1_web   <= 4'h0; 
                   data_count  <= data_count + 1'b1;
                   trans_out   <= 1'b1;
               end
               else if (data_count <= total_data) begin
                   // Step address by 4 bytes for 32-bit asymmetric access width
                   bram0_addrb <= bram0_addrb + 32'h4;
                   
                   // Latch and compute processed data to BRAM1
                   bram1_dinb  <= bram0_doutb + 32'h5; 
                   bram1_web   <= 4'hF;               
                   
                   if (data_count > 1) begin
                       bram1_addrb <= bram1_addrb + 32'h4; 
                   end
                   
                   data_count <= data_count + 1'b1;
               end
               else begin
                   // Flush final pipeline register element
                   bram1_dinb  <= bram0_doutb + 32'h5;
                   bram1_web   <= 4'hF;
                   if (total_data > 1) begin
                       bram1_addrb <= bram1_addrb + 32'h4;
                   end
                   
                   bram1_web                 <= 4'h0; 
                   bram0_enb                 <= 1'b0; 
                   bram1_enb                 <= 1'b0;
                   trans_out                 <= 1'b0;
                   BRAM0_BRAM1_trans_com_out <= 1'b1;
                   data_count                <= 10'd0;
                   state                     <= s3;
               end
            end

            s3: begin // Waiting for CDMA Readback Trigger (BRAM1 -> DDR)
               if (BRAM1_DDR_W == 1'b1) begin
                  BRAM0_BRAM1_trans_com_out <= 1'b0;
                  trans_out                 <= 1'b0;
                  state                     <= s4;
               end
               else begin
                  state                     <= s3;
               end
            end
                 
            s4: begin // Final Completion & Reset Management
               if (BRAM1_DDR_W_com) begin
                  trans_out              <= 1'b0;
                  comple_transaction_out <= 1'b1;
                  transaction_finish_out <= 1'b1;
               end
               else if (restar_process == 1'b1) begin
                  comple_transaction_out <= 1'b0;
                  transaction_finish_out <= 1'b0;
                  state                  <= s0;
               end
               else begin
                  state                  <= s4;
               end
            end       
                     
            default: state <= s0;
            endcase
        end
    end

endmodule