`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/26 21:31:22
// Design Name: 
// Module Name: poolingiagu_sim
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


module poolingiagu_sim();
    //from Top
    reg clk;
    reg rst;
    
    //from schedule 
    reg start_calculate;
    
    //from decoder
    reg [11:0]addr_start_d;
    reg [7:0] in_x_length;
    reg [7:0] out_x_length;
    reg [7:0] out_y_length;
    reg [7:0] in_piece;    // for pooling : in_piece == out_piece
    reg [3:0] i_kernel;
    reg [1:0] i_stride;
    
    //to IO buffer
    wire [11:0]o_d_addr;
    wire       o_rd_en;
    wire       o_pooling_out;
    
    wire [2:0] WorkState;
    wire [2:0] WorkState_next;
    wire [3:0] o_kernel_col;
    wire [3:0] o_kernel_row;
    wire [11:0]o_row_begin_addr;
    wire [11:0]o_piece_begin_addr;
    wire [11:0]o_part_begin_addr;
    wire [11:0]o_kernel_row_begin_addr;
    
    IaguPooling
    sim_poolingiagu(clk, rst, start_calculate, addr_start_d, in_x_length, out_x_length, out_y_length, in_piece, i_kernel, i_stride,
                    o_d_addr, o_rd_en, o_pooling_out, WorkState, WorkState_next, o_kernel_col, o_kernel_row, o_row_begin_addr, o_piece_begin_addr, o_part_begin_addr, o_kernel_row_begin_addr);
    
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
        rst             <= 1'd1;
        addr_start_d    <= 12'd0;
        in_x_length     <= 8'd12;
        out_x_length    <= 8'd4;
        out_y_length    <= 8'd2;        
        in_piece        <= 8'd2;
        i_kernel        <= 4'd3;
        i_stride        <= 4'd3;
    end
    
endmodule
