`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/10 19:06:58
// Design Name: 
// Module Name: NPE_sim
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


module NPE_sim();
    parameter   DATA_WIDTH    =   8   ;
    parameter   DATA_COPIES   =   32  ;
    parameter   PE_COL_NUM    =   8   ;
    
    reg      i_clk           ;
    reg      i_rst_n         ;
    reg[3:0] i_npe_mode      ;
    reg      i_sorter_op     ;
    reg[DATA_COPIES * DATA_WIDTH - 1:0]             i_wdata ;
    reg                                             i_wdata_vld     ;
    reg[DATA_COPIES * DATA_WIDTH - 1:0]             i_mdata ;
    reg                                             i_mdata_vld     ;
    reg[PE_COL_NUM - 1:0]                           i_pe_en ;
    reg      i_pe_conv_out   ;
    reg      i_pe_max_out    ;
    reg      i_pe_fc_out     ; 
    reg      i_sorter_out    ;
    wire [DATA_COPIES * 2 * DATA_WIDTH - 1:0]         o_npe_result  ;
    wire                                             o_npe_result_vld ;
    wire o_pe_mac;
    wire [7:0]  o_load_state;
    wire [PE_COL_NUM - 1:0] o_mac_ld_en;
    wire [DATA_COPIES * DATA_WIDTH - 1:0]        mdata_1;
    wire [DATA_COPIES * DATA_WIDTH - 1:0]        wdata_1;
    wire [PE_COL_NUM - 1:0] o_mac_out_en;
    wire [PE_COL_NUM - 1:0] o_w_mac_out_en;
    
    NPE # (
        .DATA_WIDTH             (DATA_WIDTH         ), 
        .DATA_COPIES            (DATA_COPIES        ),
        .PE_COL_NUM             (PE_COL_NUM         )
    )sim_NPE(i_clk, i_rst_n, i_sorter_op, i_npe_mode, i_wdata, i_wdata_vld, i_mdata, i_mdata_vld, i_pe_en,
                i_pe_conv_out, i_pe_fc_out, i_pe_max_out,  i_sorter_out, 
                o_npe_result, o_npe_result_vld, o_pe_mac, o_load_state, o_mac_ld_en, mdata_1, wdata_1, o_mac_out_en, o_w_mac_out_en);
    
    initial begin
        i_clk <= 0;
        forever #5 i_clk <= ~i_clk;
    end
    
    initial begin
        i_rst_n     <= 1'd1;
        i_npe_mode  <= 4'd1;
        i_sorter_op <= 0;
        i_pe_en     <= 8'b00000111;
        i_pe_conv_out <= 0;
        i_pe_max_out  <= 0;
        i_pe_fc_out   <= 0;
        i_sorter_out  <= 0;       
    end            
    
    //for add
//    initial begin
//       i_wdata     <= 0;
//       i_wdata_vld <= 0;
//       i_mdata     <= 0;
//       i_mdata_vld <= 0;
//       #25 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;
//           i_mdata     <= 256'd1;
//           i_mdata_vld <= 1;
//       #10 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;
//           i_mdata     <= 256'd2;
//           i_mdata_vld <= 1;
//       #10 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;
//           i_mdata     <= 256'd3;
//           i_mdata_vld <= 1;
//       #10 i_wdata     <= 256'd0;
//           i_wdata_vld <= 0;
//           i_mdata     <= 256'd0;
//           i_mdata_vld <= 0;
//       #30 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;
//           i_mdata     <= 256'd1;
//           i_mdata_vld <= 1;
//       #10 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;
//           i_mdata     <= 256'd2;
//           i_mdata_vld <= 1;
//       #10 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;
//           i_mdata     <= 256'd3;
//           i_mdata_vld <= 1;
//       #10 i_wdata     <= 256'd0;
//           i_wdata_vld <= 0;
//           i_mdata     <= 256'd0;
//           i_mdata_vld <= 0;            
//    end
    
    //for maxpooling and avgpooling
//    initial begin
//        i_mdata     <= 0;
//        i_mdata_vld <= 0;
//        i_pe_max_out<= 0;
//        #15 i_mdata     <= 256'd1;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #10 i_mdata     <= 256'd2;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #10 i_mdata     <= 256'd4;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #20 i_mdata     <= 256'd8;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #10 i_pe_max_out<= 1;
//        #10 i_pe_max_out<= 0; 
//        #20 i_mdata     <= 256'd1;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #10 i_mdata     <= 256'd2;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #10 i_mdata     <= 256'd4;
//            i_mdata_vld <= 1;
//        #10 i_mdata_vld <= 0;
//        #10 i_pe_max_out<= 1;
//        #10 i_pe_max_out<= 0;      
//    end
    
    //for fullconnect
//    initial begin
//       i_wdata     <= 0;
//       i_wdata_vld <= 0;
//       i_mdata     <= 0;
//       i_mdata_vld <= 0;
//       i_pe_fc_out <= 0;
//       #15 i_mdata     <= 256'd65793;
//           i_mdata_vld <= 1;
//       #10 i_mdata_vld <= 0;
//       #20 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;      
//       #10 i_wdata     = 256'd2;
//           i_wdata_vld = 1;          
//       #10 i_wdata     = 256'd3;
//           i_wdata_vld = 1;         
//       #10 i_wdata_vld = 0;
//       #30 i_wdata     = 256'd0;
//           i_wdata_vld = 0;
//           i_mdata     = 256'd0;
//           i_mdata_vld = 0;
//           i_pe_fc_out  <= 1;
//       #10 i_pe_fc_out  <= 0;
//       #20 i_mdata     <= 256'd257;
//           i_mdata_vld <= 1;
//       #10 i_mdata_vld <= 0;
//       #20 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;      
//       #10 i_wdata     = 256'd2;
//           i_wdata_vld = 1;          
//       #10 i_wdata     = 256'd3;
//           i_wdata_vld = 1;         
//       #10 i_wdata_vld = 0;
//       #30 i_wdata     = 256'd0;
//           i_wdata_vld = 0;
//           i_mdata     = 256'd0;
//           i_mdata_vld = 0;
//           i_pe_fc_out  <= 1;
//       #10 i_pe_fc_out  <= 0;
//       #20 i_mdata     <= 256'd1;
//           i_mdata_vld <= 1;
//       #10 i_mdata_vld <= 0;
//       #20 i_wdata     <= 256'd1;
//           i_wdata_vld <= 1;      
//       #10 i_wdata     = 256'd2;
//           i_wdata_vld = 1;          
//       #10 i_wdata     = 256'd3;
//           i_wdata_vld = 1;         
//       #10 i_wdata_vld = 0;
//       #30 i_wdata     = 256'd0;
//           i_wdata_vld = 0;
//           i_mdata     = 256'd0;
//           i_mdata_vld = 0;
//           i_pe_fc_out  <= 1;
//       #10 i_pe_fc_out  <= 0;      
//    end
    
     // for convolution
    initial begin
       i_wdata     <= 0;
       i_wdata_vld <= 0;
       i_mdata     <= 0;
       i_mdata_vld <= 0;
       i_pe_conv_out <= 0;
       //i_npe_mode  <= 4'b1;
       #15 //i_wdata     <= 256'd1;
           //i_wdata_vld <= 1;
           i_mdata     <= 256'd65793;
           i_mdata_vld <= 1;
       #10 //i_wdata     <= 256'd1;
           //i_wdata_vld <= 1;
           i_mdata     <= 256'd257;
           i_mdata_vld <= 1;
       #10 //i_wdata     <= 256'd1;
           //i_wdata_vld <= 1;
           i_mdata     <= 256'd1;
           i_mdata_vld <= 1;
       #10 i_mdata_vld <= 0;
       #20 i_wdata     <= 256'd1;
           i_wdata_vld <= 1;
           i_mdata     <= 256'd2;
           i_mdata_vld <= 0;
       #10 i_wdata     = 256'd2;
           i_wdata_vld = 1;
           i_mdata     = 256'd3;
           i_mdata_vld = 0;
       #10 i_wdata     = 256'd3;
           i_wdata_vld = 1;
           i_mdata     = 256'd4;
           i_mdata_vld = 0;
       #10 i_wdata_vld = 0;       
       #30 i_wdata     = 256'd0;
           i_wdata_vld = 0;
           i_mdata     = 256'd0;
           i_mdata_vld = 0;
           i_pe_conv_out  <= 1;
       #10 i_pe_conv_out  <= 0;  
    end
    
endmodule
