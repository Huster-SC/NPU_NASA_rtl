`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/28 20:20:56
// Design Name: 
// Module Name: bias_addr_generate
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


module bias_addr_generate
#(
	parameter ADDR_WIDTH = 8
)(
    //from top
    input clk,
    input rst,
    
    //from schedule
    input calculate_enble,
     
    //from decoder
    input [4:0]part_num,
    input [7:0]out_piece,
    input [7:0]addr_start_b,
    
    //from wagu
    input pe_out_en,
       
    //to bias buffer
    output  [7:0] o_b_addr,
    output        o_rd_en,
    
    //for simulate
    output [7:0] o_part_num,
    output [7:0] o_out_piece,
    output       o_r_part_end    
);
//    reg [5:0]  r_part_num;
//    reg [7:0]  r_cur_outlayers;
//    reg        first_part_zero;
   
//    wire c_outlayerEn;
//    wire c_addr_En;
    
//   assign o_part_num  = r_part_num;
//   assign o_out_piece = r_cur_outlayers;

//   assign c_outlayerEn = ((r_part_num == part_num) && pe_out_en) || (first_part_zero&& pe_out_en);
//   assign o_rd_en      = c_outlayerEn ;
//   assign c_addr_En    = c_outlayerEn && (r_cur_outlayers == out_piece);

//   always@(posedge clk or negedge rst)begin
//       if(!rst)
//            r_part_num <= 6'h0;
//       else if(calculate_enble)
//            r_part_num <= 6'h0;
//       else
//            if(pe_out_en)
//                if(r_part_num == part_num )
//                    r_part_num <= 6'h1;
//                else 
//                    r_part_num <= r_part_num + 1;
//            else 
//                r_part_num <= r_part_num;
//    end 
  
//  //用来修改第一次的r_part计数器
//    always @(posedge clk or negedge rst) begin 
//        if(!rst) begin
//            first_part_zero<= 0;
//        end else if (calculate_enble) 
//            first_part_zero <= 1'b1 ;
//        else if(pe_out_en && first_part_zero)
//            first_part_zero <= 1'b0;
//        else
//            first_part_zero <= first_part_zero;  
//    end

//    always@(posedge clk or negedge rst)begin
//        if(!rst)
//            r_cur_outlayers <= 8'h0;
//        else if(calculate_enble)
//            r_cur_outlayers <= 8'h1;
//        else
//            if(c_outlayerEn)
//                if(r_cur_outlayers == out_piece)
//                    r_cur_outlayers <= 8'h1;
//                else 
//                    r_cur_outlayers <= r_cur_outlayers + 1;
//            else 
//               r_cur_outlayers <= r_cur_outlayers;
//    end 

//    always@(posedge clk or negedge rst)begin
//        if(!rst)
//            o_b_addr <= {ADDR_WIDTH{1'b0}};
//        else if(calculate_enble)
//            o_b_addr <= addr_start_b;
//        else if(o_rd_en)
//               if(c_addr_En)
//                  o_b_addr <= addr_start_b;    
//                else
//                  o_b_addr <= o_b_addr + 1;
//         else
//            o_b_addr <= o_b_addr;
//    end
    
    
    reg [7:0]r_part_num;
    reg [7:0]r_out_piece;
    reg [7:0]r_group_addr;
    reg      r_part_end;
    reg      r_out_piece_end;
    
    wire w_part_end;
    wire w_out_piece_end;
    
    assign w_part_end  = (r_part_num  == part_num  - 1);
    assign w_out_piece_end = (r_out_piece == out_piece - 1);
    
    assign o_rd_en  = pe_out_en;
    assign o_b_addr = r_group_addr;
    
    //for simulate
    assign o_part_num  = r_part_num;
    assign o_out_piece = r_out_piece;
    assign o_r_part_end = r_part_end;
    
    initial begin
        r_group_addr <= 0;
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_part_end <= 0;
        else if(w_part_end && pe_out_en)
            r_part_end <= w_part_end;
        else
            r_part_end <= 0;
    end
    
    
    //generate bias address
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_group_addr <= 0;
        else if(calculate_enble)
            r_group_addr <= addr_start_b;
        else if(r_part_end)
            if(w_out_piece_end)
                r_group_addr <= addr_start_b;
            else
                r_group_addr <= r_group_addr + 1;
        else
            r_group_addr <= r_group_addr;
    end
    
    //part count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_part_num <= 0;
        else if(calculate_enble)
            r_part_num <= 0;
        else if(pe_out_en)
            if(w_part_end)
                r_part_num <= 0;
            else
                r_part_num <= r_part_num + 1;
        else
            r_part_num <= r_part_num;   
    end
    
    //out piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_out_piece <= 0;
        else if(calculate_enble)
            r_out_piece <= 0;
        else if(w_part_end && pe_out_en)
            if(w_out_piece_end)
                r_out_piece <= 0;
            else
                r_out_piece <= r_out_piece + 1;
        else 
            r_out_piece <= r_out_piece;
    end
       
endmodule
