`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/20 21:30:51
// Design Name: 
// Module Name: wagu_sim
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


module convwagu_sim();
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from IAGU
    reg feature_load_end;
    
    //from decoder
    reg [3:0] mode;
    reg [11:0]addr_start_w;
    reg [7:0] in_y_length;
    reg [7:0] in_piece;
    reg [7:0] out_x_length;
    reg [7:0] out_y_length;
    reg [7:0] out_piece;
    reg [4:0] part_num;
    reg [3:0] last_part;
    reg [3:0] i_kernel;
    reg [1:0] i_stride;
    reg [1:0] i_pad;
    reg [1:0] tilingtype;
    
    //to weight buffer
    wire [11:0]o_w_addr;
    wire       o_rd_en;
    
    //to IAGU
    wire o_group_end;
    
    //to NPE
    wire       o_conv_out;
    wire [7:0] o_pe_en;
    //wire o_fc_out;
    
    wire [3:0] o_r_WorkState;
    wire [3:0] o_r_WorkState_next;
    wire [7:0] o_kernel_col;
    wire [7:0] o_kernel_row;
    wire [7:0] o_in_piece;
    wire [4:0] o_part_num;
    wire [7:0] o_out_piece;
    wire [7:0] o_row;
    wire [7:0] o_in_row;
    wire [5:0] o_group_cnt;
    
    
    WaguConvolution 
    sim_convwagu(clk, rst, start_calculate, feature_load_end, mode, addr_start_w, in_y_length, in_piece, out_x_length, out_y_length, out_piece, part_num, last_part, i_kernel, i_stride, i_pad, tilingtype,
                o_w_addr, o_rd_en, o_group_end, o_conv_out, o_pe_en, o_r_WorkState, o_r_WorkState_next, 
                o_kernel_col, o_kernel_row, o_in_piece, o_part_num, o_out_piece, o_row, o_in_row, o_group_cnt);
                
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
       
    initial begin
        //start_calculate = 1'd1;
        rst          <= 1'd1;
        mode         <= 4'd1;
        addr_start_w <= 12'd0;
        in_y_length  <= 8'd3;
        in_piece     <= 8'd2;
        out_x_length <= 8'd5;
        out_y_length <= 8'd2;
        out_piece    <= 8'd2;
        part_num     <= 5'd1;
        last_part    <= 4'd5;
        i_kernel     <= 4'd3;
        i_stride     <= 2'd2;
        i_pad        <= 2'd2;
        tilingtype   <= 2'd2;
    end
    
    initial begin
        start_calculate     = 1'd0;
        #10 start_calculate = 1'd1;
        #10 start_calculate = 1'd0;
    end
    
    initial begin
        feature_load_end = 0;
        #20
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0; 
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
        #400 feature_load_end = 1;
        #10  feature_load_end = 0;
    end
    
endmodule
