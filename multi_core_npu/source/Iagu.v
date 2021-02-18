`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/25 11:30:58
// Design Name: 
// Module Name: Iagu
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


module Iagu(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from IAGU
    input weight_load_end,
    
    //from decoder
    input [3:0] mode,
    input [12:0]addr_start_d,
    input [7:0] in_x_length,
    input [7:0] in_y_length,
    input [7:0] in_piece,
    input [7:0] out_x_length,
    input [7:0] out_y_length,
    input [7:0] out_piece,
    input [4:0] part_num,
    input [3:0] last_part,
    input [3:0] i_kernel,
    input [1:0] i_stride,
    input [1:0] i_pad,
    input [1:0] tilingtype,
    input       i_sort_en,
    
    //to IO buffer
    output [12:0]o_rd_addr,
    output       o_rd_en,
    output       o_pad_en,
    
    //to WAGU
    output       o_feature_end,
    output       o_add_start,
    //to NPE
    output       o_pooling_out,
    output       o_sort_out
    );
    
    parameter [3:0]PARA_MODE_CONV = 4'd1;
    parameter [3:0]PARA_MODE_FC   = 4'd2;
    parameter [3:0]PARA_MODE_ADD  = 4'd3;  
    parameter [3:0]PARA_MODE_POOL = 4'd4;  
    parameter [3:0]PARA_MODE_ACC  = 4'd5;
    parameter [3:0]PARA_MODE_DEPTHCONV = 4'd6;
    
    //to IO buffer   
    wire [12:0]w_conv_rd_addr;
    wire [12:0]w_depthconv_rd_addr;
    wire [12:0]w_fc_rd_addr;
    wire [12:0]w_add_rd_addr;
    wire [12:0]w_pool_rd_addr;
    wire [12:0]w_sort_rd_addr;
    wire       w_conv_rd_en;
    wire       w_depthconv_rd_en;
    wire       w_fc_rd_en;
    wire       w_add_rd_en;
    wire       w_pool_rd_en;
    wire       w_sort_rd_en;
    wire       w_conv_pad_en;
    wire       w_depthconv_pad_en;
    //to WAGU
    wire       w_conv_feature_end;
    wire       w_depthconv_feature_end;
    wire       w_fc_feature_end;
    wire       w_add_start;
    //to NPE
    wire       w_pooling_out;
    wire       w_sort_out; 
    
    assign o_rd_addr     = w_conv_rd_addr | w_fc_rd_addr | w_add_rd_addr | w_pool_rd_addr | w_sort_rd_addr | w_depthconv_rd_addr;
    assign o_rd_en       = w_conv_rd_en   | w_fc_rd_en   | w_add_rd_en   | w_pool_rd_en   | w_sort_rd_en   | w_depthconv_rd_en;
    assign o_pad_en      = w_conv_pad_en  | w_depthconv_pad_en;
    assign o_feature_end = w_conv_feature_end | w_fc_feature_end | w_depthconv_feature_end;
    assign o_add_start   = w_add_start;
    assign o_pooling_out = w_pooling_out;
    assign o_sort_out    = w_sort_out;
    
    IaguConvolution
    conv_feature_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .start_calculate    (start_calculate && mode == PARA_MODE_CONV),
        //from Wagu
        .weight_load_end    (weight_load_end ),
        //from decoder
        .addr_start_d       (addr_start_d    ),
        .in_x_length        (in_x_length     ),
        .in_y_length        (in_y_length     ),
        .in_piece           (in_piece        ),
        .out_x_length       (out_x_length    ),
        .out_y_length       (out_y_length    ),
        .out_piece          (out_piece       ),
        .part_num           (part_num        ),
        .last_part          (last_part       ),
        .i_kernel           (i_kernel        ),
        .i_stride           (i_stride        ),
        .i_pad              (i_pad           ),
        .tilingtype         (tilingtype      ),
        //to IO buffer
        .o_d_addr           (w_conv_rd_addr  ),
        .o_rd_en            (w_conv_rd_en    ),
        .o_pad_en           (w_conv_pad_en   ),
        //to WAGU
        .o_feature_end      (w_conv_feature_end)
    );
    
    IaguDepthConvolution
    depthconv_feature_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .start_calculate    (start_calculate && mode == PARA_MODE_DEPTHCONV),
        //from Wagu
        .weight_load_end    (weight_load_end ),
        //from decoder
        .addr_start_d       (addr_start_d    ),
        .in_x_length        (in_x_length     ),
        .in_y_length        (in_y_length     ),
        .in_piece           (in_piece        ),
        .out_y_length       (out_y_length    ),
        .part_num           (part_num        ),
        .last_part          (last_part       ),
        .i_kernel           (i_kernel        ),
        .i_stride           (i_stride        ),
        .i_pad              (i_pad           ),
        .tilingtype         (tilingtype      ),
        //to IO buffer
        .o_d_addr           (w_depthconv_rd_addr  ),
        .o_rd_en            (w_depthconv_rd_en    ),
        .o_pad_en           (w_depthconv_pad_en   ),
        //to WAGU
        .o_feature_end      (w_depthconv_feature_end)            
    );
    
    IaguFC
    fc_feature_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .start_calculate    (start_calculate && mode == PARA_MODE_FC),
        //from Wagu
        .weight_load_end    (weight_load_end ),
        //from decoder
        .addr_start_d       (addr_start_d    ),
        .in_piece           (in_piece        ),
        .out_piece          (out_piece       ),
        .tilingtype         (tilingtype      ),
        //to IO buffer
        .o_d_addr           (w_fc_rd_addr    ),
        .o_rd_en            (w_fc_rd_en      ),
        //to WAGU
        .o_feature_end      (w_fc_feature_end)
    );
    
    IaguADD
    add_feature_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .start_calculate    (start_calculate && mode == PARA_MODE_ADD),
        //from decoder
        .addr_start_d       (addr_start_d    ),
        .in_piece           (in_piece        ),
        .out_x_length       (out_x_length    ),
        .out_y_length       (out_y_length    ),    
        //to IO buffer
        .o_d_addr           (w_add_rd_addr   ),
        .o_rd_en            (w_add_rd_en     ),
        //to WAGU
        .o_add_start        (w_add_start     )
    );
    
    IaguPooling
    pooling_feature_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .start_calculate    (start_calculate && (mode == PARA_MODE_POOL || mode == PARA_MODE_ACC)),    
        //from decoder
        .addr_start_d       (addr_start_d    ),
        .in_x_length        (in_x_length     ),
        .out_x_length       (out_x_length    ),
        .out_y_length       (out_y_length    ),
        .in_piece           (in_piece        ),
        .i_kernel           (i_kernel        ),
        .i_stride           (i_stride        ),
        //to IO buffer
        .o_d_addr           (w_pool_rd_addr  ),
        .o_rd_en            (w_pool_rd_en    ),
        //to NPE
        .o_pooling_out      (w_pooling_out   )
    );
    
    IaguSort
    sort_feature_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),
        //from schedule     
        .start_calculate    (start_calculate && i_sort_en),    
        //from decoder
        .addr_start_d       (addr_start_d    ),
        .in_piece           (in_piece        ),
        //to IO buffer
        .o_d_addr           (w_sort_rd_addr  ),
        .o_rd_en            (w_sort_rd_en    ),
        //to NPE
        .o_sorter_out       (w_sort_out      )
    );
    
endmodule
