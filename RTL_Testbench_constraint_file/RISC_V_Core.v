//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Sun Aug 30 23:13:57 2026
//Host        : DESKTOP-UR0PACQ running 64-bit major release  (build 9200)
//Command     : generate_target RISC_V_Core.bd
//Design      : RISC_V_Core
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "RISC_V_Core,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=RISC_V_Core,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=20,numReposBlks=20,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=20,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "RISC_V_Core.hwdef" *) 
module RISC_V_Core
   (mie_out_0,
    ms_riscv32_clk_0,
    ms_riscv32_mp_data_htrans_out_0,
    ms_riscv32_mp_dmwr_req_out_0,
    ms_riscv32_mp_eirq_in_0,
    ms_riscv32_mp_hready_in_0,
    ms_riscv32_mp_instr_hready_in_0,
    ms_riscv32_mp_sirq_in_0,
    ms_riscv32_mp_tirq_in_0,
    ms_riscv32_rst_0,
    result_status_0,
    unused_out1_0);
  output mie_out_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.MS_RISCV32_CLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.MS_RISCV32_CLK_0, ASSOCIATED_RESET ms_riscv32_rst_0, CLK_DOMAIN RISC_V_Core_ms_riscv32_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input ms_riscv32_clk_0;
  output [1:0]ms_riscv32_mp_data_htrans_out_0;
  output ms_riscv32_mp_dmwr_req_out_0;
  input ms_riscv32_mp_eirq_in_0;
  input ms_riscv32_mp_hready_in_0;
  input ms_riscv32_mp_instr_hready_in_0;
  input ms_riscv32_mp_sirq_in_0;
  input ms_riscv32_mp_tirq_in_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.MS_RISCV32_RST_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.MS_RISCV32_RST_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input ms_riscv32_rst_0;
  output [139:0]result_status_0;
  output unused_out1_0;

  wire [31:0]ALU_0_result_out;
  wire [31:0]D_cache_0_rdata;
  wire D_cache_0_unused_sink_Dc;
  wire [31:0]I_cache_0_rdata;
  wire I_cache_0_unused_sink_ic;
  wire branch_unit_0_branch_taken_out;
  wire branch_unit_0_unused_sink_br;
  wire fwrite_file_0_unused_sink_fr2;
  wire [31:0]imm_adder_0_iadder_imm_out;
  wire [31:0]imm_generator_0_imm_out;
  wire [11:0]instruction_mux_0_csr_addr_out;
  wire [2:0]instruction_mux_0_funct3_out;
  wire [6:0]instruction_mux_0_funct7_out;
  wire [31:7]instruction_mux_0_instr_out;
  wire [6:0]instruction_mux_0_opcode_out;
  wire [4:0]instruction_mux_0_rdaddr_out;
  wire [4:0]instruction_mux_0_rs1addr_out;
  wire [4:0]instruction_mux_0_rs2addr_out;
  wire [31:0]load_unit1_0_lu_output_out;
  wire load_unit1_0_unused_sink_lo;
  wire [3:0]machine_control_0_cause_out;
  wire machine_control_0_flush_out;
  wire machine_control_0_i_or_e_out;
  wire machine_control_0_instret_inc_out;
  wire machine_control_0_mie_clear_out;
  wire machine_control_0_mie_set_out;
  wire machine_control_0_misaligned_expectetion_out;
  wire [1:0]machine_control_0_pc_src_out;
  wire machine_control_0_set_cause_out;
  wire machine_control_0_set_epc_out;
  wire machine_control_0_trap_taken_out;
  wire mie_out_0;
  wire ms_riscv32_clk_0;
  wire [1:0]ms_riscv32_mp_data_htrans_out_0;
  wire ms_riscv32_mp_dmwr_req_out_0;
  wire ms_riscv32_mp_eirq_in_0;
  wire ms_riscv32_mp_hready_in_0;
  wire ms_riscv32_mp_instr_hready_in_0;
  wire ms_riscv32_mp_sirq_in_0;
  wire ms_riscv32_mp_tirq_in_0;
  wire ms_riscv32_rst_0;
  wire [31:0]msrv32_csr_file_0_csr_data_out;
  wire [31:0]msrv32_csr_file_0_epc_out;
  wire msrv32_csr_file_0_meie_out;
  wire msrv32_csr_file_0_meip_out;
  wire msrv32_csr_file_0_msie_out;
  wire msrv32_csr_file_0_msip_out;
  wire msrv32_csr_file_0_mtie_out;
  wire msrv32_csr_file_0_mtip_out;
  wire [31:0]msrv32_csr_file_0_trap_address_out;
  wire [3:0]msrv32_decoder_0_alu_opcode_out;
  wire msrv32_decoder_0_alu_src_out;
  wire [2:0]msrv32_decoder_0_csr_op_out;
  wire msrv32_decoder_0_csr_wr_en_out;
  wire msrv32_decoder_0_iadder_src_out;
  wire msrv32_decoder_0_illegal_instr_out;
  wire [2:0]msrv32_decoder_0_imm_type_out;
  wire msrv32_decoder_0_is_load_out;
  wire msrv32_decoder_0_is_store_out;
  wire [1:0]msrv32_decoder_0_load_size_out;
  wire msrv32_decoder_0_load_unsigned_out;
  wire msrv32_decoder_0_mem_wr_req_out;
  wire msrv32_decoder_0_misaligned_load_out;
  wire msrv32_decoder_0_misaligned_store_out;
  wire msrv32_decoder_0_rf_wr_en_out;
  wire msrv32_decoder_0_unused_sink_De;
  wire [2:0]msrv32_decoder_0_wb_mux_sel_out;
  wire [31:0]msrv32_integer_file_0_rs_1_out;
  wire [31:0]msrv32_integer_file_0_rs_2_out;
  wire msrv32_integer_file_0_unused_sink_in;
  wire [31:0]msrv32_pc_0_iadder_out;
  wire msrv32_pc_0_misaligned_instr_logic_out;
  wire [31:0]msrv32_pc_0_pc_mux_out;
  wire [31:0]msrv32_pc_0_pc_plus_4_out;
  wire msrv32_pc_0_unused_pc;
  wire msrv32_wr_en_generat_0_wr_en_csr_file_out;
  wire msrv32_wr_en_generat_0_wr_en_integer_file_out;
  wire [3:0]reg_block2_0_alu_opcode_reg_out;
  wire reg_block2_0_alu_src_reg_out;
  wire [11:0]reg_block2_0_csr_addr_reg_out;
  wire [2:0]reg_block2_0_csr_op_reg_out;
  wire reg_block2_0_csr_wr_en_reg_out;
  wire [31:0]reg_block2_0_imm_iadder_reg2_out;
  wire [31:0]reg_block2_0_imm_reg_out;
  wire [1:0]reg_block2_0_load_size_reg_out;
  wire reg_block2_0_load_unsigned_reg_out;
  wire [31:0]reg_block2_0_pc_plus_4_reg_out;
  wire [31:0]reg_block2_0_pc_reg_out;
  wire [4:0]reg_block2_0_rd_addr_reg_out;
  wire reg_block2_0_rf_wr_en_reg_out;
  wire [31:0]reg_block2_0_rs1_reg_out;
  wire [31:0]reg_block2_0_rs2_reg_out;
  wire [2:0]reg_block2_0_wb_mux_sel_reg_out;
  wire [31:0]reg_block_1_0_pc_out;
  wire [139:0]result_status_0;
  wire [31:0]store_unit_0_ms_riscv32_mp_dmaddr_out;
  wire [31:0]store_unit_0_ms_riscv32_mp_dmdata_out;
  wire [3:0]store_unit_0_ms_riscv32_mp_dmwr_mask_out;
  wire store_unit_0_unused_st;
  wire unused_out1_0;
  wire [31:0]wb_mux_sel_unit_0_alu_2nd_src_mux_out;
  wire [31:0]wb_mux_sel_unit_0_wb_mux_out;

  RISC_V_Core_ALU_0_0 ALU_0
       (.op_1_in(reg_block2_0_rs1_reg_out),
        .op_2_in(wb_mux_sel_unit_0_alu_2nd_src_mux_out),
        .opcode_in(reg_block2_0_alu_opcode_reg_out),
        .result_out(ALU_0_result_out));
  RISC_V_Core_D_cache_0_0 D_cache_0
       (.addr(store_unit_0_ms_riscv32_mp_dmaddr_out),
        .clk(ms_riscv32_clk_0),
        .rdata(D_cache_0_rdata),
        .reset(ms_riscv32_rst_0),
        .unused_sink_Dc(D_cache_0_unused_sink_Dc),
        .wdata(store_unit_0_ms_riscv32_mp_dmdata_out),
        .wen(store_unit_0_ms_riscv32_mp_dmwr_mask_out));
  RISC_V_Core_I_cache_0_0 I_cache_0
       (.clk(ms_riscv32_clk_0),
        .iadder_in(msrv32_pc_0_iadder_out),
        .rdata(I_cache_0_rdata),
        .reset(ms_riscv32_rst_0),
        .unused_sink_ic(I_cache_0_unused_sink_ic));
  RISC_V_Core_branch_unit_0_0 branch_unit_0
       (.branch_taken_out(branch_unit_0_branch_taken_out),
        .funct3_in(instruction_mux_0_funct3_out),
        .opcode_in(instruction_mux_0_opcode_out),
        .rs1_in(msrv32_integer_file_0_rs_1_out),
        .rs2_in(msrv32_integer_file_0_rs_2_out),
        .unused_sink_br(branch_unit_0_unused_sink_br));
  RISC_V_Core_fwrite_file_0_0 fwrite_file_0
       (.clk(ms_riscv32_clk_0),
        .funct3_in1(instruction_mux_0_funct3_out),
        .is_load(msrv32_decoder_0_is_load_out),
        .is_store(msrv32_decoder_0_is_store_out),
        .load_size_in(msrv32_decoder_0_load_size_out),
        .load_unsignned_in(msrv32_decoder_0_load_unsigned_out),
        .mem_radd(imm_adder_0_iadder_imm_out),
        .mem_wadd(imm_adder_0_iadder_imm_out),
        .mem_wdata(store_unit_0_ms_riscv32_mp_dmdata_out),
        .pc(reg_block_1_0_pc_out),
        .rd_add(instruction_mux_0_rdaddr_out),
        .rd_en(msrv32_decoder_0_rf_wr_en_out),
        .reset(ms_riscv32_rst_0),
        .result_status(result_status_0),
        .unused_sink_fr(fwrite_file_0_unused_sink_fr2),
        .wrd_add1(instruction_mux_0_rdaddr_out),
        .wrd_data1(wb_mux_sel_unit_0_wb_mux_out),
        .wrd_en1(msrv32_decoder_0_rf_wr_en_out));
  RISC_V_Core_imm_adder_0_0 imm_adder_0
       (.iadder_imm_out(imm_adder_0_iadder_imm_out),
        .iadder_src_in(msrv32_decoder_0_iadder_src_out),
        .imm_in(imm_generator_0_imm_out),
        .pc_in(reg_block_1_0_pc_out),
        .rs1_in(msrv32_integer_file_0_rs_1_out));
  RISC_V_Core_imm_generator_0_0 imm_generator_0
       (.imm_out(imm_generator_0_imm_out),
        .imm_type(msrv32_decoder_0_imm_type_out),
        .instr_in(instruction_mux_0_instr_out));
  RISC_V_Core_instruction_mux_0_0 instruction_mux_0
       (.csr_addr_out(instruction_mux_0_csr_addr_out),
        .flush_in(machine_control_0_flush_out),
        .funct3_out(instruction_mux_0_funct3_out),
        .funct7_out(instruction_mux_0_funct7_out),
        .instr_out(instruction_mux_0_instr_out),
        .ms_riscv32_mp_instr_in(I_cache_0_rdata),
        .opcode_out(instruction_mux_0_opcode_out),
        .rdaddr_out(instruction_mux_0_rdaddr_out),
        .rs1addr_out(instruction_mux_0_rs1addr_out),
        .rs2addr_out(instruction_mux_0_rs2addr_out));
  RISC_V_Core_load_unit1_0_0 load_unit1_0
       (.imm_iadder_in(reg_block2_0_imm_iadder_reg2_out),
        .load_size_in(reg_block2_0_load_size_reg_out),
        .load_unsigned_in(reg_block2_0_load_unsigned_reg_out),
        .lu_output_out(load_unit1_0_lu_output_out),
        .ms_riscv32_mp_dmdata_in(D_cache_0_rdata),
        .unused_sink_lo(load_unit1_0_unused_sink_lo));
  RISC_V_Core_machine_control_0_0 machine_control_0
       (.cause_out(machine_control_0_cause_out),
        .flush_out(machine_control_0_flush_out),
        .funct3_in(instruction_mux_0_funct3_out),
        .funct7_in(instruction_mux_0_funct7_out),
        .i_or_e_out(machine_control_0_i_or_e_out),
        .illegal_instr_in(msrv32_decoder_0_illegal_instr_out),
        .instret_inc_out(machine_control_0_instret_inc_out),
        .meie_in(msrv32_csr_file_0_meie_out),
        .meip_in(msrv32_csr_file_0_meip_out),
        .mie_clear_out(machine_control_0_mie_clear_out),
        .mie_set_out(machine_control_0_mie_set_out),
        .misaligned_expectetion_out(machine_control_0_misaligned_expectetion_out),
        .misaligned_instr_in(msrv32_pc_0_misaligned_instr_logic_out),
        .misaligned_load_in(msrv32_decoder_0_misaligned_load_out),
        .misaligned_store_in(msrv32_decoder_0_misaligned_store_out),
        .ms_riscv32_mp_clk_in(ms_riscv32_clk_0),
        .ms_riscv32_mp_eirq_in(ms_riscv32_mp_eirq_in_0),
        .ms_riscv32_mp_rst_in(ms_riscv32_rst_0),
        .ms_riscv32_mp_sirq_in(ms_riscv32_mp_sirq_in_0),
        .ms_riscv32_mp_tirq_in(ms_riscv32_mp_tirq_in_0),
        .msie_in(msrv32_csr_file_0_msie_out),
        .msip_in(msrv32_csr_file_0_msip_out),
        .mtie_in(msrv32_csr_file_0_mtie_out),
        .mtip_in(msrv32_csr_file_0_mtip_out),
        .opcode_in(instruction_mux_0_opcode_out),
        .pc_src_out(machine_control_0_pc_src_out),
        .rd_addr_in(instruction_mux_0_rdaddr_out),
        .rs1_addr_in(instruction_mux_0_rs1addr_out),
        .rs2_addr_in(instruction_mux_0_rs2addr_out),
        .set_cause_out(machine_control_0_set_cause_out),
        .set_epc_out(machine_control_0_set_epc_out),
        .trap_taken_out(machine_control_0_trap_taken_out));
  RISC_V_Core_msrv32_csr_file_0_0 msrv32_csr_file_0
       (.cause_in(machine_control_0_cause_out),
        .clk_in(ms_riscv32_clk_0),
        .csr_addr_in(reg_block2_0_csr_addr_reg_out),
        .csr_data_in(reg_block2_0_rs1_reg_out),
        .csr_data_out(msrv32_csr_file_0_csr_data_out),
        .csr_op_in(reg_block2_0_csr_op_reg_out),
        .e_irq_in(ms_riscv32_mp_eirq_in_0),
        .epc_out(msrv32_csr_file_0_epc_out),
        .i_or_e_in(machine_control_0_i_or_e_out),
        .iadder_in(reg_block2_0_imm_iadder_reg2_out),
        .imm_reg2_in(reg_block2_0_imm_reg_out),
        .instret_inc_in(machine_control_0_instret_inc_out),
        .meie_out(msrv32_csr_file_0_meie_out),
        .meip_out(msrv32_csr_file_0_meip_out),
        .mie_clear_in(machine_control_0_mie_clear_out),
        .mie_out(mie_out_0),
        .mie_set_in(machine_control_0_mie_set_out),
        .misaligned_exception_in(machine_control_0_misaligned_expectetion_out),
        .msie_out(msrv32_csr_file_0_msie_out),
        .msip_out(msrv32_csr_file_0_msip_out),
        .mtie_out(msrv32_csr_file_0_mtie_out),
        .mtip_out(msrv32_csr_file_0_mtip_out),
        .pc_in(reg_block2_0_pc_reg_out),
        .rst_in(ms_riscv32_rst_0),
        .s_irq_in(ms_riscv32_mp_tirq_in_0),
        .set_cause_in(machine_control_0_set_cause_out),
        .set_epc_in(machine_control_0_set_epc_out),
        .t_irq_in(ms_riscv32_mp_sirq_in_0),
        .trap_address_out(msrv32_csr_file_0_trap_address_out),
        .wr_en_in(msrv32_wr_en_generat_0_wr_en_csr_file_out));
  RISC_V_Core_msrv32_decoder_0_0 msrv32_decoder_0
       (.alu_opcode_out(msrv32_decoder_0_alu_opcode_out),
        .alu_src_out(msrv32_decoder_0_alu_src_out),
        .csr_op_out(msrv32_decoder_0_csr_op_out),
        .csr_wr_en_out(msrv32_decoder_0_csr_wr_en_out),
        .funct3_in(instruction_mux_0_funct3_out),
        .funct7_in(instruction_mux_0_funct7_out),
        .iadder_src_out(msrv32_decoder_0_iadder_src_out),
        .illegal_instr_out(msrv32_decoder_0_illegal_instr_out),
        .imm_iadder_in(imm_adder_0_iadder_imm_out),
        .imm_type_out(msrv32_decoder_0_imm_type_out),
        .is_load_out(msrv32_decoder_0_is_load_out),
        .is_store_out(msrv32_decoder_0_is_store_out),
        .load_size_out(msrv32_decoder_0_load_size_out),
        .load_unsigned_out(msrv32_decoder_0_load_unsigned_out),
        .mem_wr_req_out(msrv32_decoder_0_mem_wr_req_out),
        .misaligned_load_out(msrv32_decoder_0_misaligned_load_out),
        .misaligned_store_out(msrv32_decoder_0_misaligned_store_out),
        .opcode_in(instruction_mux_0_opcode_out),
        .rf_wr_en_out(msrv32_decoder_0_rf_wr_en_out),
        .trap_taken_in(machine_control_0_trap_taken_out),
        .unused_sink_De(msrv32_decoder_0_unused_sink_De),
        .wb_mux_sel_out(msrv32_decoder_0_wb_mux_sel_out));
  RISC_V_Core_msrv32_integer_file_0_0 msrv32_integer_file_0
       (.imm_iadder_reg2_in(reg_block2_0_imm_iadder_reg2_out),
        .load_size_reg2_in(reg_block2_0_load_size_reg_out),
        .load_unsigned_reg2_in(reg_block2_0_load_unsigned_reg_out),
        .ms_riscv32_mp_clk_in(ms_riscv32_clk_0),
        .ms_riscv32_mp_rst_in(ms_riscv32_rst_0),
        .rgb2_rd_addr_reg_out(reg_block2_0_rd_addr_reg_out),
        .rs_1_addr_in(instruction_mux_0_rs1addr_out),
        .rs_1_out(msrv32_integer_file_0_rs_1_out),
        .rs_2_addr_in(instruction_mux_0_rs2addr_out),
        .rs_2_out(msrv32_integer_file_0_rs_2_out),
        .unused_sink_in(msrv32_integer_file_0_unused_sink_in),
        .wb_mux_sel_rd_in(wb_mux_sel_unit_0_wb_mux_out),
        .wr_en_in(msrv32_wr_en_generat_0_wr_en_integer_file_out));
  RISC_V_Core_msrv32_pc_0_0 msrv32_pc_0
       (.branch_taken_in(branch_unit_0_branch_taken_out),
        .epc_in(msrv32_csr_file_0_epc_out),
        .iadder_imm_in(imm_adder_0_iadder_imm_out),
        .iadder_out(msrv32_pc_0_iadder_out),
        .misaligned_instr_logic_out(msrv32_pc_0_misaligned_instr_logic_out),
        .ms_riscv32_mp_hready_in(ms_riscv32_mp_hready_in_0),
        .pc_in(reg_block_1_0_pc_out),
        .pc_mux_out(msrv32_pc_0_pc_mux_out),
        .pc_plus_4_out(msrv32_pc_0_pc_plus_4_out),
        .pc_src_in(machine_control_0_pc_src_out),
        .rst_in(ms_riscv32_rst_0),
        .trap_address_in(msrv32_csr_file_0_trap_address_out),
        .unused_pc(msrv32_pc_0_unused_pc));
  RISC_V_Core_msrv32_wr_en_generat_0_0 msrv32_wr_en_generat_0
       (.csr_wr_en_reg_in(reg_block2_0_csr_wr_en_reg_out),
        .flush_in(machine_control_0_flush_out),
        .rf_wr_en_reg_in(reg_block2_0_rf_wr_en_reg_out),
        .wr_en_csr_file_out(msrv32_wr_en_generat_0_wr_en_csr_file_out),
        .wr_en_integer_file_out(msrv32_wr_en_generat_0_wr_en_integer_file_out));
  RISC_V_Core_reg_block2_0_0 reg_block2_0
       (.alu_opcode_in(msrv32_decoder_0_alu_opcode_out),
        .alu_opcode_reg_out(reg_block2_0_alu_opcode_reg_out),
        .alu_src_in(msrv32_decoder_0_alu_src_out),
        .alu_src_reg_out(reg_block2_0_alu_src_reg_out),
        .branch_taken_in(branch_unit_0_branch_taken_out),
        .csr_addr_in(instruction_mux_0_csr_addr_out),
        .csr_addr_reg_out(reg_block2_0_csr_addr_reg_out),
        .csr_op_in(msrv32_decoder_0_csr_op_out),
        .csr_op_reg_out(reg_block2_0_csr_op_reg_out),
        .csr_wr_en_in(msrv32_decoder_0_csr_wr_en_out),
        .csr_wr_en_reg_out(reg_block2_0_csr_wr_en_reg_out),
        .imm_iadder_in(imm_adder_0_iadder_imm_out),
        .imm_iadder_reg2_out(reg_block2_0_imm_iadder_reg2_out),
        .imm_in(imm_generator_0_imm_out),
        .imm_reg_out(reg_block2_0_imm_reg_out),
        .load_size_in(msrv32_decoder_0_load_size_out),
        .load_size_reg_out(reg_block2_0_load_size_reg_out),
        .load_unsigned_in(msrv32_decoder_0_load_unsigned_out),
        .load_unsigned_reg_out(reg_block2_0_load_unsigned_reg_out),
        .ms_riscv32_mp_clk_in(ms_riscv32_clk_0),
        .ms_riscv32_mp_rst_in(ms_riscv32_rst_0),
        .pc_in(reg_block_1_0_pc_out),
        .pc_plus_4_in(msrv32_pc_0_pc_plus_4_out),
        .pc_plus_4_reg_out(reg_block2_0_pc_plus_4_reg_out),
        .pc_reg_out(reg_block2_0_pc_reg_out),
        .rd_addr_in(instruction_mux_0_rdaddr_out),
        .rd_addr_reg_out(reg_block2_0_rd_addr_reg_out),
        .rf_wr_en_in(msrv32_decoder_0_rf_wr_en_out),
        .rf_wr_en_reg_out(reg_block2_0_rf_wr_en_reg_out),
        .rs1_in(msrv32_integer_file_0_rs_1_out),
        .rs1_reg_out(reg_block2_0_rs1_reg_out),
        .rs2_in(msrv32_integer_file_0_rs_2_out),
        .rs2_reg_out(reg_block2_0_rs2_reg_out),
        .wb_mux_sel_in(msrv32_decoder_0_wb_mux_sel_out),
        .wb_mux_sel_reg_out(reg_block2_0_wb_mux_sel_reg_out));
  RISC_V_Core_reg_block_1_0_0 reg_block_1_0
       (.PC_mux_in(msrv32_pc_0_pc_mux_out),
        .ms_riscv32_clk(ms_riscv32_clk_0),
        .ms_riscv32_rst(ms_riscv32_rst_0),
        .pc_out(reg_block_1_0_pc_out));
  RISC_V_Core_store_unit_0_0 store_unit_0
       (.funct3_in1(instruction_mux_0_funct3_out),
        .imm_iaddr_in(imm_adder_0_iadder_imm_out),
        .mem_wr_req_in(msrv32_decoder_0_mem_wr_req_out),
        .ms_riscv32_mp_data_htrans_out(ms_riscv32_mp_data_htrans_out_0),
        .ms_riscv32_mp_dmaddr_out(store_unit_0_ms_riscv32_mp_dmaddr_out),
        .ms_riscv32_mp_dmdata_out(store_unit_0_ms_riscv32_mp_dmdata_out),
        .ms_riscv32_mp_dmwr_mask_out(store_unit_0_ms_riscv32_mp_dmwr_mask_out),
        .ms_riscv32_mp_dmwr_req_out(ms_riscv32_mp_dmwr_req_out_0),
        .ms_riscv32_mp_instr_hready_in(ms_riscv32_mp_instr_hready_in_0),
        .rs2_in(msrv32_integer_file_0_rs_2_out),
        .unused_st(store_unit_0_unused_st));
  RISC_V_Core_unused_0_0 unused_0
       (.unused_in1(D_cache_0_unused_sink_Dc),
        .unused_in2(msrv32_pc_0_unused_pc),
        .unused_in3(I_cache_0_unused_sink_ic),
        .unused_in4(msrv32_integer_file_0_unused_sink_in),
        .unused_in5(store_unit_0_unused_st),
        .unused_in6(msrv32_decoder_0_unused_sink_De),
        .unused_in7(branch_unit_0_unused_sink_br),
        .unused_in8(load_unit1_0_unused_sink_lo),
        .unused_in9(fwrite_file_0_unused_sink_fr2),
        .unused_out1(unused_out1_0));
  RISC_V_Core_wb_mux_sel_unit_0_0 wb_mux_sel_unit_0
       (.alu_2nd_src_mux_out(wb_mux_sel_unit_0_alu_2nd_src_mux_out),
        .alu_result_in(ALU_0_result_out),
        .alu_src_reg_in(reg_block2_0_alu_src_reg_out),
        .csr_data_in(msrv32_csr_file_0_csr_data_out),
        .imm_iadder_reg2_in(reg_block2_0_imm_iadder_reg2_out),
        .imm_reg_in(reg_block2_0_imm_reg_out),
        .lu_output_in(load_unit1_0_lu_output_out),
        .pc_plus_4_reg_in(reg_block2_0_pc_plus_4_reg_out),
        .rs2_reg_in(reg_block2_0_rs2_reg_out),
        .wb_mux_out(wb_mux_sel_unit_0_wb_mux_out),
        .wb_mux_sel_reg_in(reg_block2_0_wb_mux_sel_reg_out));
endmodule
