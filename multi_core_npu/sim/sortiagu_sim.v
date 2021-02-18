`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/29 20:41:34
// Design Name: 
// Module Name: sortiagu_sim
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


module sortiagu_sim();
    //from Top
    reg clk;
    reg rst;
    
    //from schedule
    reg start_calculate;
    
    //from decoder
    reg [11:0]addr_start_d;
    reg [7:0] in_piece;
	
	//to IO buffer
	wire [11:0]o_d_addr;
    wire       o_rd_en;	
	
	//to npe
	wire  o_sorter_out;
	
	IaguSort
	sim_sortiagu(clk, rst, start_calculate, addr_start_d, in_piece, o_d_addr, o_rd_en, o_sorter_out);
	
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
        rst          <= 1'b1;
        addr_start_d <= 1'b0;
        in_piece     <= 8'd32;
    end
      
endmodule
