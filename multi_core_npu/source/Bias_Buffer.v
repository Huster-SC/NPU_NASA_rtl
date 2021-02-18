`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/10/13 16:48:51
// Design Name: 
// Module Name: Bias_Buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Bias_Buffer(
    input clk,
    input rst,
    //external data input port for axi bram controller
    input           i_bias_bramctl_en   ,
    input  [7:0]    i_bias_bramctl_addr ,
    input           i_bias_bramctl_we   ,
    input  [511:0]  i_bias_bramctl_wdata,
    
    //internal port
    input [7:0]     i_bias_raddr  ,
    input           i_bias_rd_en  , 
    output[511:0]   o_bias_data   ,
    output          o_bias_data_vld 
    );
    
    wire        w_bias_wren;
    wire [7:0]  w_bias_waddr;
    wire [511:0]w_bias_wdata;
    
    wire        w_bias_rden;
    wire [7:0]  w_bias_raddr;
    wire [511:0]w_bias_rdata;
    
    reg r_bias_data_vld;
    
    assign w_bias_wren  = i_bias_bramctl_en && i_bias_bramctl_we;
    assign w_bias_waddr = i_bias_bramctl_addr;
    assign w_bias_wdata = i_bias_bramctl_wdata;
    
    assign w_bias_rden  = i_bias_rd_en;
    assign i_bias_raddr = i_bias_raddr;
    
    assign o_bias_data     = w_bias_rdata;
    assign o_bias_data_vld = r_bias_data_vld;
    
    initial begin
       r_bias_data_vld <= 0; 
    end
    
    always@(posedge clk) begin
        if(!rst)
            r_bias_data_vld <= 0;
        else if(i_bias_rd_en)
            r_bias_data_vld <= 1;
        else
            r_bias_data_vld <= 0;     
    end
    
    blk_mem_gen_bias_512X128 bias(
        .clka       (clk            ),   // input wire clka
        .ena        (1'b1           ),   // input wire ena
        .wea        (w_bias_wren    ),   // input wire [0 : 0] wea
        .addra      (w_bias_waddr   ),   // input wire [7 : 0] addra
        .dina       (w_bias_wdata   ),   // input wire [511 : 0] dina
        .clkb       (clk            ),   // input wire clkb
        .enb        (w_bias_rden    ),   // input wire enb
        .addrb      (w_bias_raddr   ),   // input wire [7 : 0] addrb
        .doutb      (w_bias_rdata   )    // output wire [511 : 0] doutb
    );
    
endmodule
