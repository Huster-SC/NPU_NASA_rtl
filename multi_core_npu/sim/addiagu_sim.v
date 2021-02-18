`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/30 15:45:38
// Design Name: 
// Module Name: addiagu_sim
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


module addiagu_sim();
    //from Top
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from decoder
    reg [12:0]addr_start_d;
    reg [7:0] out_x_length;
    reg [7:0] out_y_length;
    reg [7:0] in_piece;
    
    //to IO buffer
    wire [12:0]o_d_addr;
    wire       o_rd_en;
    wire       o_feature_end;
    
    IaguADD
    sim_addiagu(clk, rst, start_calculate, addr_start_d, out_x_length, out_y_length, in_piece,
                o_d_addr, o_rd_en, o_feature_end);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        start_calculate = 0;
        #15 start_calculate = 1;
        #10 start_calculate = 0;
    end
    
    initial begin
        rst          <= 1'd1;
        addr_start_d <= 13'd0;
        out_x_length <= 8'd2;
        out_y_length <= 8'd2;
        in_piece     <= 8'd2;
    end
    
    
endmodule
