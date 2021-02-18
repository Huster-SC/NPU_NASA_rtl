`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/24 22:07:15
// Design Name: 
// Module Name: addwagu_sim
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


module addwagu_sim();
    //from Top
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from decoder
    reg [3:0] mode;
    reg [12:0]addr_start_w;
    reg [7:0] out_x_length;
    reg [7:0] out_y_length;
    reg [7:0] in_piece;
    
    //to weight buffer
    wire [11:0]o_w_addr;
    wire       o_rd_en;
    
    WaguADD
    sim_addwagu(clk, rst, start_calculate, mode, addr_start_w, out_x_length, out_y_length, in_piece,
                o_w_addr, o_rd_en);
                
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        rst          <= 1'd1;
        mode         <= 4'd3;
        addr_start_w <= 13'd0;
        out_x_length <= 8'd2;
        out_y_length <= 8'd2;
        in_piece     <= 8'd2;
    end
    
    initial begin
        start_calculate = 0;
        #15 start_calculate = 1;
        #10 start_calculate = 0;
    end

endmodule
