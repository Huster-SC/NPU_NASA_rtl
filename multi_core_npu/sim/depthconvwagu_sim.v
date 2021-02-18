`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 20:57:04
// Design Name: 
// Module Name: depthconvwagu_sim
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


module depthconvwagu_sim();
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from IAGU
    reg feature_load_end;
    
    //from decoder
    reg [3:0] mode;
    reg [12:0]addr_start_w;
    reg [7:0] in_y_length;
    reg [7:0] in_piece;
    reg [7:0] out_y_length;
    reg [4:0] part_num;
    reg [3:0] last_part;
    reg [3:0] i_kernel;
    reg [1:0] i_stride;
    reg [1:0] i_pad;
    reg [1:0] tilingtype;
    
    //to weight buffer
    wire [12:0]o_w_addr;
    wire       o_rd_en;
    
    //to IAGU
    wire o_group_end;
    
    //to NPE
    wire       o_depthconv_out;
    wire [7:0] o_pe_en;
    
    WaguDepthConvolution
    sim_depthconvwagu(clk, rst, start_calculate, feature_load_end, mode, addr_start_w, in_y_length, in_piece, out_y_length, part_num,
                      last_part, i_kernel, i_stride, i_pad, tilingtype, o_w_addr, o_rd_en, o_group_end, o_depthconv_out, o_pe_en);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        start_calculate     = 1'd0;
        #10 start_calculate = 1'd1;
        #10 start_calculate = 1'd0;
    end
    
    initial begin
        rst          <= 1'd1;
        mode         <= 4'd5;
        addr_start_w <= 12'd0;
        in_y_length  <= 8'd5;
        in_piece     <= 8'd2;
        out_y_length <= 8'd3;
        part_num     <= 5'd1;
        last_part    <= 4'd3;
        i_kernel     <= 4'd3;
        i_stride     <= 2'd1;
        i_pad        <= 2'd0;
        tilingtype   <= 2'd1;
    end  
    
    initial begin
        feature_load_end = 0;
        #20 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
        #50 feature_load_end = 1;
        #10 feature_load_end = 0;
    end     
endmodule
