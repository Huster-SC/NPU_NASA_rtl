`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/28 20:15:46
// Design Name: 
// Module Name: bias
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


module bias #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16
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
    
    //from NPE
    input [511:0] npe_data_out,
    input         npe_data_valid,
    
    //from wagu
    input pe_out_en,
    
    //from bias buffer
    input [511:0] bias_data,
    input         bias_data_valid,
    
    //from Oagu
    input calculate_end,
    
    //to bias buffer
    output [7:0] o_b_addr,
    output       o_rd_en,
    
    //to relu
    output [511:0]o_bias_result,
    output        o_bias_result_valid   
    );
    
    bias_addr_generate #(
        .ADDR_WIDTH         (ADDR_WIDTH      )
    )bias_addr_gen(
         //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .calculate_enble    (calculate_enble ),
        //from decoder
        .part_num           (part_num        ),
        .out_piece          (out_piece       ),
        .addr_start_b       (addr_start_b    ),  
        //from wagu
        .pe_out_en          (pe_out_en       ),    
        //to bias buffer
        .o_b_addr           (o_b_addr        ),
        .o_rd_en            (o_rd_en         )     
    );
    
    bias_add # (
        .DATA_WIDTH         (DATA_WIDTH         )
    )bias_add(
        .npe_data           (npe_data_out       ),
        .npe_data_valid     (npe_data_valid     ),
        .bias_data          (bias_data          ),
        .bias_data_out      (o_bias_result      ),
        .bias_data_out_valid(o_bias_result_valid)
    );
    
endmodule
