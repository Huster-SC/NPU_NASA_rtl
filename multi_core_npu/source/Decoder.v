`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/10/21 21:12:37
// Design Name: 
// Module Name: Decoder
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


module Decoder(
    input clk,
    input rst,
    input [127:0] inst_in,
	input         inst_valid,
	
    //to NPU
    output [3:0] o_mode,
    output [1:0] o_xpe_mode,
    output [12:0]o_addr_start_w,
    output [12:0]o_addr_start_d,
    output [7:0] o_addr_start_b,
    output [12:0]o_addr_start_s,
    output [7:0] o_in_x_length,
    output [7:0] o_in_y_length,
    output [7:0] o_in_piece,
    output [7:0] o_out_x_length,
    output [7:0] o_out_y_length,
    output [7:0] o_out_piece,
    output [7:0] o_part_num,
    output [3:0] o_last_part,
    output [3:0] o_kernel,
    output [1:0] o_stride,
    output [1:0] o_pad,
    output [1:0] o_tilingtype,
    output [3:0] o_i_q_encode,
    output [3:0] o_w_q_encode,
    output [3:0] o_o_q_encode,
    output [7:0] o_avg_pooling_coe,
    output [1:0] o_buffer_flag,
    output [7:0] o_store_length,
    output [7:0] o_jump_length,
    output       o_sort_en
    );
    
    parameter IOB2N = 5'b01010;
    parameter WB2N  = 5'b01011;
    parameter N2IOB = 5'b01101;
    
    //from decoder
    reg [3:0] r_mode;
    reg [1:0] r_xpe_mode;
    reg [12:0]r_addr_start_w;
    reg [12:0]r_addr_start_d;
    reg [7:0] r_addr_start_b;
    reg [12:0]r_addr_start_s;
    reg [7:0] r_in_x_length;
    reg [7:0] r_in_y_length;
    reg [7:0] r_in_piece;
    reg [7:0] r_out_x_length;
    reg [7:0] r_out_y_length;
    reg [7:0] r_out_piece;
    reg [7:0] r_part_num;
    reg [3:0] r_last_part;
    reg [3:0] r_kernel;
    reg [1:0] r_stride;
    reg [1:0] r_pad;
    reg [1:0] r_tilingtype;
    reg [3:0] r_i_q_encode;
    reg [3:0] r_w_q_encode;
    reg [3:0] r_o_q_encode;
    reg [7:0] r_avg_pooling_coe;
    reg [1:0] r_buffer_flag;
    reg [7:0] r_store_length;
    reg [7:0] r_jump_length;
    reg       r_sort_en;
    
    wire [4:0] opcode;
    assign opcode = inst_in[127:123];
    
    assign o_mode         = r_mode;
    assign o_xpe_mode     = r_xpe_mode;
    assign o_addr_start_w = r_addr_start_w;
    assign o_addr_start_d = r_addr_start_d;
    assign o_addr_start_b = r_addr_start_b;
    assign o_addr_start_s = r_addr_start_s; 
    assign o_in_x_length  = r_in_x_length;
    assign o_in_y_length  = r_in_y_length;
    assign o_in_piece     = r_in_piece;
    assign o_out_x_length = r_out_x_length;
    assign o_out_y_length = r_out_y_length;
    assign o_out_piece    = r_out_piece;
    assign o_part_num     = r_part_num;
    assign o_last_part    = r_last_part;
    assign o_kernel       = r_kernel;
    assign o_stride       = r_stride;
    assign o_pad          = r_pad;
    assign o_tilingtype   = r_tilingtype;
    assign o_i_q_encode   = r_i_q_encode;
    assign o_w_q_encode   = r_w_q_encode;
    assign o_o_q_encode   = r_o_q_encode;
    assign o_avg_pooling_coe = r_avg_pooling_coe;
    assign o_buffer_flag  = r_buffer_flag;
    assign o_store_length = r_store_length;
    assign o_jump_length  = r_jump_length;
    assign o_sort_en      = r_sort_en;
    
    initial begin
        r_mode          <= 0;
        r_xpe_mode      <= 0;
        r_addr_start_w  <= 0;
        r_addr_start_d  <= 0;
        r_addr_start_b  <= 0;
        r_addr_start_s  <= 0;
        r_in_x_length   <= 0;
        r_in_y_length   <= 0;
        r_in_piece      <= 0;
        r_out_x_length  <= 0;
        r_out_y_length  <= 0;
        r_out_piece     <= 0;
        r_part_num      <= 0;
        r_last_part     <= 0;
        r_kernel        <= 0;
        r_stride        <= 0;
        r_pad           <= 0;
        r_tilingtype    <= 0;
        r_i_q_encode    <= 0;
        r_w_q_encode    <= 0;
        r_o_q_encode    <= 0;
        r_avg_pooling_coe <= 0;
        r_buffer_flag   <= 0;
        r_store_length  <= 0;
        r_jump_length   <= 0;
        r_sort_en       <= 0;
    end
    
    always@(posedge clk or posedge rst)begin
        if(!rst) begin
            r_mode          <= 0;
            r_xpe_mode      <= 0;
            r_addr_start_w  <= 0;
            r_addr_start_d  <= 0;
            r_addr_start_b  <= 0;
            r_addr_start_s  <= 0;
            r_in_x_length   <= 0;
            r_in_y_length   <= 0;
            r_in_piece      <= 0;
            r_out_x_length  <= 0;
            r_out_y_length  <= 0;
            r_out_piece     <= 0;
            r_part_num      <= 0;
            r_last_part     <= 0;
            r_kernel        <= 0;
            r_stride        <= 0;
            r_pad           <= 0;
            r_tilingtype    <= 0;
            r_i_q_encode    <= 0;
            r_w_q_encode    <= 0;
            r_o_q_encode    <= 0;
            r_avg_pooling_coe <= 0;
            r_buffer_flag   <= 0;
            r_store_length  <= 0;
            r_jump_length   <= 0;
            r_sort_en       <= 0;
        end else if(inst_valid) begin
            case (opcode)
                IOB2N: begin
                    r_addr_start_d <= inst_in[121:110];
                    r_buffer_flag  <= inst_in[109:108];
                    r_mode         <= inst_in[107:104];
                    r_in_x_length  <= inst_in[103:96];
                    r_in_y_length  <= inst_in[95:88];
                    r_in_piece     <= inst_in[87:80];
                    r_tilingtype   <= inst_in[79:78];
                    r_part_num     <= inst_in[77:70];
                    r_last_part    <= inst_in[69:66];
                    r_avg_pooling_coe <= inst_in[57:50];
			    end

                WB2N: begin
                    r_addr_start_w <= inst_in[121:110];
                    r_addr_start_b <= inst_in[109:98];
                    r_kernel       <= inst_in[97:94];
                    r_stride       <= inst_in[93:92];
                    r_pad          <= inst_in[91:90];
                    r_w_q_encode   <= inst_in[89:86];
                    r_i_q_encode   <= inst_in[85:82];
                    r_o_q_encode   <= inst_in[81:78];
                end

                N2IOB: begin
                    r_addr_start_s <= inst_in[121:110];
                    r_out_x_length <= inst_in[109:102];
                    r_out_y_length <= inst_in[101:94];
                    r_out_piece    <= inst_in[93:86];
                    r_jump_length  <= inst_in[85:78];
                    r_store_length <= inst_in[77:70];
                    r_xpe_mode     <= inst_in[53:52];
                end
			endcase    
        end else begin
            r_mode          <= r_mode;
            r_xpe_mode      <= r_xpe_mode;
            r_addr_start_w  <= r_addr_start_w;
            r_addr_start_d  <= r_addr_start_d;
            r_addr_start_b  <= r_addr_start_b;
            r_addr_start_s  <= r_addr_start_s;
            r_in_x_length   <= r_in_x_length;
            r_in_y_length   <= r_in_y_length;
            r_in_piece      <= r_in_piece;
            r_out_x_length  <= r_out_x_length;
            r_out_y_length  <= r_out_y_length;
            r_out_piece     <= r_out_piece;
            r_part_num      <= r_part_num;
            r_last_part     <= r_last_part;
            r_kernel        <= r_kernel;
            r_stride        <= r_stride;
            r_pad           <= r_pad;
            r_tilingtype    <= r_tilingtype;
            r_i_q_encode    <= r_i_q_encode;
            r_w_q_encode    <= r_w_q_encode;
            r_o_q_encode    <= r_o_q_encode;
            r_avg_pooling_coe <= r_avg_pooling_coe;
            r_buffer_flag   <= r_buffer_flag;
            r_store_length  <= r_store_length;
            r_jump_length   <= r_jump_length;
            r_sort_en       <= r_sort_en;
        end
    end
    
endmodule
