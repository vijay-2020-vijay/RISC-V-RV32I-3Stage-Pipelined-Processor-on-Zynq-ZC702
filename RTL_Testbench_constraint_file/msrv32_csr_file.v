`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Module Name: msrv32_csr_file

//Description: Control and status register.

//Dependencies: csr_data_mux_unit.v,
//		mcause_reg.v,
//		misa_and_pre_data.v,
//		mtval_reg.v,
//		data_wr_mux_unit.v,
//		mepc_and_mscratch_reg.v,
//		mtvec_reg.v,
//		machine_counter_setup.v,
//		mie_reg.v,
//		machine_counter.v,
//		mip_reg.v,
//		mstatus_reg.v

`timescale 1ns / 1ps

module msrv32_csr_file(input        clk_in,rst_in,wr_en_in,
		       input [11:0] csr_addr_in,
		       input [2:0 ] csr_op_in,
		       input [31:0] imm_reg2_in,
		       input [31:0] csr_data_in,
		       input [31:0] pc_in,iadder_in,
		       input	    e_irq_in,s_irq_in,t_irq_in,i_or_e_in,set_cause_in,set_epc_in,instret_inc_in,mie_clear_in,mie_set_in,
		       input [3:0 ] cause_in,
		      // input [63:0] real_time_in,
		       input misaligned_exception_in,
		       output [31:0] csr_data_out,
		       output  mie_out,
		       output [31:0] epc_out,trap_address_out,
		       output meie_out,mtie_out,msie_out,meip_out,mtip_out,msip_out

		
);

////////////////////////////////////////////////////////////
   wire  [63:0] real_time_in;
   assign real_time_in=64'd0;
 ////////////////////////////////////////////////////////////  
   wire [4:0] csr_uimm_in;
   assign csr_uimm_in = imm_reg2_in[4:0];
   // Machine trap setup
   wire [31:0] mstatus; // machine status register
   wire [31:0] misa; // machine ISA register
   wire [31:0] mie_reg; // machine interrupt enable register
   wire [31:0] mtvec;
   wire [1:0 ] mxl; // machine XLEN
   wire [25:0] mextensions; // ISA extensions
   wire  [1:0 ] mtvec_mode; // machine trap mode
   wire  [29:0] mtvec_base; // machine trap base address
   wire        mpie; // mach. prior interrupt enable

   // Machine trap handling
   wire  [31:0] mscratch; // machine scratch register
   wire [31:0] mepc; // machine exception program counter
   wire [31:0] mtval; // machine trap value register
   wire [31:0] mcause; // machine trap cause register
   wire [31:0] mip_reg; // machine interrupt pending register
   wire        int_or_exc; // interrupt or exception signal
   wire [3:0 ] cause; // interrupt cause
   wire  [26:0] cause_rem; // remaining bits of mcause register 

   // Machine counters
   wire [63:0] mcycle;
   wire [63:0] mtime;
   wire [63:0] minstret;

   // Machine counters setup
   wire [31:0] mcountinhibit;
   wire  mcountinhibit_cy;
   wire  mcountinhibit_ir;

   // CSR operation control
   
   //     ----------------------------------------------------------------------------

   wire [31:0] data_wr;
   wire [31:0] pre_data;

   //Data write Mux Unit
   data_wr_mux_unit DRMU (.csr_op_1_0_in(csr_op_in[1:0]),
			  .csr_data_out_in(csr_data_out),
			  .pre_data_in(pre_data),
			  .data_wr_out(data_wr)
			 );

   //CSR Data Mux Unit
   csr_data_mux_unit CDMU (.csr_addr_in(csr_addr_in),
			   .mcycle_in(mcycle),
			   .mtime_in(mtime),
			   .minstret_in(minstret),
			   .mscratch_in(mscratch),
			   .mip_reg_in(mip_reg),
			   .mtval_in(mtval),
			   .mcause_in(mcause),
			   .mepc_in(mepc),
			   .mtvec_in(mtvec),
			   .mstatus_in(mstatus),
			   .misa_in(misa),
			   .mie_reg_in(mie_reg),
			   .mcountinhibit_in(mcountinhibit),
			   .csr_data_out(csr_data_out)
			);


   //Mstatus Register
   mstatus_reg MS (.clk_in(clk_in),
		   .rst_in(rst_in),
		   .wr_en_in(wr_en_in),
		   .data_wr_3_in(data_wr[3]),
		   .data_wr_7_in(data_wr[7]),
		   .mie_clear_in(mie_clear_in),
		   .mie_set_in(mie_set_in),
		   .csr_addr_in(csr_addr_in),
		   .mstatus_out(mstatus),
		   .mie_out(mie_out)
		  );
   //MISA and Pre Data
   misa_and_pre_data MPD (.csr_op_2_in(csr_op_in[2]),
			  .csr_uimm_in(csr_uimm_in),
			  .csr_data_in(csr_data_in),
			  .misa_out(misa),
			  .pre_data_out(pre_data)
			 );

   //MIE Register
   mie_reg MIE_REG (.clk_in(clk_in),
		    .rst_in(rst_in),
		    .wr_en_in(wr_en_in),
		    .data_wr_3_in(data_wr[3]),
		    .data_wr_7_in(data_wr[7]),
		    .data_wr_11_in(data_wr[11]),
		    .csr_addr_in(csr_addr_in),
		    .meie_out(meie_out),
		    .mtie_out(mtie_out),
		    .msie_out(msie_out),
		    .mie_reg_out(mie_reg)
		   );



   //MTVEC Register
   mtvec_reg MTVEC_REG (.clk_in(clk_in),
			.rst_in(rst_in),
			.wr_en_in(wr_en_in),
			.int_or_exc_in(int_or_exc),
			.data_wr_in(data_wr),
			.csr_addr_in(csr_addr_in),
			.cause_in(cause),
			.mtvec_out(mtvec),
			.trap_address_out(trap_address_out)
			);


   //MEPC and Mscratch Register
   mepc_and_mscratch_reg MM_REG (.clk_in(clk_in),
				 .rst_in(rst_in),
				 .wr_en_in(wr_en_in),
				 .set_epc_in(set_epc_in),
				 .pc_in(pc_in),
				 .data_wr_in(data_wr),
				 .csr_addr_in(csr_addr_in),
				 .mscratch_out(mscratch),
				 .mepc_out(mepc),
				 .epc_out(epc_out)
				);


   //MCAUSE Register
   mcause_reg MCAUSE_REG (.clk_in(clk_in),
			  .rst_in(rst_in),
			  .wr_en_in(wr_en_in),
			  .set_cause_in(set_cause_in),
			  .i_or_e_in(i_or_e_in),
			  .cause_in(cause_in),
			  .data_wr_in(data_wr),
			  .csr_addr_in(csr_addr_in),
			  .mcause_out(mcause),
			  .cause_out(cause),
			  .int_or_exc_out(int_or_exc)
			);







   //MIP Register
   mip_reg MIP_REG (.clk_in(clk_in),
		   .rst_in(rst_in),
		   .e_irq_in(e_irq_in),
		   .t_irq_in(e_irq_in),
		   .s_irq_in(s_irq_in),
		   .meip_out(meip_out),
		   .mtip_out(mtip_out),
		   .msip_out(msip_out),
		   .mip_reg_out(mip_reg)
		  ); 




   //MTVAL Register
   mtval_reg MTVAL_REG (.clk_in(clk_in),
			.rst_in(rst_in),
			.wr_en_in(wr_en_in),
			.set_cause_in(set_cause_in),
			.misaligned_exception_in(misaligned_exception_in),
			.iadder_in(iadder_in),
			.data_wr_in(data_wr),
			.csr_addr_in(csr_addr_in),
			.mtval_out(mtval)
			);




   //Machine Counter Setup
   machine_counter_setup MCS (.clk_in(clk_in),
			      .rst_in(rst_in),
			      .wr_en_in(wr_en_in),
			      .data_wr_2_in(data_wr[2]),
			      .data_wr_0_in(data_wr[0]),
			      .csr_addr_in(csr_addr_in),
			      .mcountinhibit_cy_out(mcountinhibit_cy),
			      .mcountinhibit_ir_out(mcountinhibit_ir),
			      .mcountinhibit_out(mcountinhibit)
			     );


   //Machine Counter
   machine_counter MC (.clk_in(clk_in),
		       .rst_in(rst_in),
		       .wr_en_in(wr_en_in),
		       .mcountinhibit_cy_in(mcountinhibit_cy),
		       .mcountinhibit_ir_in(mcountinhibit_ir),
		       .instret_inc_in(instret_inc_in),
		       .csr_addr_in(csr_addr_in),
		       .data_wr_in(data_wr),
		       .real_time_in(real_time_in),
		       .mcycle_out(mcycle),
		       .minstret_out(minstret),
		       .mtime_out(mtime)
		      );

      
endmodule


/////////////////////////////////////// mstatus_reg////////////////////////////////////

module mstatus_reg( input             clk_in,rst_in,wr_en_in,data_wr_3_in,data_wr_7_in,mie_clear_in,mie_set_in,
                    input      [11:0] csr_addr_in,
                    output     [31:0] mstatus_out,
                    output reg        mie_out
);

   parameter  MSTATUS = 12'h300;
   reg mpie_out;
   assign mstatus_out = {19'b0, 2'b11, 3'b0, mpie_out, 3'b0 , mie_out, 3'b0};
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mie_out <= 1'b0;
         mpie_out <= 1'b1;
      end
      else if(csr_addr_in == MSTATUS && wr_en_in)
      begin
         mie_out <= data_wr_3_in;
         mpie_out <= data_wr_7_in;
      end
      else if(mie_clear_in == 1'b1)
      begin
         mpie_out <= mie_out;
         mie_out <= 1'b0;
      end
      else if(mie_set_in == 1'b1)
      begin
         mie_out <= mpie_out;
         mpie_out <= 1'b1;
      end
   end
endmodule

//////////////////////// mtval_reg//////////////////////////////////////////

module mtval_reg( input             clk_in,rst_in,wr_en_in,set_cause_in,misaligned_exception_in,
                  input      [31:0] iadder_in,data_wr_in,
                  input      [11:0] csr_addr_in,
                  output reg [31:0] mtval_out
);

   parameter MTVAL = 12'h343;

   always @(posedge clk_in)
   begin
      if(rst_in)
         mtval_out <= 32'b0;
      else if(set_cause_in)
      begin
         if(misaligned_exception_in)
             mtval_out <= iadder_in;
         else
             mtval_out <= 32'b0;
      end
      else if(csr_addr_in == MTVAL && wr_en_in)
         mtval_out <= data_wr_in;
   end


endmodule

/////////////////////////////// mtvec-reg/////////////////////////////////////////

module mtvec_reg( input        clk_in,rst_in,wr_en_in,int_or_exc_in,
                  input  [31:0] data_wr_in,
                  input  [11:0] csr_addr_in,
                  input  [3:0 ] cause_in,
                  output [31:0] mtvec_out,trap_address_out
);

   parameter  MTVEC_BASE_RESET  =    30'b00000000_00000000_00000010_000000;
   parameter  MTVEC_MODE_RESET  =    2'b00;
   parameter  MTVEC             =    12'h305;

   reg  [1:0 ] mtvec_mode; // machine trap mode
   reg  [29:0] mtvec_base; // machine trap base address

   assign mtvec_out = {mtvec_base, mtvec_mode};
   wire [31:0] trap_mux_out;
   wire [31:0] vec_mux_out;
   wire [31:0] base_offset;
   assign base_offset = cause_in << 2;
   assign trap_mux_out = int_or_exc_in ? vec_mux_out : {mtvec_base, 2'b00};
   assign vec_mux_out = mtvec_out[0] ? {mtvec_base, 2'b00} + base_offset : {mtvec_base, 2'b00};
   assign trap_address_out = trap_mux_out;
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mtvec_mode <= MTVEC_MODE_RESET;
         mtvec_base <= MTVEC_BASE_RESET;
      end
      else if(csr_addr_in == MTVEC && wr_en_in)
      begin
         mtvec_mode <= data_wr_in[1:0];
         mtvec_base <= data_wr_in[31:2];
      end
   end
endmodule

////////////////////////// csr_data_mux_unit//////////////////////////////////////////////

module csr_data_mux_unit ( input      [11:0] csr_addr_in,
			   input      [63:0] mcycle_in,mtime_in,minstret_in,
			   input      [31:0] mscratch_in,mip_reg_in,mtval_in,mcause_in,mepc_in,mtvec_in,mstatus_in,misa_in,mie_reg_in,mcountinhibit_in,
			   output reg [31:0] csr_data_out
);

   // CSR ADDRESSES ----------------------------
   
   // Performance Counters
   parameter CYCLE     =         12'hC00;
   parameter TIME      =         12'hC01;
   parameter INSTRET   =         12'hC02;
   parameter CYCLEH    =         12'hC80;
   parameter TIMEH     =         12'hC81;
   parameter INSTRETH  =         12'hC82;
   
   // Machine Trap Setup
   parameter MSTATUS   =         12'h300;
   parameter MISA      =         12'h301;
   parameter MIE       =         12'h304;
   parameter MTVEC     =         12'h305;
   
   // Machine Trap Handling
   parameter MSCRATCH  =         12'h340;
   parameter MEPC      =         12'h341;
   parameter MCAUSE    =         12'h342;
   parameter MTVAL     =         12'h343;
   parameter MIP       =         12'h344;  
   // Machine Counter / Timers
   parameter MCYCLE    =         12'hB00;
   parameter MINSTRET  =         12'hB02;
   parameter MCYCLEH   =         12'hB80;
   parameter MINSTRETH =         12'hB82;
   
   // Machine Counter Setup
   parameter MCOUNTINHIBIT =   12'h320;
   
   always @*
   begin
      case(csr_addr_in)
         CYCLE:         csr_data_out = mcycle_in[31:0];
         CYCLEH:        csr_data_out = mcycle_in[63:32];
         TIME:          csr_data_out = mtime_in[31:0];
         TIMEH:         csr_data_out = mtime_in[63:32];
         INSTRET:       csr_data_out = minstret_in[31:0];
         INSTRETH:      csr_data_out = minstret_in[63:32];
         MSTATUS:       csr_data_out = mstatus_in;
         MISA:          csr_data_out = misa_in;
         MIE:           csr_data_out = mie_reg_in;
         MTVEC:         csr_data_out = mtvec_in;
         MSCRATCH:      csr_data_out = mscratch_in;
         MEPC:          csr_data_out = mepc_in;
         MCAUSE:        csr_data_out = mcause_in;
         MTVAL:         csr_data_out = mtval_in;
         MIP:           csr_data_out = mip_reg_in;
         MCYCLE:        csr_data_out = mcycle_in[31:0];
         MCYCLEH:       csr_data_out = mcycle_in[63:32];
         MINSTRET:      csr_data_out = minstret_in[31:0];
         MINSTRETH:     csr_data_out = minstret_in[63:32];
         MCOUNTINHIBIT: csr_data_out = mcountinhibit_in;
         default:        csr_data_out = 32'b0;
      endcase
    end


endmodule

///////////////////////// data_wr_mux_unit ////////////////////////////////////////

module data_wr_mux_unit ( input      [1:0] csr_op_1_0_in,
                          input      [31:0] csr_data_out_in,pre_data_in,
                          output reg [31:0] data_wr_out
);

   parameter CSR_NOP = 2'b00;
   parameter CSR_RW  = 2'b01;
   parameter CSR_RS  = 2'b10;
   parameter CSR_RC  = 2'b11;

   always @*
   begin
      case(csr_op_1_0_in)
         CSR_RW: data_wr_out <= pre_data_in;
         CSR_RS: data_wr_out <= csr_data_out_in | pre_data_in;
         CSR_RC: data_wr_out <= csr_data_out_in & ~pre_data_in;
         CSR_NOP: data_wr_out <= csr_data_out_in;
      endcase
   end

endmodule

//////////////////////// machine_counter /////////////////////////////////////////

module machine_counter( input             clk_in,rst_in,wr_en_in,mcountinhibit_cy_in,mcountinhibit_ir_in,instret_inc_in,
			input      [11:0] csr_addr_in,
			input  	   [31:0] data_wr_in, 
  			input 	   [63:0] real_time_in, 
			output reg [63:0] mcycle_out,minstret_out,mtime_out
);

   parameter MCYCLE_RESET   =     32'h00000000;
   parameter TIME_RESET     =     32'h00000000;
   parameter MINSTRET_RESET =     32'h00000000;
   parameter MCYCLEH_RESET  =     32'h00000000;
   parameter TIMEH_RESET    =     32'h00000000;
   parameter MINSTRETH_RESET=     32'h00000000;
   parameter MCYCLE         =     12'hB00;
   parameter MCYCLEH        =     12'hB80;
   parameter MINSTRET       =     12'hB02;
   parameter MINSTRETH      =     12'hB82;

   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mcycle_out <= {MCYCLEH_RESET, MCYCLE_RESET};
         minstret_out <= {MINSTRETH_RESET, MINSTRET_RESET};
         mtime_out <= {TIMEH_RESET, TIME_RESET};
      end
      else
      begin
         mtime_out <= real_time_in;

         if(csr_addr_in == MCYCLE && wr_en_in)
         begin
            if(mcountinhibit_cy_in == 1'b0) 
	       mcycle_out <= {mcycle_out[63:32], data_wr_in} + 1;
            else
	       mcycle_out <= {mcycle_out[63:32], data_wr_in};
         end
         else if(csr_addr_in == MCYCLEH && wr_en_in)
         begin
            if(mcountinhibit_cy_in == 1'b0) 
	       mcycle_out <= {data_wr_in, mcycle_out[31:0]} + 1;
            else 
	       mcycle_out <= {data_wr_in, mcycle_out[31:0]};
         end
         else
         begin
            if(mcountinhibit_cy_in == 1'b0) 
	       mcycle_out <= mcycle_out + 1;
            else 
	       mcycle_out <= mcycle_out;
         end
         if(csr_addr_in == MINSTRET && wr_en_in)
         begin
            if(mcountinhibit_ir_in == 1'b0) 
	       minstret_out <= {minstret_out[63:32], data_wr_in} + instret_inc_in;
            else 
	       minstret_out <= {minstret_out[63:32], data_wr_in};
         end
         else if(csr_addr_in == MINSTRETH && wr_en_in)
         begin
            if(mcountinhibit_ir_in == 1'b0) 
	       minstret_out <= {data_wr_in, minstret_out[31:0]} + instret_inc_in;
            else 
	       minstret_out <= {data_wr_in, minstret_out[31:0]};
         end
         else
         begin
            if(mcountinhibit_ir_in == 1'b0) 
	       minstret_out <= minstret_out + instret_inc_in;
            else 
	       minstret_out <= minstret_out;
         end

      end
   end
endmodule

//////////////////// machine_cpunter_setup ///////////////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RISC-V Machine Counter Setup Module
// Manages mcountinhibit CSR for suppressing cycle/instret counters
//////////////////////////////////////////////////////////////////////////////////
  
module machine_counter_setup (
    input         clk_in,
    input         rst_in,
    input         wr_en_in,
    input         data_wr_2_in,               // Bit 2: CY (Cycle counter inhibit)
    input         data_wr_0_in,               // Bit 0: IR (Instruction counter inhibit)
    input  [11:0] csr_addr_in,
    output reg    mcountinhibit_cy_out,
    output reg    mcountinhibit_ir_out,
    output [31:0] mcountinhibit_out
);

    parameter MCOUNTINHIBIT_CY_RESET = 1'b0;
    parameter MCOUNTINHIBIT_IR_RESET = 1'b0;
    parameter MCOUNTINHIBIT          = 12'h320;

    // Correctly drive the 32-bit output port (Bit 0: CY, Bit 2: IR per RISC-V Privileged Spec)
    assign mcountinhibit_out = {29'b0, mcountinhibit_ir_out, 1'b0, mcountinhibit_cy_out};

    always @(posedge clk_in) begin
        if (rst_in) begin
            mcountinhibit_cy_out <= MCOUNTINHIBIT_CY_RESET;
            mcountinhibit_ir_out <= MCOUNTINHIBIT_IR_RESET;
        end 
        else if ((csr_addr_in == MCOUNTINHIBIT) && wr_en_in) begin
            mcountinhibit_cy_out <= data_wr_2_in;
            mcountinhibit_ir_out <= data_wr_0_in;
        end
    end

endmodule





///////////////////// mcause_reg ////////////////////////////////////////////////

module mcause_reg( input             clk_in,rst_in,set_cause_in,i_or_e_in,wr_en_in,
                   input      [3:0 ] cause_in,
                   input      [31:0] data_wr_in,
                   input      [11:0] csr_addr_in,
                   output     [31:0] mcause_out,
                   output reg [3:0 ] cause_out,
                   output reg        int_or_exc_out
);

   parameter MCAUSE =  12'h342;

   reg  [26:0] cause_rem;   //remaining bits of mcause register

   assign mcause_out = {int_or_exc_out, cause_rem, cause_out};
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         cause_out <= 4'b0000;
         cause_rem <= 27'b0;
         int_or_exc_out <= 1'b0;
      end
      else if(set_cause_in)
      begin
         cause_out <= cause_in;
         cause_rem <= 27'b0;
         int_or_exc_out <= i_or_e_in;
      end
      else if(csr_addr_in == MCAUSE && wr_en_in)
      begin
         cause_out <= data_wr_in[3:0];
         cause_rem <= data_wr_in[30:4];
         int_or_exc_out <= data_wr_in[31];

      end
   end
endmodule

///////////////////////// mepc_and_mscratch_reg /////////////////////////////////

module mepc_and_mscratch_reg( input        clk_in,rst_in,wr_en_in,set_epc_in,
                              input      [31:0] pc_in,data_wr_in,
                              input      [11:0] csr_addr_in,
                              output reg [31:0] mscratch_out,mepc_out,
                              output     [31:0] epc_out
);

   parameter MSCRATCH_RESET =     32'h00000000;
   parameter MSCRATCH       =     12'h340;
   parameter MEPC_RESET     =     32'h00000000;
   parameter MEPC           =     12'h341;


   // MSCRATCH register
   always @(posedge clk_in)
   begin
      if(rst_in)
         mscratch_out <= MSCRATCH_RESET;
      else if(csr_addr_in == MSCRATCH && wr_en_in)
         mscratch_out <= data_wr_in;
   end

   // MEPC register
   assign epc_out = mepc_out;
   always @(posedge clk_in)
   begin
      if(rst_in)
         mepc_out <=MEPC_RESET;
      else if(set_epc_in)
         mepc_out <= pc_in;
      else if(csr_addr_in == MEPC && wr_en_in)
         mepc_out <= {data_wr_in[31:2], 2'b00};
   end
endmodule

////////////////////// mie_reg ////////////////////////////////////


module mie_reg( input         clk_in,rst_in,wr_en_in,data_wr_11_in,data_wr_7_in,data_wr_3_in,
                input  [11:0] csr_addr_in,
                output        meie_out,mtie_out,msie_out,
                output [31:0] mie_reg_out
);

   parameter MIE = 12'h304;


   reg meie,mtie,msie;

   assign mie_reg_out = {20'b0, meie, 3'b0, mtie, 3'b0, msie, 3'b0};
   assign meie_out = meie;
   assign mtie_out = mtie;
   assign msie_out = msie;
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         meie <= 1'b0;
         mtie <= 1'b0;
         msie <= 1'b0;
      end
      else if(csr_addr_in == MIE && wr_en_in)
      begin
         meie <= data_wr_11_in;
         mtie <= data_wr_7_in;
         msie <= data_wr_3_in;
      end
   end

endmodule

//////////////////// mip_reg ////////////////////////////////

module mip_reg(input         clk_in,rst_in,e_irq_in,t_irq_in,s_irq_in,
               output        meip_out,mtip_out,msip_out,
               output [31:0] mip_reg_out);

   reg meip,mtip,msip;   //Internal wires

   always@(posedge clk_in)
   begin
      if(rst_in)
      begin
         meip = 1'b0;
         mtip = 1'b0;
         msip = 1'b0;
      end
      else
      begin
         meip = e_irq_in;
         mtip = t_irq_in;
         msip = s_irq_in;
      end
   end
   assign meip_out = meip;
   assign mtip_out = mtip;
   assign msip_out = msip;

   assign mip_reg_out = {20'b0, meip, 3'b0, mtip, 3'b0, msip, 3'b0};
endmodule

//////////// misa_and_pre_data ////////////////////////////////////


module misa_and_pre_data( input         csr_op_2_in,
                          input  [4:0 ] csr_uimm_in,
                          input  [31:0] csr_data_in,
                          output [31:0] misa_out,pre_data_out
);

   wire [1:0 ] mxl; // machine XLEN
   wire [25:0] mextensions; // ISA extensions


   assign pre_data_out = csr_op_2_in == 1'b1 ? {27'b0, csr_uimm_in} : csr_data_in;

   assign mxl = 2'b01;
   assign mextensions = 26'b00000000000000000100000000;
   assign misa_out = {mxl, 4'b0, mextensions};

endmodule
