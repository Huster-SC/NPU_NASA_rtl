`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/24 15:29:02
// Design Name: 
// Module Name: Wagu
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


module Wagu(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
     //from IAGU
    input feature_load_end,
    input add_start,
    
    //from decoder
    input [3:0] mode,
    input [12:0]addr_start_w,
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
    
    //to weight buffer
    output [12:0]o_rd_addr,
    output       o_rd_en,
    
    //to IAGU
    output o_group_end,
    
    //to NPE
    output       o_conv_out,
    output       o_fc_out,
    output [7:0] o_pe_en
    );
    
    //to weight buffer
    wire [12:0]w_conv_rd_addr;
    wire [12:0]w_fc_rd_addr;
    wire [12:0]w_add_rd_addr;
    wire [12:0]w_depthconv_rd_addr;
    wire       w_conv_rd_en;
    wire       w_fc_rd_en;
    wire       w_add_rd_en;
    wire       w_depthconv_rd_en; 
    
    //to IAGU
    wire w_conv_group_end;
    wire w_fc_group_end;
    wire w_depthconv_group_end;
    
    //to NPE
    wire      w_conv_result_out;
    wire      w_fc_result_out;
    wire      w_depthconv_result_out;
    wire [7:0]w_conv_pe_en;
    wire [7:0]w_fc_pe_en;
    wire [7:0]w_depthconv_pe_en;
    
    assign o_rd_addr    = w_conv_rd_addr    | w_fc_rd_addr   | w_add_rd_addr | w_depthconv_rd_addr;
    assign o_rd_en      = w_conv_rd_en      | w_fc_rd_en     | w_add_rd_en   | w_depthconv_rd_en;
    assign o_group_end  = w_conv_group_end  | w_fc_group_end | w_depthconv_group_end;
    assign o_pe_en      = w_conv_pe_en      | w_fc_pe_en     | w_depthconv_pe_en;
    assign o_conv_out   = w_conv_result_out | w_depthconv_result_out;
    assign o_fc_out     = w_fc_result_out;
    
    WaguConvolution 
    conv_weight_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),                           
        //from schedule     
        .start_calculate    (start_calculate ),                            
        //from IAGU         
        .feature_load_end   (feature_load_end), 
        //from decoder
        .mode               (mode            ),
        .addr_start_w       (addr_start_w    ),
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
        //to weight buffer
        .o_w_addr           (w_conv_rd_addr  ),
        .o_rd_en            (w_conv_rd_en    ),
        //to IAGU
        .o_group_end        (w_conv_group_end),   
        //to NPE
        .o_conv_out         (w_conv_result_out),
        .o_pe_en            (w_conv_pe_en     )
    );
    
    WaguDepthConvolution
    depthconv_weight_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),                           
        //from schedule     
        .start_calculate    (start_calculate ),                            
        //from IAGU         
        .feature_load_end   (feature_load_end), 
        //from decoder
        .mode               (mode            ),
        .addr_start_w       (addr_start_w    ),
        .in_y_length        (in_y_length     ),
        .in_piece           (in_piece        ),
        .out_y_length       (out_y_length    ),
        .part_num           (part_num        ),
        .last_part          (last_part       ),
        .i_kernel           (i_kernel        ),
        .i_stride           (i_stride        ),
        .i_pad              (i_pad           ),
        .tilingtype         (tilingtype      ),
        //to weight buffer
        .o_w_addr           (w_depthconv_rd_addr    ),
        .o_rd_en            (w_depthconv_rd_en      ),
        //to IAGU
        .o_group_end        (w_depthconv_group_end  ),   
        //to NPE
        .o_depthconv_out    (w_depthconv_result_out ),
        .o_pe_en            (w_depthconv_pe_en      )
    );
    
    WaguFC
    fc_weight_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),                           
        //from schedule     
        .start_calculate    (start_calculate ),                            
        //from IAGU         
        .feature_load_end   (feature_load_end),
        //from decoder
        .mode               (mode            ),
        .addr_start_w       (addr_start_w    ),
        .in_piece           (in_piece        ),
        .out_piece          (out_piece       ),    
        //to weight buffer
        .o_w_addr           (w_fc_rd_addr    ),
        .o_rd_en            (w_fc_rd_en      ),
        //to IAGU
        .o_group_end        (w_fc_group_end  ),   
        //to NPE
        .o_fc_out           (w_fc_result_out ),
        .o_pe_en            (w_fc_pe_en      )
    ); 
    
    WaguADD
    add_addr_generate(
        //from Top
        .clk                (clk             ),
        .rst                (rst             ),                           
        //from schedule     
        .start_calculate    (add_start       ),
        //from decoder   
        .mode               (mode            ),
        .in_piece           (in_piece        ),
        .addr_start_w       (addr_start_w    ),
        .out_x_length       (out_x_length    ),
        .out_y_length       (out_y_length    ),
        //to weight buffer
        .o_w_addr           (w_add_rd_addr   ),
        .o_rd_en            (w_add_rd_en     )
    );        
    
endmodule
