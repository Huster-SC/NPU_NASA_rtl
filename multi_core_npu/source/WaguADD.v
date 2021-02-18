`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/24 21:07:07
// Design Name: 
// Module Name: WaguADD
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


module WaguADD(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from decoder
    input [3:0] mode,
    input [12:0]addr_start_w,
    input [7:0] out_x_length,
    input [7:0] out_y_length,
    input [7:0] in_piece,
    
    //to weight buffer
    output [12:0]o_w_addr,
    output       o_rd_en
    
    );
    
    //for state machine
    parameter [1:0] ADD_WBR_IDLE     = 2'd0, 
                     ADD_WBR_ADDR_GEN = 2'd1,
                     ADD_WBR_WAIT     = 2'd2;
    reg [1:0] r_WorkState,r_WorkState_next;
    
    //mode map
    parameter [3:0] CONV_MODE = 4'd1,
                     FC_MODE   = 4'd2,
                     ADD_MODE  = 4'd3,
                     POOL_MODE = 4'd4;
    
    reg [7:0] r_col; 
    reg [7:0] r_piece;
    reg [7:0] r_row;
    reg [12:0]r_add_address;
    reg       r_rd_en;
    
    wire w_col_end;
    wire w_piece_end;
    wire w_row_end;
    
    assign w_col_end   = (r_col   == out_x_length - 1);
    assign w_piece_end = (r_piece == in_piece     - 1);
    assign w_row_end   = (r_row   == out_y_length - 1);
    
    assign o_w_addr = r_add_address;
    assign o_rd_en  = r_rd_en;
    
    initial begin
        r_add_address <= 0;
        r_rd_en       <= 0;
    end
    
    always@(*) begin
        r_rd_en <= (r_WorkState == ADD_WBR_ADDR_GEN);
    end
    
    //state machine for generating feature address 
    always@(posedge clk or negedge rst) begin
        if (!rst)
            r_WorkState <= ADD_WBR_IDLE;
        else 
            r_WorkState <= r_WorkState_next;
    end
    
    always @(*) begin
        if (!rst)
            r_WorkState_next <= ADD_WBR_IDLE;
        else
            case (r_WorkState)
                ADD_WBR_IDLE: begin
                    if(mode == ADD_MODE && start_calculate)
                        r_WorkState_next <= ADD_WBR_ADDR_GEN;
                    else
                        r_WorkState_next <= r_WorkState;
                end
                
                ADD_WBR_ADDR_GEN: begin
                    r_WorkState_next <= ADD_WBR_WAIT;
                end
                
                ADD_WBR_WAIT: begin
                    if (w_col_end && w_piece_end && w_row_end)
                        r_WorkState_next <= ADD_WBR_IDLE;
                    else
                        r_WorkState_next <= ADD_WBR_ADDR_GEN;
                end
                
                default:
                    r_WorkState_next <= ADD_WBR_IDLE;
            endcase
    end
    
    //generate add_address
    always @(posedge clk or negedge rst) begin
        if (!rst) 
            r_add_address <= 0;
         else if(start_calculate)
         	r_add_address <= addr_start_w;
        else if (r_WorkState == ADD_WBR_ADDR_GEN)
            r_add_address <= r_add_address + 1;
        else
            r_add_address <= r_add_address;
    end
    
    //Loop 3: current column
    always @(posedge clk or negedge rst) begin
        if(!rst)
            r_col <= 0;
        else if(start_calculate)
            r_col <= 0;
        else if(r_WorkState_next == ADD_WBR_ADDR_GEN)
            if(w_col_end)
                r_col <= 0;
            else 
                r_col <= r_col + 1;
        else
            r_col <= r_col;
    end
    
    //Loop 2: current piece
    always @(posedge clk or negedge rst) begin
        if(!rst)
            r_piece <= 0;
        else if(start_calculate)
            r_piece <= 0;
        else if(r_WorkState_next == ADD_WBR_ADDR_GEN)
            if(w_col_end)
                if(w_piece_end)
                    r_piece <= 0;
                else 
                    r_piece <= r_piece + 1;
            else
                r_piece <= r_piece;
       else
            r_piece <= r_piece; 
    end
    
    //Loop 3: current row
    always @(posedge clk or negedge rst) begin
        if(!rst)
            r_row <= 0;
        else if(start_calculate)
            r_row <= 0;
        else if(r_WorkState_next == ADD_WBR_ADDR_GEN)
            if(w_col_end && w_piece_end)
                if(w_row_end)
                    r_row <= 0;
                else 
                    r_row <= r_row + 1;
            else
                r_row <= r_row;
        else
            r_row <= r_row;
    end   
       
endmodule
