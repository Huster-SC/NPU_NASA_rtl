`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/16 17:10:22
// Design Name: 
// Module Name: simply_npu
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


module simply_npu(
        //from Top
        input clk,
        input rst,
        
        //from and to schedule
        input         start_calculate,
        output        o_calculate_end,
//        input  [127:0]inst_in,
//        input         inst_valid,  
        //from decoder
        input [3:0] i_mode,
        input [1:0] i_xpe_mode,
        input [12:0]i_addr_start_w,
        input [12:0]i_addr_start_d,
        input [7:0] i_addr_start_b,
        input [12:0]i_addr_start_s,
        input [7:0] i_in_x_length,
        input [7:0] i_in_y_length,
        input [7:0] i_in_piece,
        input [7:0] i_out_x_length,
        input [7:0] i_out_y_length,
        input [7:0] i_out_piece,
        input [4:0] i_part_num,
        input [3:0] i_last_part,
        input [3:0] i_kernel,
        input [1:0] i_stride,
        input [1:0] i_pad,
        input [1:0] i_tilingtype,
        input [3:0] i_i_q_encode,
        input [3:0] i_w_q_encode,
        input [3:0] i_o_q_encode,
        input [7:0] i_avg_pooling_coe,
        input [1:0] i_buffer_flag,
        input [7:0] i_store_length,
        input [7:0] i_jump_length,
        input       i_sort_en,
        
        //for Globle_Buffer
        (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM EN"      *)
        input          i_gb_bramctl_en, // Chip Enable Signal (optional)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DOUT"    *)
        output [255:0] o_gb_bramctl_rdata, // Data Out Bus (optional)
        output         o_gb_bramctl_rvld,
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DIN"     *)
        input [255:0]  i_gb_bramctl_wdata, // Data In Bus (optional)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM WE"      *)
        input          i_gb_bramctl_we, // Byte Enables (optional)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM ADDR"    *)
        input [12:0]   i_gb_bramctl_addr, // Address Signal (required)                                  
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM CLK"     *)
        input          i_gb_bramctl_s_clk, // Clock Signal (required)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM RST"     *)
        input          i_gb_bramctl_s_rst // Reset Signal (required)
        
    );
    
    wire w_feature_load_end;
    wire w_weight_group_end;
    wire w_add_start;
    wire w_calculate_end;
    wire w_conv_out;
    wire w_fc_out;
    wire w_pooling_out;
    wire w_sort_out;
    wire w_pe_out;
    
    wire [7:0]   w_pe_en;
    wire [511:0] w_npe_result;
    wire         w_npe_result_vld;
    
    wire [255:0] w_xpe_data_out;
    wire         w_xpe_data_valid;
    
    //from and to Globle Buffer
    wire [12:0] w_gb_rd_addr;
    wire        w_gb_rd_en;
    wire        w_gb_pad_en;
    wire [12:0] w_gb_w_addr;
    wire        w_gb_w_en;
    wire [255:0]w_gb_w_data;
    wire [255:0]w_gb_data;
    wire        w_gb_data_vld;       
    
    //from and to IO buffer
    wire [255:0] w_mdata;
    wire         w_mdata_vld;
    wire [12:0]  w_iob_rd_addr;
    wire         w_iob_rd_en;
    wire         w_iob_pad_en;
    wire         w_buffer_select;
    
    //from and to weight buffer
    wire [255:0]w_wdata;
    wire        w_wdata_vld;
    wire [12:0] w_wb_rd_addr;
    wire        w_wb_rd_en;
    
    //from and to bias buffer
    wire [511:0] w_bias_data;
    wire         w_bias_data_valid;
    wire [7:0]   w_bias_rd_addr;
    wire         w_bias_rd_en;
    
    //from decoder
    wire [3:0] w_mode;
    wire [1:0] w_xpe_mode;
    wire [12:0]w_addr_start_w;
    wire [12:0]w_addr_start_d;
    wire [7:0] w_addr_start_b;
    wire [12:0]w_addr_start_s;
    wire [7:0] w_in_x_length;
    wire [7:0] w_in_y_length;
    wire [7:0] w_in_piece;
    wire [7:0] w_out_x_length;
    wire [7:0] w_out_y_length;
    wire [7:0] w_out_piece;
    wire [7:0] w_part_num;
    wire [3:0] w_last_part;
    wire [3:0] w_kernel;
    wire [1:0] w_stride;
    wire [1:0] w_pad;
    wire [1:0] w_tilingtype;
    wire [3:0] w_i_q_encode;
    wire [3:0] w_w_q_encode;
    wire [3:0] w_o_q_encode;
    wire [7:0] w_avg_pooling_coe;
    wire [1:0] w_buffer_flag;
    wire [7:0] w_store_length;
    wire [7:0] w_jump_length;
    wire       w_sort_en;
    
    reg r_mdata_vld;
    reg r_wdata_vld;
    
    assign w_gb_pad_en  = w_iob_pad_en;
    assign w_gb_rd_en   = w_wb_rd_en | w_iob_rd_en;
    assign w_gb_rd_addr = w_wb_rd_en ? w_wb_rd_addr : w_iob_rd_addr;
    
    assign w_mdata     = w_gb_data;
    assign w_mdata_vld = r_mdata_vld & w_gb_data_vld; 
    assign w_wdata     = w_gb_data;
    assign w_wdata_vld = r_wdata_vld & w_gb_data_vld;
    assign w_pe_out    = w_fc_out | w_conv_out;
    
    initial begin
        r_mdata_vld <= 0;
        r_wdata_vld <= 0;
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_mdata_vld <= 0;
        else
            r_mdata_vld <= w_iob_rd_en;
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_wdata_vld <= 0;
        else if(w_wb_rd_en)
            r_wdata_vld <= 1; 
        else
            r_wdata_vld <= 0;
    end
    
    Decoder 
    inst_decoder(
        //from Top
        .clk                (clk                ),
        .rst                (rst                ),
        .inst_in            (inst_in            ),
        .inst_valid         (inst_valid         ),
        //to NPU
        .o_mode             (w_mode             ),
        .o_xpe_mode         (w_xpe_mode         ),
        .o_addr_start_w     (w_addr_start_w     ),
        .o_addr_start_d     (w_addr_start_d     ),
        .o_addr_start_b     (w_addr_start_b     ),
        .o_addr_start_s     (w_addr_start_s     ),
        .o_in_x_length      (w_in_x_length      ),
        .o_in_y_length      (w_in_y_length      ),
        .o_in_piece         (w_in_piece         ),
        .o_out_x_length     (w_out_x_length     ),
        .o_out_y_length     (w_out_y_length     ),
        .o_out_piece        (w_out_piece        ),
        .o_part_num         (w_part_num         ),
        .o_last_part        (w_last_part        ),
        .o_kernel           (w_kernel           ),
        .o_stride           (w_stride           ),
        .o_pad              (w_pad              ),
        .o_tilingtype       (w_tilingtype       ),
        .o_i_q_encode       (w_i_q_encode       ),
        .o_w_q_encode       (w_w_q_encode       ),
        .o_o_q_encode       (w_o_q_encode       ),
        .o_avg_pooling_coe  (w_avg_pooling_coe  ),
        .o_buffer_flag      (w_buffer_flag      ),
        .o_store_length     (w_store_length     ),
        .o_jump_length      (w_jump_length      ),
        .o_sort_en          (w_sort_en          )    
    );
    
    Wagu 
    weight_addr_generate(
        //from Top
        .clk                (clk                ),
        .rst                (rst                ),
        //from schedule
        .start_calculate    (start_calculate    ),        
         //from IAGU
        .feature_load_end   (w_feature_load_end ),
        .add_start          (w_add_start        ),        
        //from decoder
        .mode               (i_mode             ),
        .addr_start_w       (i_addr_start_w     ),
        .in_y_length        (i_in_y_length      ),
        .in_piece           (i_in_piece         ),
        .out_x_length       (i_out_x_length     ),
        .out_y_length       (i_out_y_length     ),
        .out_piece          (i_out_piece        ),
        .part_num           (i_part_num         ),
        .last_part          (i_last_part        ),
        .i_kernel           (i_kernel           ),
        .i_stride           (i_stride           ),
        .i_pad              (i_pad              ),
        .tilingtype         (i_tilingtype       ),       
        //to weight buffer
        .o_rd_addr          (w_wb_rd_addr       ),
        .o_rd_en            (w_wb_rd_en         ),      
        //to IAGU
        .o_group_end        (w_weight_group_end ),      
        //to NPE
        .o_conv_out         (w_conv_out         ),
        .o_fc_out           (w_fc_out           ),
        .o_pe_en            (w_pe_en            )
    );
    
    Iagu 
    feature_addr_generate(
        //from Top
        .clk                (clk                ),
        .rst                (rst                ),
        //from schedule
        .start_calculate    (start_calculate    ),
        //from IAGU
        .weight_load_end    (w_weight_group_end ),
        //from decoder
        .mode               (i_mode             ),
        .addr_start_d       (i_addr_start_d     ),
        .in_x_length        (i_in_x_length      ),
        .in_y_length        (i_in_y_length      ),
        .in_piece           (i_in_piece         ),
        .out_x_length       (i_out_x_length     ),
        .out_y_length       (i_out_y_length     ),
        .out_piece          (i_out_piece        ),
        .part_num           (i_part_num         ),
        .last_part          (i_last_part        ),
        .i_kernel           (i_kernel           ),
        .i_stride           (i_stride           ),
        .i_pad              (i_pad              ),
        .tilingtype         (i_tilingtype       ),
        .i_sort_en          (i_sort_en          ),
        //to IO buffer
        .o_rd_addr          (w_iob_rd_addr      ),
        .o_rd_en            (w_iob_rd_en        ),
        .o_pad_en           (w_iob_pad_en       ),
        //to WAGU
        .o_feature_end      (w_feature_load_end ),
        .o_add_start        (w_add_start        ),
        //to NPE
        .o_pooling_out      (w_pooling_out      ),
        .o_sort_out         (w_sort_out         )
    );
    
    NPE  
    npe(
        //from top
        .i_clk              (clk                ),
        .i_rst_n            (rst                ),
        .i_sorter_op        (i_sort_en          ),
        //from decode
        .i_npe_mode         (i_mode             ),
        //from weight buffer
        .i_wdata            (w_wdata            ),
        .i_wdata_vld        (w_wdata_vld        ),
        //from IO buffer
        .i_mdata            (w_mdata            ),
        .i_mdata_vld        (w_mdata_vld        ),
        //from wagu
        .i_pe_en            (w_pe_en            ),
        .i_pe_conv_out      (w_conv_out         ),
        .i_pe_fc_out        (w_fc_out           ),
        //from iagu
        .i_pe_max_out       (w_pooling_out      ),
        .i_sorter_out       (w_sort_out         ),
        //to XPE
        .o_npe_result       (w_npe_result       ),
        .o_npe_result_vld   (w_npe_result_vld   )    
    );
    
    XPE  
    xpe(
        //from top
        .clk                (clk                ),
        .rst                (rst                ),
        .i_sort_en          (i_sort_en          ),
        //from schedule
        .calculate_enble    (start_calculate    ),
        //from decoder
        .mode               (i_mode             ),
        .xpe_mode           (i_xpe_mode         ),
        .part_num           (i_part_num         ),
        .out_piece          (i_out_piece        ),
        .addr_start_b       (i_addr_start_b     ),
        .i_q_encode         (i_i_q_encode       ),
        .w_q_encode         (i_w_q_encode       ),
        .o_q_encode         (i_o_q_encode       ),
        .avg_pooling_coe    (i_avg_pooling_coe  ),  
        //from NPE
        .npe_data_out       (w_npe_result       ),
        .npe_data_valid     (w_npe_result_vld   ),   
        //from wagu
        .pe_out_en          (w_pe_out           ),   
        //from bias buffer
        .bias_data          (w_bias_data        ),
        .bias_data_valid    (w_bias_data_valid  ),  
        //from Oagu
        .calculate_end      (o_calculate_end    ),   
        //to bias buffer
        .o_b_addr           (w_bias_rd_addr     ),
        .o_rd_en            (w_bias_rd_en       ),  
        //to IO buffer
        .o_xpe_data_out     (w_xpe_data_out     ),
        .o_xpe_data_valid   (w_xpe_data_valid   )
    );
    
    Oagu 
    output_addr_generate(
        //from Top
        .clk                (clk                ),
        .rst                (rst                ),  
        //from schedule
        .start_calculate    (start_calculate    ),  
        //from decoder
        .buffer_flag        (i_buffer_flag      ),
        .out_x_length       (i_out_x_length     ),
        .out_y_length       (i_out_y_length     ),
        .out_piece          (i_out_piece        ),
        .addr_start_s       (i_addr_start_s     ),
        .store_length       (i_store_length     ),
        .jump_length        (i_jump_length      ),       
        //from XPE
        .xpe_data           (w_xpe_data_out     ),
        .xpe_data_valid     (w_xpe_data_valid   ), 
        //to IO buffer
        .o_w_addr           (w_gb_w_addr        ),
        .o_w_data           (w_gb_w_data        ),
        .o_w_en             (w_gb_w_en          ),
        .o_buffer_select    (w_buffer_select    ),      
        //to schedule
        .calculate_end      (o_calculate_end    )    
    );
    
    Globle_Buffer 
    globle_buffer(
        //from Top
        .clk                (clk                ),
        .rst                (rst                ),
        //external data input port for axi bram controller
        .i_gb_bramctl_en    (i_gb_bramctl_en    ),
        .i_gb_bramctl_addr  (i_gb_bramctl_addr  ),
        .i_gb_bramctl_we    (i_gb_bramctl_we    ),
        .i_gb_bramctl_wdata (i_gb_bramctl_wdata ),
        .o_gb_bramctl_data  (o_gb_bramctl_rdata ),
        .o_gb_bramctl_vld   (o_gb_bramctl_rvld  ),        
        //internal port
        .i_gb_raddr         (w_gb_rd_addr       ),
        .i_gb_rd_en         (w_gb_rd_en         ),
        .i_gb_pad_en        (w_gb_pad_en        ),
        .i_gb_waddr         (w_gb_w_addr        ),
        .i_gb_wr_en         (w_gb_w_en          ),
        .i_gb_wdata         (w_gb_w_data        ),
        .o_data             (w_gb_data          ),
        .o_data_vld         (w_gb_data_vld      )     
    );
    
endmodule
