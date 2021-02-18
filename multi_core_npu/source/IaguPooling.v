`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/25 13:59:49
// Design Name: 
// Module Name: IaguPooling
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


module IaguPooling(
    //from Top
    input clk,
    input rst,
    
    //from schedule 
    input start_calculate,
    
    //from decoder
    input [12:0]addr_start_d,
    input [7:0] in_x_length,
    input [7:0] out_x_length,
    input [7:0] out_y_length,
    input [7:0] in_piece,    // for pooling : in_piece == out_piece
    input [3:0] i_kernel,
    input [1:0] i_stride,
    
    //to IO buffer
    output [12:0]o_d_addr,
    output       o_rd_en,
    output       o_pooling_out
    
    //for simulation
//    output [3:0] WorkState,
//    output [3:0] WorkState_next,
//    output [3:0] o_kernel_col,
//    output [3:0] o_kernel_row,
//    output [11:0]o_row_begin_addr,
//    output [11:0]o_piece_begin_addr,
//    output [11:0]o_part_begin_addr,
//    output [11:0]o_kernel_row_begin_addr
    );
    
    //for state machine
    parameter [4:0] IBR_IDLE              = 3'd0,
                    IBR_GEN_ROW_BEGIN     = 3'd1,
                    IBR_GEN_PIECE_BEGIN   = 3'd2,
                    IBR_GEN_PART_BEGIN    = 3'd3, //next windows
                    IBR_GEN_KER_ROW_BEGIN = 3'd4,
                    IBR_GEN_ADDR          = 3'd5,
                    IBR_UPDATE_COORDINATE = 3'd6;                 
    reg [2:0] r_WorkState,r_WorkState_next;
    
    wire w_kernel_col_end;
    wire w_kernel_row_end;
    wire w_out_x_end;
    wire w_in_piece_end;
    wire w_out_y_end;
    wire w_tiling_end;
    wire w_update_row;
    wire w_update_piece;
    wire w_update_part;
    wire w_update_kernel_row;
    
    wire [12:0] one_line_size;
    wire [12:0] stride_jump_size;
    
    reg [12:0]r_group_addr;
    reg [3:0] r_kernel_col;
    reg [3:0] r_kernel_row;
    reg [7:0] r_out_x;
    reg [7:0] r_piece;
    reg [7:0] r_out_y;
    reg [7:0] r_in_y;
    
    reg signed [13:0] row_begin_addr;
    reg signed [13:0] part_begin_addr;
    reg signed [13:0] piece_begin_addr;
    reg signed [13:0] kernel_row_begin_addr;
    
    reg r_rd_en;
    reg r_pooling_out;
    reg r_pooling_out_1;
    
    assign one_line_size    = in_x_length   * in_piece;
    assign stride_jump_size = one_line_size * i_stride;
    
    assign w_kernel_col_end = (r_kernel_col == i_kernel     - 1);
    assign w_kernel_row_end = (r_kernel_row == i_kernel     - 1);
    assign w_out_x_end      = (r_out_x      == out_x_length - 1);
    assign w_in_piece_end   = (r_piece      == in_piece     - 1);
    assign w_out_y_end      = (r_out_y      == out_y_length - 1);
    assign w_tiling_end     = (r_kernel_col == i_kernel) && (r_kernel_row == i_kernel) && (r_out_x == out_x_length) && (r_piece == in_piece) && (r_out_y == out_y_length);
    assign w_update_row     = (r_kernel_col == i_kernel) && (r_kernel_row == i_kernel) && (r_out_x == out_x_length) && (r_piece == in_piece);
    assign w_update_piece   = (r_kernel_col == i_kernel) && (r_kernel_row == i_kernel) && (r_out_x == out_x_length);
    assign w_update_part    = (r_kernel_col == i_kernel) && (r_kernel_row == i_kernel);
    assign w_update_kernel_row = (r_kernel_col == i_kernel);
    
     
    assign o_d_addr = r_group_addr;
    assign o_rd_en  = r_rd_en;
    assign o_pooling_out = r_pooling_out_1;
    
    //for simulation
//    assign WorkState      = r_WorkState; 
//    assign WorkState_next = r_WorkState_next;
//    assign o_kernel_col   = r_kernel_col;
//    assign o_kernel_row   = r_kernel_row;
//    assign o_row_begin_addr   = row_begin_addr;
//    assign o_piece_begin_addr = piece_begin_addr;
//    assign o_part_begin_addr  = part_begin_addr;
//    assign o_kernel_row_begin_addr = kernel_row_begin_addr;
    
    initial begin
        r_group_addr    <= 0;
        r_rd_en         <= 0;
        r_pooling_out   <= 0;
        r_pooling_out_1 <= 0;           
    end
    
    always@(*) begin
        r_rd_en <= (r_WorkState == IBR_UPDATE_COORDINATE);
        r_pooling_out <= w_update_part && (r_WorkState == IBR_UPDATE_COORDINATE);    
    end
    
    always@(posedge clk or negedge rst) begin
        if (!rst)
            r_pooling_out_1 <= 0;  
        else 
            r_pooling_out_1 <= r_pooling_out;        
    end
    
    //state machine for generating feature address 
    always@(posedge clk or negedge rst) begin
        if (!rst)
            r_WorkState <= IBR_IDLE;
        else 
            r_WorkState <= r_WorkState_next;
    end
    
    always @(*) begin
        if (!rst)
            r_WorkState_next = IBR_IDLE;
        else
            case (r_WorkState)
                IBR_IDLE: begin
                    if(start_calculate)
                        r_WorkState_next = IBR_GEN_ROW_BEGIN;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                IBR_GEN_ROW_BEGIN: begin
                    r_WorkState_next = IBR_GEN_PIECE_BEGIN;
                end
                
                IBR_GEN_PIECE_BEGIN: begin
                    r_WorkState_next = IBR_GEN_PART_BEGIN; 
                end
                
                IBR_GEN_PART_BEGIN: begin
                    r_WorkState_next = IBR_GEN_KER_ROW_BEGIN; 
                end
                
                IBR_GEN_KER_ROW_BEGIN: begin
                    r_WorkState_next = IBR_GEN_ADDR;
                end
                
                IBR_GEN_ADDR: begin
                    r_WorkState_next = IBR_UPDATE_COORDINATE;  
                end
                                               
                IBR_UPDATE_COORDINATE: begin
                    if(w_tiling_end)
                        r_WorkState_next = IBR_IDLE;
                    else if(w_update_row)
                        r_WorkState_next = IBR_GEN_ROW_BEGIN;
                    else if(w_update_piece)
                        r_WorkState_next = IBR_GEN_PIECE_BEGIN;
                    else if(w_update_part)
                        r_WorkState_next = IBR_GEN_PART_BEGIN;
                    else if(w_update_kernel_row)
                        r_WorkState_next = IBR_GEN_KER_ROW_BEGIN;
                    else
                        r_WorkState_next = IBR_GEN_ADDR;
                end
                
                default:
                    r_WorkState_next = IBR_IDLE; 
            endcase
    end
    
    //generate feature map address
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_group_addr <= 0;
        else if(start_calculate)
            r_group_addr <= 0;
        else if(r_WorkState == IBR_GEN_ADDR)
            r_group_addr <= r_group_addr + kernel_row_begin_addr + r_kernel_col;
        else
            r_group_addr <= 0;
    end
    
    //Loop 5: kernel column count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_kernel_col <= 0;
        else if(start_calculate)
            r_kernel_col <= 0;
        else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            r_kernel_col <= r_kernel_col + 1;
        end else if(r_WorkState_next == IBR_GEN_KER_ROW_BEGIN)
            r_kernel_col <= 0;       
        else 
            r_kernel_col <= r_kernel_col;
    end
    
    //Loop 4: kernel row count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_kernel_row <= 0;
        else if(start_calculate)
            r_kernel_row <= 0;
        else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end)
                r_kernel_row <= r_kernel_row + 1;
        end else if(r_WorkState_next == IBR_GEN_PART_BEGIN)
            r_kernel_row <= 0;
        else 
            r_kernel_row <= r_kernel_row;
    end
    
    //Loop 3: current column count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_out_x <= 0;
        else if(start_calculate)
            r_out_x <= 0;
        else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end)
                r_out_x <= r_out_x + 1;
        end else if(r_WorkState_next == IBR_GEN_PIECE_BEGIN) begin
                r_out_x <= 0;
        end else
            r_out_x <= r_out_x;
    end
    
    //Loop 2: input piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_piece <= 0;
        else if(start_calculate)
            r_piece <= 0;
        else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end && w_out_x_end)
               r_piece <= r_piece + 1;
        end else if(r_WorkState_next == IBR_GEN_ROW_BEGIN) begin
                r_piece <= 0;
        end else
            r_piece <= r_piece;
    end
    
    //Loop 1: current row count
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_out_y <= 0;
            r_in_y  <= 0;
        end else if(start_calculate) begin
            r_out_y <= 0;
            r_in_y  <= 0;
        end else if(r_WorkState_next == IBR_UPDATE_COORDINATE)
            if(w_kernel_col_end && w_kernel_row_end && w_out_x_end && w_in_piece_end) begin
                r_out_y <= r_out_y + 1;
                r_in_y  <= r_in_y  + i_stride;
            end 
        else if(r_WorkState_next == IBR_IDLE) begin
                r_out_y <= 0;
                r_in_y  <= 0;
            end
        else begin
            r_out_y <= r_out_y;
            r_in_y  <= r_in_y;
        end
    end
    
    //calculate first address
    //calculate row_begin_addr
    always@(posedge clk or negedge rst) begin
        if(!rst)
            row_begin_addr <= 0;
        else  if(start_calculate)
            row_begin_addr <= 0;
        else if(r_WorkState == IBR_GEN_ROW_BEGIN) begin
            row_begin_addr <= r_in_y * one_line_size; 
        end else
            row_begin_addr <= row_begin_addr;       
    end
    
    //calculate piece_begin_addr
    always@(posedge clk or negedge rst) begin
        if(!rst)
            piece_begin_addr <= 0;
        else  if(start_calculate)
            piece_begin_addr <= 0;
        else if(r_WorkState == IBR_GEN_PIECE_BEGIN) begin
            piece_begin_addr <= row_begin_addr + r_piece * in_x_length; 
        end else
            piece_begin_addr <= piece_begin_addr;       
    end
    
    //calculate part_begin_addr
    always@(posedge clk or negedge rst) begin
        if(!rst)
            part_begin_addr <= 0;
        else  if(start_calculate)
            part_begin_addr <= 0;
        else if(r_WorkState == IBR_GEN_PART_BEGIN) begin
            part_begin_addr <= piece_begin_addr + r_out_x * i_stride; 
        end else
            part_begin_addr <= part_begin_addr;       
    end
    
    //calculate kernel_row_begin_addr
    always@(posedge clk or negedge rst) begin
        if(!rst)
            kernel_row_begin_addr <= 0;
        else  if(start_calculate)
            kernel_row_begin_addr <= 0;
        else if(r_WorkState == IBR_GEN_KER_ROW_BEGIN) begin
            kernel_row_begin_addr <= part_begin_addr + r_kernel_row * one_line_size; 
        end else
            kernel_row_begin_addr <= kernel_row_begin_addr;       
    end
    
endmodule
