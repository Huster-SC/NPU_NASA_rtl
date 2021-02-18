`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/29 20:18:07
// Design Name: 
// Module Name: IaguSort
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


module IaguSort(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from decoder
    input [12:0]addr_start_d,
    input [7:0] in_piece,
	
	//to IO buffer
	output [12:0]o_d_addr,
    output       o_rd_en,		
	
	//to npe
	output  o_sorter_out
);
    parameter INTERVAL_CYCLE = 5;
    
    reg [7:0] r_in_piece;
    reg [2:0] r_cycle_num;
    reg       r_sorter_out_en;
    reg       r_IOB_REn;
    reg [12:0]r_IOB_RAddr;
    reg       r_addr_en;
    
    wire w_in_piece_end;
    wire c_interval_end;
    
    assign  w_in_piece_end = (r_in_piece  + 12'b1 == in_piece);
    assign  c_interval_end = (r_cycle_num + 1     == INTERVAL_CYCLE);
  
    assign  o_rd_en      = r_IOB_REn;
    assign  o_d_addr     = r_IOB_RAddr;
    assign  o_sorter_out = r_sorter_out_en;
    
    initial begin
        r_IOB_REn       <= 0;
        r_IOB_RAddr     <= 0;
        r_sorter_out_en <= 0;
    end
    
    always@(posedge clk or negedge rst)begin
        if(!rst) begin
            r_IOB_REn   <= 1'd0;
            r_in_piece  <= 12'b0;
            r_IOB_RAddr <= 12'b0;
            r_addr_en   <= 1'b0;
        end
        else if(start_calculate) begin
            r_IOB_REn   <= 1'd1;
            r_in_piece  <= 12'b0;
            r_IOB_RAddr <= addr_start_d;
            r_addr_en   <= 1'b1;
        end
        else  if(w_in_piece_end) begin
            r_IOB_REn   <= 0;
            r_in_piece  <= 12'b0;
            r_IOB_RAddr <= 12'b0;
            r_addr_en   <= 1'b0;
        end else if(c_interval_end&&r_addr_en) begin 
            r_IOB_REn   <= 1'b1;
            r_in_piece  <= r_in_piece + 12'b1;
            r_IOB_RAddr <= r_IOB_RAddr + 12'b1;
            r_addr_en   <= r_addr_en;
        end
        else  begin
             r_IOB_REn   <= 0;
             r_in_piece  <= r_in_piece;
             r_IOB_RAddr <= r_IOB_RAddr;
             r_addr_en   <= r_addr_en;
        end
    end
        
        always@(posedge clk or negedge rst)begin
            if(!rst)
                r_cycle_num <= 3'b0;
            else if(start_calculate) 
                r_cycle_num <= 3'b0;
            else if(c_interval_end)
                r_cycle_num <= 3'b0;
            else  begin
                r_cycle_num <=  r_cycle_num + 3'b1;
            end
        end
            
        always@(posedge clk or negedge rst)begin
            if(!rst)
                r_sorter_out_en <= 1'b0;
            else if(w_in_piece_end)
                r_sorter_out_en <= 1'b1;
            else  begin
                r_sorter_out_en <= 1'b0;
            end
        end

endmodule
