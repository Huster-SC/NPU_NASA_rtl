`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/25 11:33:57
// Design Name: 
// Module Name: IaguFC
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


module IaguFC(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from IAGU
    input weight_load_end,
    
    //from decoder
    input [12:0]addr_start_d,
    input [7:0] in_piece,
    input [7:0] out_piece,
    input [1:0] tilingtype,
    
    //to IO buffer
    output [12:0]o_d_addr,
    output       o_rd_en,
    
    //to WAGU
    output       o_feature_end
    
    //for simulation
//    output [2:0] WorkState,
//    output [2:0] WorkState_next
    );
    
    //for state machine
    parameter [2:0] IBR_IDLE              = 3'd0,
                    IBR_ADDR_GEN          = 3'd1,
                    IBR_JUDGE_END         = 3'd2,
                    IBR_UPDATE_COORDINATE = 3'd3,
                    IBR_WAIT_GROUP        = 3'd4;
    reg [2:0] r_WorkState,r_WorkState_next;
    
    wire w_in_piece_end;
    wire w_out_piece_end;
    wire w_tiling_end;
    wire w_feature_end;
    
    reg [7:0] r_in_piece;
    reg [7:0] r_out_piece;
    reg [12:0]r_group_addr;
    reg       r_rd_en;
    //Because WaguFC's state machine need three cycles to judge and update coordinate,
    //So delay two cycles to output feature_end signal
    reg       r_feature_end;
    reg       r1_feature_end;
    reg       r2_feature_end;
    
    assign w_in_piece_end  = (r_in_piece  == in_piece  - 1);
    assign w_out_piece_end = (r_out_piece == out_piece - 1);
    assign w_tiling_end    =  w_in_piece_end && w_out_piece_end;
    assign w_feature_end   = (r_WorkState == IBR_ADDR_GEN);
    
    assign o_d_addr      = r_group_addr;
    assign o_rd_en       = r_rd_en;
    assign o_feature_end = r1_feature_end;
    
    always@(*) begin
        r_rd_en = (r_WorkState == IBR_ADDR_GEN);
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_feature_end  <= 0;
            r1_feature_end <= 0;
            r2_feature_end <= 0;            
        end else begin
            r_feature_end  <= w_feature_end;
            r1_feature_end <= r_feature_end;
            r2_feature_end <= r1_feature_end;
        end      
    end
    
    //for simulation
//    assign WorkState      = r_WorkState; 
//    assign WorkState_next = r_WorkState_next;
    
    initial begin
        r_group_addr  <= 0;
        r_rd_en       <= 0;
        r_feature_end <= 0;
        r1_feature_end <= 0;
        r2_feature_end <= 0;
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
                        r_WorkState_next = IBR_ADDR_GEN;
                    else
                        r_WorkState_next = r_WorkState;     
                end
                
                IBR_ADDR_GEN: begin
                    r_WorkState_next = IBR_JUDGE_END;
                end
                
                IBR_JUDGE_END: begin
                //need to consider tiling end 
                    if(w_tiling_end)
                        r_WorkState_next = IBR_IDLE;
                    else
                        r_WorkState_next = IBR_UPDATE_COORDINATE;
                end
                
                IBR_UPDATE_COORDINATE: begin
                    r_WorkState_next = IBR_WAIT_GROUP;
                end 
                
                IBR_WAIT_GROUP: begin
                    if(weight_load_end)
                        r_WorkState_next = IBR_ADDR_GEN;
                    else
                        r_WorkState_next = r_WorkState; 
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
            r_group_addr <= addr_start_d; 
        else if(r_WorkState == IBR_ADDR_GEN) 
            if(w_in_piece_end)
                r_group_addr <= addr_start_d;
            else
                r_group_addr <= r_group_addr + 1;
        else
            r_group_addr <= r_group_addr;                       
    end
    
    //Loop 2: in_piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_in_piece <= 0;
        else if(start_calculate)
            r_in_piece <= 0;
        else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_in_piece_end)
                r_in_piece <= 0;
            else
                r_in_piece <= r_in_piece + 1;
        end else 
            r_in_piece <= r_in_piece;
    end
    
    //Loop 1: out_piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_out_piece <= 0;
        else if(start_calculate)
            r_out_piece <= 0;
        else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
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
    
endmodule
