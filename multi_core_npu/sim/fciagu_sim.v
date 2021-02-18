`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/25 16:20:26
// Design Name: 
// Module Name: fciagu_sim
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


module fciagu_sim();
    //from Top
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from IAGU
    reg weight_load_end;
    
    //from decoder
    reg [11:0]addr_start_d;
    reg [7:0] in_piece;
    reg [7:0] out_piece;
    reg [1:0] tilingtype;
    
    //to IO buffer
    wire [11:0]o_d_addr;
    wire       o_rd_en;
    
    //to WAGU
    wire       o_feature_end;
    
    wire       [2:0] WorkState;
    wire       [2:0] WorkState_next;
    
    IaguFC
    sim_fciagu(clk, rst, start_calculate, weight_load_end, addr_start_d, in_piece, out_piece, tilingtype,
                o_d_addr, o_rd_en, o_feature_end, WorkState, WorkState_next);
    
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
        addr_start_d    <= 12'd1;       
        in_piece        <= 8'd2;
        out_piece       <= 8'd2;
    end
    
    initial begin
        weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0; 
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        #50 weight_load_end = 1;
        #10 weight_load_end = 0;
        
    end
    
endmodule
