`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/24 17:35:00
// Design Name: 
// Module Name: fcwagu_sim
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


module fcwagu_sim();
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from IAGU
    reg feature_load_end;
    
    //from decoder
    reg [3:0] mode;
    reg [11:0]addr_start_w;
    reg [7:0] in_piece;
    reg [7:0] out_piece;
    
     //to weight buffer
    wire [11:0]o_w_addr;
    wire       o_rd_en;
    
    //to IAGU
    wire o_group_end;
    
    //to NPE
    wire o_fc_out;
    
    wire [3:0] o_r_WorkState;
    wire [3:0] o_r_WorkState_next;
    wire [7:0] o_piece;
    wire [5:0] o_group_cnt;
    
    WaguFC
    sim_fcwagu(clk, rst, start_calculate, feature_load_end, mode, addr_start_w, in_piece, out_piece,
                o_w_addr, o_rd_en, o_group_end, o_fc_out, o_r_WorkState, o_r_WorkState_next, o_piece, o_group_cnt);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        rst          <= 1'd1;
        mode         <= 4'd2;
        addr_start_w <= 12'd0;
        in_piece     <= 8'd1;
        out_piece    <= 8'd2;
    end
    
    initial begin
        start_calculate     = 1'd0;
        #10 start_calculate = 1'd1;
        #10 start_calculate = 1'd0;
    end
    
    initial begin
        feature_load_end = 0;
        #30
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #500 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #500 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #500 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
        #500 
        feature_load_end = 1;
        #10
        feature_load_end = 0;
    end
    
endmodule
