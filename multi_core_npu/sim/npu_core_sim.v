`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/16 10:51:32
// Design Name: 
// Module Name: npu_core_sim
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


module npu_core_sim();
        //from Top
        reg clk;
        reg rst;
        
        //from and to schedule
        reg start_calculate;
        wire o_calculate_end;
        
        //from decoder
        reg [3:0] i_mode;
        reg [1:0] xpe_mode;
        reg [12:0]addr_start_w;
        reg [12:0]addr_start_d;
        reg [7:0] addr_start_b;
        reg [12:0]addr_start_s;
        reg [7:0] in_x_length;
        reg [7:0] in_y_length;
        reg [7:0] in_piece;
        reg [7:0] out_x_length;
        reg [7:0] out_y_length;
        reg [7:0] out_piece;
        reg [4:0] part_num;
        reg [3:0] last_part;
        reg [3:0] i_kernel;
        reg [1:0] i_stride;
        reg [1:0] i_pad;
        reg [1:0] tilingtype;
        reg [3:0] i_q_encode;
        reg [3:0] w_q_encode;
        reg [3:0] o_q_encode;
        reg [7:0] avg_pooling_coe;
        reg [1:0] buffer_flag;
        reg [7:0] store_length;
        reg [7:0] jump_length;
        reg       i_sort_en;
        
        //for Globle_Buffer
        (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM EN"      *)
        reg          i_gb_bramctl_en; // Chip Enable Signal (optional)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DOUT"    *)
        wire [255:0] o_gb_bramctl_rdata; // Data Out Bus (optional)
        wire         o_gb_bramctl_rvld;
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DIN"     *)
        reg [255:0]  i_gb_bramctl_wdata; // Data In Bus (optional)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM WE"      *)
        reg          i_gb_bramctl_we; // Byte Enables (optional)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM ADDR"    *)
        reg [12:0]   i_gb_bramctl_addr; // Address Signal (required)                                  
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM CLK"     *)
        reg          i_gb_bramctl_s_clk; // Clock Signal (required)
        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM RST"     *)
        reg          i_gb_bramctl_s_rst; // Reset Signal (required)
        
        //for IO_Buffer_0
//        (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 EN"   *)
//        reg          i_iob_0_bramctl_en; // Chip Enable Signal (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DOUT" *)
//        wire [255:0] o_iob_0_bramctl_rdata; // Data Out Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DIN"  *)
//        reg [255:0]  i_iob_0_bramctl_wdata; // Data In Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 WE"   *)
//        reg          i_iob_0_bramctl_we; // Byte Enables (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 ADDR" *)
//        reg [16:0]   i_iob_0_bramctl_addr; // Address Signal (required)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 CLK"  *)
//        reg          i_iob_0_bramctl_s_clk; // Clock Signal (required)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 RST"  *)
//        reg          i_iob_0_bramctl_s_rst; // Reset Signal (required)
        
//        //for IO_Buffer_1
//        (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 EN"   *)
//        reg          i_iob_1_bramctl_en; // Chip Enable Signal (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 DOUT" *)
//        wire [255:0] o_iob_1_bramctl_rdata; // Data Out Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 DIN"  *)
//        reg [255:0]  i_iob_1_bramctl_wdata; // Data In Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 WE"   *)
//        reg          i_iob_1_bramctl_we; // Byte Enables (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 ADDR" *)
//        reg [16:0]   i_iob_1_bramctl_addr; // Address Signal (required)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 CLK"  *)
//        reg          i_iob_1_bramctl_s_clk; // Clock Signal (required)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_1 RST"  *)
//        reg          i_iob_1_bramctl_s_rst; // Reset Signal (required)
        
//        //for Weight_Buffer
//        (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM EN"      *)
//        reg          i_wb_bramctl_en; // Chip Enable Signal (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DOUT"    *)
//        wire [415:0] o_wb_bramctl_rdata; // Data Out Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DIN"     *)
//        reg [415:0]  i_wb_bramctl_wdata; // Data In Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM WE"      *)
//        reg  [3:0]   i_wb_bramctl_we; // Byte Enables (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM ADDR"    *)
//        reg [17:0]   i_wb_bramctl_addr; // Address Signal (required)                                  
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM CLK"     *)
//        reg          i_wb_bramctl_s_clk; // Clock Signal (required)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM RST"     *)
//        reg          i_wb_bramctl_s_rst; // Reset Signal (required)
        
//        //for Bias_Buffer
//        (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM EN"    *)
//        reg          i_bias_bramctl_en; // Chip Enable Signal (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM DOUT"  *)
//        wire [511:0]  o_bias_bramctl_rdata; // Data Out Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM DIN"   *)
//        reg [511:0]  i_bias_bramctl_wdata; // Data In Bus (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM WE"    *)
//        reg [63:0]   i_bias_bramctl_we; // Byte Enables (optional)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM ADDR"  *)
//        reg [13:0]   i_bias_bramctl_addr; // Address Signal (required)                
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM CLK"   *)
//        reg          i_bias_bramctl_s_clk; // Clock Signal (required)
//        (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM RST"   *)
//        reg          i_bias_bramctl_s_rst;  // Reset Signal (required) 
    
    simply_npu
    npu_core(
        //from Top
        .clk                (clk            ),
        .rst                (rst            ),
        
        //from and to schedule
        .start_calculate    (start_calculate),
        .o_calculate_end    (o_calculate_end),
        
        //from decoder
        .i_mode               (i_mode         ),
        .i_xpe_mode           (xpe_mode       ),
        .i_addr_start_w       (addr_start_w   ),
        .i_addr_start_d       (addr_start_d   ),
        .i_addr_start_b       (addr_start_b   ),
        .i_addr_start_s       (addr_start_s   ),
        .i_in_x_length        (in_x_length    ),
        .i_in_y_length        (in_y_length    ),
        .i_in_piece           (in_piece       ),
        .i_out_x_length       (out_x_length   ),
        .i_out_y_length       (out_y_length   ),
        .i_out_piece          (out_piece      ),
        .i_part_num           (part_num       ),
        .i_last_part          (last_part      ),
        .i_kernel             (i_kernel       ),
        .i_stride             (i_stride       ),
        .i_pad                (i_pad          ),
        .i_tilingtype         (tilingtype     ),
        .i_i_q_encode         (i_q_encode     ),
        .i_w_q_encode         (w_q_encode     ),
        .i_o_q_encode         (o_q_encode     ),
        .i_avg_pooling_coe    (avg_pooling_coe),
        .i_buffer_flag        (buffer_flag    ),
        .i_store_length       (store_length   ),
        .i_jump_length        (jump_length    ),
        .i_sort_en            (i_sort_en      ),
        
        //for IO_Buffer_0
        //(* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 EN"   *)
        .i_gb_bramctl_en     (i_gb_bramctl_en     ), // Chip Enable Signal (optional)
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DOUT" *)
        .o_gb_bramctl_rdata  (o_gb_bramctl_rdata  ), // Data Out Bus (optional)
        .o_gb_bramctl_rvld   (o_gb_bramctl_rvld   ),
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DIN"  *)
        .i_gb_bramctl_wdata  (i_gb_bramctl_wdata  ), // Data In Bus (optional)
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 WE"   *)
        .i_gb_bramctl_we     (i_gb_bramctl_we     ), // Byte Enables (optional)
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 ADDR" *)
        .i_gb_bramctl_addr   (i_gb_bramctl_addr   ), // Address Signal (required)
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 CLK"  *)
        .i_gb_bramctl_s_clk  (i_gb_bramctl_s_clk  ), // Clock Signal (required)
        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 RST"  *)
        .i_gb_bramctl_s_rst  (i_gb_bramctl_s_rst  ) // Reset Signal (required)

//        //for IO_Buffer_0
//        //(* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 EN"   *)
//        .i_iob_0_bramctl_en     (i_iob_0_bramctl_en     ), // Chip Enable Signal (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DOUT" *)
//        .o_iob_0_bramctl_rdata  (o_iob_0_bramctl_rdata  ), // Data Out Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DIN"  *)
//        .i_iob_0_bramctl_wdata  (i_iob_0_bramctl_wdata  ), // Data In Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 WE"   *)
//        .i_iob_0_bramctl_we     (i_iob_0_bramctl_we     ), // Byte Enables (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 ADDR" *)
//        .i_iob_0_bramctl_addr   (i_iob_0_bramctl_addr   ), // Address Signal (required)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 CLK"  *)
//        .i_iob_0_bramctl_s_clk  (i_iob_0_bramctl_s_clk  ), // Clock Signal (required)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 RST"  *)
//        .i_iob_0_bramctl_s_rst  (i_iob_0_bramctl_s_rst  ), // Reset Signal (required)
        
//        //for IO_Buffer_1
//        //(* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 EN"   *)
//        .i_iob_1_bramctl_en     (i_iob_1_bramctl_en     ), // Chip Enable Signal (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DOUT" *)
//        .o_iob_1_bramctl_rdata  (o_iob_1_bramctl_rdata  ), // Data Out Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 DIN"  *)
//        .i_iob_1_bramctl_wdata  (i_iob_1_bramctl_wdata  ), // Data In Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 WE"   *)
//        .i_iob_1_bramctl_we     (i_iob_1_bramctl_we     ), // Byte Enables (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 ADDR" *)
//        .i_iob_1_bramctl_addr   (i_iob_1_bramctl_addr   ), // Address Signal (required)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 CLK"  *)
//        .i_iob_1_bramctl_s_clk  (i_iob_1_bramctl_s_clk  ), // Clock Signal (required)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 IOB_BRAM_0 RST"  *)
//        .i_iob_1_bramctl_s_rst  (i_iob_1_bramctl_s_rst  ), // Reset Signal (required)
        
//        //for Weight_Buffer
//        //(* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM EN"      *)
//        .i_wb_bramctl_en        (i_wb_bramctl_en    ), // Chip Enable Signal (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DOUT"    *)
//        .o_wb_bramctl_rdata     (o_wb_bramctl_rdata ), // Data Out Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM DIN"     *)
//        .i_wb_bramctl_wdata     (i_wb_bramctl_wdata ), // Data In Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM WE"      *)
//        .i_wb_bramctl_we        (i_wb_bramctl_we    ), // Byte Enables (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM ADDR"    *)
//        .i_wb_bramctl_addr      (i_wb_bramctl_addr  ), // Address Signal (required)                                  
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM CLK"     *)
//        .i_wb_bramctl_s_clk     (i_wb_bramctl_s_clk ), // Clock Signal (required)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 WB_BRAM RST"     *)
//        .i_wb_bramctl_s_rst     (i_wb_bramctl_s_rst ), // Reset Signal (required)
        
//        //for Bias_Buffer
//        //(* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM EN"    *)
//        .i_bias_bramctl_en      (i_bias_bramctl_en  ), // Chip Enable Signal (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM DOUT"  *)
//        .o_bias_bramctl_rdata   (o_bias_bramctl_rdata), // Data Out Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM DIN"   *)
//        .i_bias_bramctl_wdata   (i_bias_bramctl_wdata), // Data In Bus (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM WE"    *)
//        .i_bias_bramctl_we      (i_bias_bramctl_we  ), // Byte Enables (optional)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM ADDR"  *)
//        .i_bias_bramctl_addr    (i_bias_bramctl_addr), // Address Signal (required)                
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM CLK"   *)
//        .i_bias_bramctl_s_clk   (i_bias_bramctl_s_clk), // Clock Signal (required)
//        //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BIAS_BRAM RST"   *)
//        .i_bias_bramctl_s_rst   (i_bias_bramctl_s_rst)  // Reset Signal (required) 
        
    );
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end    
    
    initial begin
        start_calculate     = 1'd0;
        #20 start_calculate = 1'd1;
        #10 start_calculate = 1'd0;
    end 
    
    initial begin
        rst             <= 1;
        i_mode          <= 6;
        xpe_mode        <= 1;
        addr_start_w    <= 13'd50;
        addr_start_d    <= 0;
        addr_start_b    <= 0;
        addr_start_s    <= 13'd80;
        in_x_length     <= 5;
        in_y_length     <= 5;
        in_piece        <= 2;
        out_x_length    <= 5;
        out_y_length    <= 4;
        out_piece       <= 2;
        part_num        <= 1;
        last_part       <= 5;
        i_kernel        <= 3;
        i_stride        <= 1;
        i_pad           <= 1;
        tilingtype      <= 1;
        i_q_encode      <= 1;
        w_q_encode      <= 1;
        o_q_encode      <= 1;
        avg_pooling_coe <= 1;
        buffer_flag     <= 0;
        store_length    <= 0;
        jump_length     <= 0;
        i_sort_en       <= 0;
    end
    
    initial begin
                //iob_1
        i_gb_bramctl_en    <= 0;
        i_gb_bramctl_wdata <= 0;
        i_gb_bramctl_we    <= 0;
        i_gb_bramctl_addr  <= 0;
        i_gb_bramctl_s_clk <= 0;
        i_gb_bramctl_s_rst <= 0;    
    end
         
//    initial begin
//        //iob_0
//        i_iob_0_bramctl_en    <= 0;
//        i_iob_0_bramctl_wdata <= 0;
//        i_iob_0_bramctl_we    <= 0;
//        i_iob_0_bramctl_addr  <= 0;
//        i_iob_0_bramctl_s_clk <= 0;
//        i_iob_0_bramctl_s_rst <= 0;
        
//        //iob_1
//        i_iob_1_bramctl_en    <= 0;
//        i_iob_1_bramctl_wdata <= 0;
//        i_iob_1_bramctl_we    <= 0;
//        i_iob_1_bramctl_addr  <= 0;
//        i_iob_1_bramctl_s_clk <= 0;
//        i_iob_1_bramctl_s_rst <= 0;
        
//        //wb
//        i_wb_bramctl_en    <= 0;
//        i_wb_bramctl_wdata <= 0;
//        i_wb_bramctl_we    <= 0;
//        i_wb_bramctl_addr  <= 0;
//        i_wb_bramctl_s_clk <= 0;
//        i_wb_bramctl_s_rst <= 0;
        
//        //bias
//        i_bias_bramctl_en    <= 0;
//        i_bias_bramctl_wdata <= 0;
//        i_bias_bramctl_we    <= 0;
//        i_bias_bramctl_addr  <= 0;
//        i_bias_bramctl_s_clk <= 0;
//        i_bias_bramctl_s_rst <= 0;    
//    end
    
    
     
endmodule
