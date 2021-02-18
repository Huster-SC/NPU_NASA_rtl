`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/29 14:18:34
// Design Name: 
// Module Name: oagu_sim
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


module oagu_sim();
    //from Top
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from decoder
    reg [1:0] buffer_flag;
    reg [7:0] out_x_length;
    reg [7:0] out_y_length;
    reg [7:0] out_piece;
    reg [11:0]addr_start_s;
    reg [7:0] store_length;
    reg [7:0] jump_length;    
    
    //from XPE
    reg [255:0] xpe_data;
    reg         xpe_data_valid;
    
    //to IO buffer
    wire [11:0] o_w_addr;
    wire [255:0]o_w_data;
    wire        o_w_en;
    wire        o_buffer_select;
     
    //to schedule
    wire calculate_end;
    
    //for simulate
    wire [7:0]o_out_col;
    wire [7:0]o_out_piece;
    wire [7:0]o_out_row;
    
    Oagu
    sim_oagu(clk, rst, start_calculate, buffer_flag, out_x_length, out_y_length, out_piece, addr_start_s, store_length, jump_length,
             xpe_data, xpe_data_valid, o_w_addr, o_w_data, o_w_en, o_buffer_select, calculate_end, o_out_col, o_out_piece, o_out_row);
    
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
        addr_start_s <= 12'd0;
        out_x_length <= 8'd3;
        out_y_length <= 8'd3;
        out_piece    <= 8'd2;
        buffer_flag  <= 2'd0;
        store_length <= 8'd0;
        jump_length  <= 8'd0;
    end
    
    initial begin
        xpe_data       = 0;
        xpe_data_valid = 0;
        #25 xpe_data       = 1;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 2;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 3;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 4;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 5;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 6;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 1;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 2;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 3;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 4;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 5;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 6;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 1;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 2;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 3;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 4;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 5;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;
        #20 xpe_data       = 6;
            xpe_data_valid = 1;
        #10 xpe_data       = 0;
            xpe_data_valid = 0;    
    end
    
//    initial begin
//        xpe_data       = 0;
//        xpe_data_valid = 0;
//        #55 xpe_data       = 0;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 1;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 2;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 3;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 4;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 5;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 0;
//            xpe_data_valid = 0;
//        #50 xpe_data       = 0;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 1;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 2;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 3;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 4;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 5;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 0;
//            xpe_data_valid = 0;
//        #50 xpe_data       = 0;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 1;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 2;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 3;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 4;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 5;
//            xpe_data_valid = 1;
//        #10 xpe_data       = 0;
//            xpe_data_valid = 0;    
//    end
    
endmodule
