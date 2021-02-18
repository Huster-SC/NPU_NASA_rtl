`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/28 19:57:58
// Design Name: 
// Module Name: XPE
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


module XPE # (
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16
)(
    //from top
    input clk,
    input rst,
    
    //from schedule
    input calculate_enble,
    
    input i_sort_en,
    
    //from decoder
    input [3:0]mode,
    input [1:0]xpe_mode,
    input [4:0]part_num,
    input [7:0]out_piece,
    input [7:0]addr_start_b,
    input [3:0]i_q_encode,
    input [3:0]w_q_encode,
    input [3:0]o_q_encode,
    input [7:0]avg_pooling_coe,
    
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
    
    //to IO buffer
    output [255:0] o_xpe_data_out,
    output         o_xpe_data_valid
    
    //for simulation
//    output [511:0] o_relu_out,
//    output [511:0] o_final_round,
//    output [255:0] o_round_out                  
  );
    
    parameter [3:0]PARA_MODE_CONV     = 4'd1;
    parameter [3:0]PARA_MODE_FC       = 4'd2;
    parameter [3:0]PARA_MODE_ADD      = 4'd3;
    parameter [3:0]PARA_MODE_POOL     = 4'd4;
    parameter [3:0]PARA_MODE_AVG_POOL = 4'd5;
    
    parameter [1:0]PARA_RELU = 2'd1;
    
    wire shift_en;
    //for bias
    wire bias_en;
    wire [7:0] w_bias_addr;
    wire       w_rd_en;
    
    //to relu
    wire [511:0]w_bias_result;
    wire        w_bias_result_valid;
    wire [511:0]w_relu_result; 
    
    //for avg pooling round
    wire [3:0]  using_i_q_encode;
    wire [3:0]  using_w_q_encode;
    wire [3:0]  using_o_q_encode;
    wire [1:0]  using_round_mode;
    wire [255:0]round_out_avg;
    wire [511:0]avg_pooling_result;
    
    //for normal round
    wire [511:0]i_final_round;
    wire [255:0]round_xpe_data_out;
    
    //for output
    wire bypass_xpe;
    
    reg [511:0]r_npe_data_out;
    reg        r_npe_data_valid;
    
    reg r_xpe_data_vld_r ;
    reg r_xpe_data_vld_r1;
    reg r_xpe_data_vld_r2;
    
    assign  shift_en         = (mode==PARA_MODE_ADD)      ? 1'b0 : 1'b1;
    assign  using_i_q_encode = (mode==PARA_MODE_AVG_POOL) ? 4'h0 : i_q_encode;
    assign  using_w_q_encode = (mode==PARA_MODE_AVG_POOL) ? 4'h0 : w_q_encode;
    assign  using_o_q_encode = (mode==PARA_MODE_AVG_POOL) ? 4'h0 : o_q_encode;
    assign  using_round_mode = (mode==PARA_MODE_AVG_POOL) ? 2'd0 : 2'd1;
    
    //output
    assign  bypass_xpe = |{ i_sort_en ,mode == PARA_MODE_POOL }; 
    assign  o_b_addr   = w_bias_addr;
    assign  o_rd_en    = w_rd_en;
    assign  o_xpe_data_out   = bypass_xpe ? npe_data_out[255:0] : round_xpe_data_out;
    assign  o_xpe_data_valid = bypass_xpe                    ? npe_data_valid   : 
                               ((mode == PARA_MODE_AVG_POOL) ? r_xpe_data_vld_r2 : r_xpe_data_vld_r1); //modify here
    
    //for simulation
//    assign o_relu_out = w_relu_result;
//    assign o_final_round = i_final_round;
//    assign o_round_out = round_xpe_data_out;
    
    initial begin
        r_npe_data_out   <= 0;
        r_npe_data_valid <= 0;    
    end
    
    always@(posedge clk or negedge rst)begin
        if(!rst)
            r_npe_data_valid <= 0;
        else
            r_npe_data_valid <= npe_data_valid;    
    end
    
    always@(posedge clk or negedge rst)begin
        if(!rst)
            r_npe_data_out <= 0;
        else if(npe_data_valid)
            r_npe_data_out <= npe_data_out;
        else
            r_npe_data_out <= 0;
    end
    
    //for decide when the XPE output is valid
    always@(posedge clk or negedge rst) begin
        if( !rst ) begin
            r_xpe_data_vld_r  <= 1'b0;
            r_xpe_data_vld_r1 <= 1'b0;
            r_xpe_data_vld_r2 <= 1'b0;
        end
        else begin
            r_xpe_data_vld_r  <= npe_data_valid;
            r_xpe_data_vld_r1 <= r_xpe_data_vld_r;
            r_xpe_data_vld_r2 <= r_xpe_data_vld_r1;
         end
    end

/////////////////////////////// Bias and Relu /////////////////////////// 
    assign bias_en = (mode == PARA_MODE_CONV || mode == PARA_MODE_FC);
   
    bias 
    bias(
        //from Top
        .clk                (clk                       ),
        .rst                (rst                       ),
        //from schedule
        .calculate_enble    (calculate_enble && bias_en),
        //from decoder
        .part_num           (part_num                  ),
        .out_piece          (out_piece                 ),
        .addr_start_b       (addr_start_b              ),
        //from npe
        .npe_data_out       (npe_data_out              ),
        .npe_data_valid     (npe_data_valid            ),
        //from wagu
        .pe_out_en          (pe_out_en                 ),
        //from bias buffer
        .bias_data          (bias_data                 ),
        .bias_data_valid    (bias_data_valid           ),
        //from oagu
        .calculate_end      (calculate_end             ),
        //to bias buffer
        .o_b_addr           (w_bias_addr               ),
        .o_rd_en            (w_rd_en                   ),
        //to relu
        .o_bias_result      (w_bias_result             ),
        .o_bias_result_valid(w_bias_result_valid       )
    );
    
    relu 
    relu(
        .calculate_en       (xpe_mode == PARA_RELU),
	    .bias_data          (r_npe_data_out       ),	
	    .o_relu_data        (w_relu_result        )
    );
////////////////////////////////////////////////////////////////////////

////////////////////////////// Avg Pooling /////////////////////////////    
    round32X16 
    round_for_avg_pooling(
        .i_clk        (clk              ),
        .i_rst_n      (rst              ),
        .i_q_encode   (i_q_encode       ),
        .w_q_encode   (using_w_q_encode ),
        .o_q_encode   (using_o_q_encode ),
        .i_bias_dat   (r_npe_data_out   ),
        .i_shift_en   (shift_en         ),
        .i_round_mode (using_round_mode ),
        .o_round_dat  (round_out_avg    )
    );
    
    avg_pooling 
    avg_pooling(
        .i_clk       (clk               ),
        .i_rst_n     (rst               ),
        .i_wdata     (avg_pooling_coe   ),
        .i_mdata     (round_out_avg     ),
        .o_mul_result(avg_pooling_result)
    );
/////////////////////////////////////////////////////////////////////////// 

////////////////////////////// Final Round /////////////////////////////////
    assign  i_final_round    = ( mode == PARA_MODE_ADD)      ? r_npe_data_out :
                               ((mode == PARA_MODE_AVG_POOL) ? avg_pooling_result : w_relu_result);
    
    round32X16
    final_round(
        .i_clk        (clk               ),
        .i_rst_n      (rst               ),
        .i_q_encode   (using_i_q_encode  ),
        .w_q_encode   (w_q_encode        ),
        .o_q_encode   (o_q_encode        ),
        .i_bias_dat   (i_final_round     ),
        .i_shift_en   (shift_en          ),
        .i_round_mode (2'd1              ),
        .o_round_dat  (round_xpe_data_out)    
    );
////////////////////////////////////////////////////////////////////////

   
endmodule
