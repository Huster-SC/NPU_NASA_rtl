`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/24 15:34:50
// Design Name: 
// Module Name: WaguFC
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


module WaguFC(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from IAGU
    input feature_load_end,
    
    //from decoder
    input [3:0] mode,
    input [12:0]addr_start_w,
    input [7:0] in_piece,
    input [7:0] out_piece,
    
    //to weight buffer
    output [12:0]o_w_addr,
    output       o_rd_en,
    
    //to IAGU
    output       o_group_end,
    output [7:0] o_pe_en,
    
    //to NPE
    output o_fc_out
    
    //for simulation
//    output [3:0] o_r_WorkState,
//    output [3:0] o_r_WorkState_next,
//    output [7:0] o_piece,
//    output [5:0] o_group_cnt
    );
    
    //chanel_num in one piece
    parameter [5:0]group_num = 6'd32;
    
    //mode map
    parameter [3:0] CONV_MODE = 4'd1,
                    POOL_MODE = 4'd4,
                    FC_MODE   = 4'd2,
                    ADD_MODE  = 4'd3;
                    //MATRIX_MODE = 4'd6;
    
    //for state machine
    parameter [2:0] WBR_IDLE                = 3'd0,
                    WBR_START_READY         = 3'd1,                 
                    WBR_ADDR_GEN            = 3'd2,
                    WBR_JUDGE_END           = 3'd3,
                    WBR_UPDATE_COORDINATE   = 3'd4; 
    reg [3:0] r_WorkState, r_WorkState_next;
    
    wire w_group_end;
    wire w_in_piece_end;
    wire w_out_piece_end;
    wire w_tiling_end;
    
    reg [12:0]r_group_addr;
    reg [5:0] r_group_cnt;
    reg [7:0] r_in_piece;
    reg [7:0] r_out_piece;
    
    //for output
    reg [12:0]r_w_addr;
    reg       r_rd_en;
    reg       r_group_end;
    reg       r_fc_out;
    reg [7:0] r_pe_en;
    
    assign o_group_end = r_group_end;
    assign o_w_addr    = r_group_addr;
    assign o_rd_en     = r_rd_en;
    assign o_fc_out    = r_fc_out;
    assign o_pe_en     = r_pe_en;
    
    assign w_group_end      = (r_group_cnt == group_num - 1);
    assign w_in_piece_end   = (r_in_piece  == in_piece  - 1);
    assign w_out_piece_end  = (r_out_piece == out_piece - 1);
    assign w_tiling_end     = w_in_piece_end && w_out_piece_end;
    
    //for simulation
//    assign o_r_WorkState      = r_WorkState;
//    assign o_r_WorkState_next = r_WorkState_next;
//    assign o_group_cnt        = r_group_cnt;
//    assign o_piece            = r_in_piece;
    
    initial begin
        r_group_addr <= 0;
        r_rd_en      <= 0;
        r_group_end  <= 0;
        r_fc_out     <= 0;
        r_pe_en      <= 0;
    end
    
    always@(*) begin
        r_w_addr    <= r_group_addr;
        r_rd_en     <= (r_WorkState == WBR_ADDR_GEN);
        r_group_end <= w_group_end;
        r_fc_out    <= (r_WorkState == WBR_JUDGE_END) && w_in_piece_end;
    end 
    
    //state machine for generating weight address 
    always@(posedge clk or negedge rst) begin
        if (!rst)
            r_WorkState <= WBR_IDLE ;
        else 
            r_WorkState <= r_WorkState_next;
    end
    
    always@(*) begin
        if (!rst)
            r_WorkState_next = WBR_IDLE;
        else begin
            case (r_WorkState)
                WBR_IDLE: begin
                    if(mode == FC_MODE && start_calculate)
                        r_WorkState_next = WBR_START_READY;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                WBR_START_READY: begin
                    if(feature_load_end)
                       r_WorkState_next = WBR_ADDR_GEN;                                                                
                    else
                       r_WorkState_next = r_WorkState; 
                end
            
                WBR_ADDR_GEN: begin
                    if (w_group_end) 
                        r_WorkState_next = WBR_JUDGE_END;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                WBR_JUDGE_END: begin
                //here: need to consider both feature and weight tiling end 
                    if(w_tiling_end)
                        r_WorkState_next = WBR_IDLE;
                    else
                        r_WorkState_next = WBR_UPDATE_COORDINATE;
                end
                
                WBR_UPDATE_COORDINATE:begin
                    r_WorkState_next = WBR_START_READY;
                end
                
                default:
                    r_WorkState_next = WBR_IDLE; 
            endcase
        end 
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_group_addr <= 0;
        end else if(r_WorkState == WBR_IDLE) begin
            if(start_calculate) begin
                r_group_addr <= addr_start_w;
            end else    
                r_group_addr <= 0;
        end else if(r_WorkState == WBR_ADDR_GEN) begin
            if(r_group_cnt == group_num) begin
                r_group_addr <= r_group_addr;
            end else begin  
                r_group_addr <= r_group_addr + 1;
            end
        end else
            r_group_addr <= r_group_addr;  
    end
    
    //Loop 3: group count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_group_cnt <= 0;
        else if(start_calculate || r_WorkState == WBR_UPDATE_COORDINATE)
            r_group_cnt <= 0;
        else if(r_WorkState == WBR_ADDR_GEN) begin
            if(r_group_cnt == group_num)
                r_group_cnt <= 0;
            else 
                r_group_cnt <= r_group_cnt + 1; 
        end else
            r_group_cnt <= 0;
    end
    
    //Loop 2: input piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_in_piece <= 0;
        else if(start_calculate)
            r_in_piece <= 0;
        else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
                if(w_in_piece_end)
                    r_in_piece <= 0;
                else
                    r_in_piece <= r_in_piece + 1;
        end else
            r_in_piece <= r_in_piece;
    end
    
    //Loop 1: output piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_out_piece <= 0;
        else if(start_calculate)
            r_out_piece <= 0;
        else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_in_piece_end)
                if(w_out_piece_end)
                    r_out_piece <= 0;
                else
                    r_out_piece <= r_out_piece + 1;
            else
                r_out_piece <= r_out_piece;            
        end else
            r_out_piece <= r_out_piece;
    end
    
    //need to decide next pe_en(which pe to be used)
    always @(posedge clk or negedge rst) begin
        if (!rst)
            r_pe_en <= 0;
        else
            if (start_calculate || r_fc_out)
                r_pe_en <= 8'b00000001;
            else
                r_pe_en <= r_pe_en;
    end
    
endmodule
