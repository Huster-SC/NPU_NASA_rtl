`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/29 13:26:52
// Design Name: 
// Module Name: Oagu
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


module Oagu(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from decoder
    input [1:0] buffer_flag,
    input [7:0] out_x_length,
    input [7:0] out_y_length,
    input [7:0] out_piece,
    input [12:0]addr_start_s,
    input [7:0] store_length,
    input [7:0] jump_length,     
    
    //from XPE
    input [255:0] xpe_data,
    input         xpe_data_valid,
    
    //to IO buffer
    output [12:0] o_w_addr,
    output [255:0]o_w_data,
    output        o_w_en,
    output        o_buffer_select,
     
    //to schedule
    output calculate_end
    
    //for simulate
//    output [7:0]o_out_col,
//    output [7:0]o_out_piece,
//    output [7:0]o_out_row
    
);
    reg [7:0]  r_out_col;
    reg [7:0]  r_out_row;
    reg [7:0]  r_out_piece;
    reg [12:0] r_group_addr;
//    reg [7:0]  r_store_length;
    reg [255:0]r_xpe_data;
    reg        r_xpe_data_valid; 
    reg        r_calculate_end;
        
    wire w_col_end;
    wire w_row_end;
    wire w_piece_end;
//    wire DontJump;
    wire JumpEn;
    wire w_calculate_end;
    
    assign w_col_end   = (r_out_col   == out_x_length - 1);
    assign w_row_end   = (r_out_row   == out_y_length - 1);
    assign w_piece_end = (r_out_piece == out_piece    - 1);
    assign w_calculate_end = r_xpe_data_valid && w_col_end && w_piece_end && w_row_end;
    
//    assign DontJump = (jump_length == 0);
    assign JumpEn   = w_col_end && w_piece_end;
    
    assign o_w_addr        = r_group_addr;
    assign o_w_data        = r_xpe_data_valid ? r_xpe_data : 255'd0;
    assign o_w_en          = r_xpe_data_valid;
    assign o_buffer_select = buffer_flag ? 1'b1 : 1'b0;
    //assign calculate_end   = r_xpe_data_valid && w_col_end && w_piece_end && w_row_end; 
    assign calculate_end   = r_calculate_end; 
    //for simulate
//    assign o_out_col   = r_out_col;
//    assign o_out_piece = r_out_piece;
//    assign o_out_row   = r_out_row;
    
    initial begin
        r_group_addr     <= 0;
        r_xpe_data_valid <= 0;
        r_xpe_data       <= 0;
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_xpe_data_valid <= 0;
        else
            r_xpe_data_valid <= xpe_data_valid;
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_xpe_data <= 0;
        else if(xpe_data_valid)
            r_xpe_data <= xpe_data;
        else
            r_xpe_data <= 0;     
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_group_addr <= 0;
        else if(start_calculate)
            r_group_addr <= addr_start_s;
        else if(r_xpe_data_valid)
            if(JumpEn)
                r_group_addr <= r_group_addr + jump_length + 1;
            else
                r_group_addr <= r_group_addr + 1;
        else
            r_group_addr <= r_group_addr;         
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
           r_out_col <= 0;
        else if(start_calculate)
           r_out_col <= 0;
        else if(r_xpe_data_valid)
            if(w_col_end)
                r_out_col <= 0;
            else
                r_out_col <= r_out_col + 1;
        else
            r_out_col <= r_out_col;  
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
           r_out_piece <= 0;
        else if(start_calculate)
           r_out_piece <= 0;
        else if(w_col_end && r_xpe_data_valid)
            if(w_piece_end)
                r_out_piece <= 0;
            else
                r_out_piece <= r_out_piece + 1;
        else
            r_out_piece <= r_out_piece;  
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
           r_out_row <= 0;
        else if(start_calculate)
           r_out_row <= 0;
        else if(w_col_end && w_piece_end && r_xpe_data_valid)
            if(w_row_end)
                r_out_row <= 0;
            else
                r_out_row <= r_out_row + 1;
        else
            r_out_row <= r_out_row;  
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_calculate_end <= 0;
        else if(start_calculate)
            r_calculate_end <= 0;    
        else if(w_calculate_end)
            r_calculate_end <= 1;
        else
            r_calculate_end <= 0;     
    end
    
endmodule
