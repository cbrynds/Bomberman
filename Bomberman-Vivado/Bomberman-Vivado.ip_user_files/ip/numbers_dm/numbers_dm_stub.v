// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Fri Dec  1 20:22:46 2023
// Host        : CECSB85NZV2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/numbers_dm/numbers_dm_stub.v
// Design      : numbers_dm
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_12,Vivado 2017.4" *)
module numbers_dm(a, spo)
/* synthesis syn_black_box black_box_pad_pin="a[10:0],spo[23:0]" */;
  input [10:0]a;
  output [23:0]spo;
endmodule
