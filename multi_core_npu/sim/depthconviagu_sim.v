`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/29 15:51:53
// Design Name: 
// Module Name: depthconviagu_sim
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


module depthconviagu_sim();
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from IAGU
    reg weight_load_end;
    
     //from decoder
    reg [12:0]addr_start_d;
    reg [7:0] in_x_length;
    reg [7:0] in_y_length;
    reg [7:0] in_piece;
    reg [7:0] out_y_length;
    reg [4:0] part_num;
    reg [3:0] last_part;
    reg [3:0] i_kernel;
    reg [1:0] i_stride;
    reg [1:0] i_pad;
    reg [1:0] tilingtype;
    
    //to IO buffer
    wire [12:0]o_d_addr;
    wire       o_rd_en;
    wire       o_pad_en;
    
    //to WAGU
    wire       o_feature_end;
    
    IaguDepthConvolution
    sim_depthconvolution(clk, rst, start_calculate, weight_load_end, addr_start_d, in_x_length, in_y_length, in_piece, out_y_length,
                         part_num, last_part, i_kernel, i_stride, i_pad, tilingtype, o_d_addr, o_rd_en, o_pad_en, o_feature_end);
    
    initial begin 
        clk <= 0;
        forever #10 clk <= ~clk;
    end
    
    initial begin
        start_calculate     = 1'd0;
        #20 start_calculate = 1'd1;
        #20 start_calculate = 1'd0;
    end
    
    initial begin
        weight_load_end <= 1'd0;
        rst             <= 1'd1;
        addr_start_d    <= 13'd0;
        in_x_length     <= 8'd5;
        in_y_length     <= 8'd5;        
        in_piece        <= 8'd2;
        out_y_length    <= 8'd5;
        part_num        <= 5'd2;
        last_part       <= 4'd2;
        i_kernel        <= 4'd3;
        i_stride        <= 2'd1;
        i_pad           <= 2'd1;
        tilingtype      <= 2'd1;
    end
    
    initial begin 
        #500 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
        #400 weight_load_end <= 1;
        #20  weight_load_end <= 0;
    end
     
endmodule
