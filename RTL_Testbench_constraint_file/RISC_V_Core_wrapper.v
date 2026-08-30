//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Sun Aug 30 23:13:57 2026
//Host        : DESKTOP-UR0PACQ running 64-bit major release  (build 9200)
//Command     : generate_target RISC_V_Core_wrapper.bd
//Design      : RISC_V_Core_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module RISC_V_Core_wrapper
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
  input ms_riscv32_clk_0;
  output [1:0]ms_riscv32_mp_data_htrans_out_0;
  output ms_riscv32_mp_dmwr_req_out_0;
  input ms_riscv32_mp_eirq_in_0;
  input ms_riscv32_mp_hready_in_0;
  input ms_riscv32_mp_instr_hready_in_0;
  input ms_riscv32_mp_sirq_in_0;
  input ms_riscv32_mp_tirq_in_0;
  input ms_riscv32_rst_0;
  output [139:0]result_status_0;
  output unused_out1_0;

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
  wire [139:0]result_status_0;
  wire unused_out1_0;

  RISC_V_Core RISC_V_Core_i
       (.mie_out_0(mie_out_0),
        .ms_riscv32_clk_0(ms_riscv32_clk_0),
        .ms_riscv32_mp_data_htrans_out_0(ms_riscv32_mp_data_htrans_out_0),
        .ms_riscv32_mp_dmwr_req_out_0(ms_riscv32_mp_dmwr_req_out_0),
        .ms_riscv32_mp_eirq_in_0(ms_riscv32_mp_eirq_in_0),
        .ms_riscv32_mp_hready_in_0(ms_riscv32_mp_hready_in_0),
        .ms_riscv32_mp_instr_hready_in_0(ms_riscv32_mp_instr_hready_in_0),
        .ms_riscv32_mp_sirq_in_0(ms_riscv32_mp_sirq_in_0),
        .ms_riscv32_mp_tirq_in_0(ms_riscv32_mp_tirq_in_0),
        .ms_riscv32_rst_0(ms_riscv32_rst_0),
        .result_status_0(result_status_0),
        .unused_out1_0(unused_out1_0));
endmodule
