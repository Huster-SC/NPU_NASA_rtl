// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Fri Oct 30 19:32:17 2020
// Host        : DESKTOP-8T4TJSM running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               F:/master/verilog/NASA/simply_npu/simply_npu.srcs/sources_1/ip/GlobleBuffer_256X8192/GlobleBuffer_256X8192_stub.v
// Design      : GlobleBuffer_256X8192
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module GlobleBuffer_256X8192(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[12:0],dina[255:0],clkb,enb,addrb[12:0],doutb[255:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [12:0]addra;
  input [255:0]dina;
  input clkb;
  input enb;
  input [12:0]addrb;
  output [255:0]doutb;
endmodule
