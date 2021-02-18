`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/28 21:42:45
// Design Name: 
// Module Name: biasagu_sim
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


module biasagu_sim();
    //from top
    reg clk;
    reg rst;
    
    //from schedule
    reg calculate_enble;
     
    //from decoder
    reg [4:0]part_num;
    reg [7:0]out_piece;
    reg [7:0]addr_start_b;
    
    //from wagu
    reg pe_out_en;
       
    //to bias buffer
    wire [7:0] o_b_addr;
    wire       o_rd_en;
    
    //for simulate
    wire [7:0] o_part_num;
    wire [7:0] o_out_piece; 
    wire       o_r_part_end;
    
    bias_addr_generate
    sim_bias_gen(clk, rst, calculate_enble, part_num, out_piece, addr_start_b, pe_out_en, o_b_addr, o_rd_en, o_part_num, o_out_piece, o_r_part_end);
    
    initial begin 
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        calculate_enble     = 1'd0;
        #10 calculate_enble = 1'd1;
        #10 calculate_enble = 1'd0;
    end
    
    initial begin
        rst          <= 1'd1;
        part_num     <= 5'd3;
        out_piece    <= 8'd3;
        addr_start_b <= 8'd0;
    end
    
    initial begin
        pe_out_en       = 1'b0;
        #30 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
        #20 pe_out_en   = 1'b1;
        #10 pe_out_en   = 1'b0;
    end
     
endmodule
