`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/23 19:05:35
// Design Name: 
// Module Name: NPE
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

`default_nettype none
module NPE #(
    parameter   DATA_WIDTH      =   8   ,
    parameter   DATA_COPIES     =   32  ,
    parameter   PE_COL_NUM      =   8
) (
    //from top
    input  wire                                             i_clk           ,
    input  wire                                             i_rst_n         ,
    input  wire                                             i_sorter_op     ,
    //from decode
    input  wire[3:0]                                        i_npe_mode      ,
    //from weight buffer
    input  wire[DATA_COPIES * DATA_WIDTH - 1:0]             i_wdata         ,
    input  wire                                             i_wdata_vld     ,
    //from IO buffer
    input  wire[DATA_COPIES * DATA_WIDTH - 1:0]             i_mdata         ,
    input  wire                                             i_mdata_vld     ,
    //from wagu
    input  wire[PE_COL_NUM - 1:0]                           i_pe_en         ,
    input  wire                                             i_pe_conv_out   ,
    input  wire                                             i_pe_fc_out     ,
    //from iagu
    input  wire                                             i_pe_max_out    ,
    input  wire                                             i_sorter_out    ,
    //to XPE
    output reg [DATA_COPIES * 2 * DATA_WIDTH - 1:0]         o_npe_result    ,
    output wire                                             o_npe_result_vld
    
    //for simulation
//    output wire o_pe_mac,
//    output wire [7:0]  o_load_state        ,
//    output wire [PE_COL_NUM - 1:0] o_mac_ld_en,
//    output wire [DATA_COPIES * DATA_WIDTH - 1:0]        mdata_1,
//    output wire [DATA_COPIES * DATA_WIDTH - 1:0]        wdata_1,
//    output wire [PE_COL_NUM - 1:0] o_mac_out_en,
//    output wire [PE_COL_NUM - 1:0] o_w_mac_out_en
 );
    localparam [3:0]PARA_MODE_CONV = 4'd1;
    localparam [3:0]PARA_MODE_FC   = 4'd2;
    localparam [3:0]PARA_MODE_ADD  = 4'd3;
    localparam [3:0]PARA_MODE_POOL = 4'd4;
    localparam [3:0]PARA_MODE_ACC  = 4'd5;
    localparam [3:0]PARA_MODE_DEPTHCONV = 4'd6;
    
    //for all
    wire[DATA_COPIES * DATA_WIDTH - 1:0]        wdata       [PE_COL_NUM:0];
    wire                                        wdata_vld   [PE_COL_NUM:0];
    wire[DATA_COPIES * DATA_WIDTH - 1:0]        w_idata     [PE_COL_NUM:0];
    wire                                        w_idata_vld [PE_COL_NUM:0];
    wire[DATA_COPIES * DATA_WIDTH - 1:0]        mdata       [PE_COL_NUM:0];
    wire                                        mdata_vld   [PE_COL_NUM:0];
    
    //for mac
    wire[DATA_COPIES * 2 * DATA_WIDTH - 1:0]    mac_result[PE_COL_NUM - 1:0]  ;
    wire[PE_COL_NUM - 1:0]                      pe_mac_ld_en     ;
    wire[PE_COL_NUM - 1:0]                      pe_mac_clear     ;
    wire[PE_COL_NUM - 1:0]                      pe_mac_en        ;
    reg [PE_COL_NUM - 1:0]                      pe_mac_out_en    ;
    
    //for sort
    wire  [255:0] sort_result;
    wire          sort_clear ;
    wire          sort_valid ;
    wire          last_sort_o;
    wire          sort_out_en;
    
    //for acc avg_pooling
    wire                                      pe_acc_en    ;
    reg                                       pe_acc_out_en;
    wire                                      pe_acc_clear ;
    wire [DATA_COPIES * 2 * DATA_WIDTH - 1:0] acc_result   ;
    
    //for add
    wire                                      pe_add_en    ;
    wire [DATA_COPIES * 2 * DATA_WIDTH - 1:0] add_result   ;
    reg                                       pe_add_out_en;
    
    //for max pooling
    wire                                      pe_max_en    ;
    reg                                       pe_max_out_en;
    wire                                      pe_max_clear ;
    wire [DATA_COPIES * 2 * DATA_WIDTH - 1:0] max_result   ;
    
    assign wdata    [0] = i_wdata;
    assign wdata_vld[0] = i_wdata_vld;
    assign mdata    [0] = i_mdata;
    assign mdata_vld[0] = i_mdata_vld;
    
    initial begin
        r_output_pe_en <= 0;
        pe_mac_out_en  <= 0;    
    end
 
/////////////////////////////////// MAC /////////////////////////////////////////////    
    //for load feature
    localparam  [PE_COL_NUM - 1:0]  LOAD_PE_MAC0 = 8'b00000001,
                                    LOAD_PE_MAC1 = 8'b00000010,
                                    LOAD_PE_MAC2 = 8'b00000100,
                                    LOAD_PE_MAC3 = 8'b00001000,
                                    LOAD_PE_MAC4 = 8'b00010000,
                                    LOAD_PE_MAC5 = 8'b00100000,
                                    LOAD_PE_MAC6 = 8'b01000000,
                                    LOAD_PE_MAC7 = 8'b10000000;
    //for output result
    localparam  [PE_COL_NUM - 1:0]  OUTPUT_PE_MAC0  = 8'b00000001,
                                    OUTPUT_PE_MAC1  = 8'b00000010,
                                    OUTPUT_PE_MAC2  = 8'b00000100,
                                    OUTPUT_PE_MAC3  = 8'b00001000,
                                    OUTPUT_PE_MAC4  = 8'b00010000,
                                    OUTPUT_PE_MAC5  = 8'b00100000,
                                    OUTPUT_PE_MAC6  = 8'b01000000,
                                    OUTPUT_PE_MAC7  = 8'b10000000;
    reg [7:0]  load_state        ;
    reg [7:0]  load_state_next   ; 
    reg [7:0]  output_state      ;
    reg [7:0]  output_state_next ;
    reg [7:0]  r_output_pe_en    ;
    wire[7:0]  output_pe_en      ;
    wire[7:0]  pe_mac_output_en  ;
    wire       pe_mac, pe_fc     ;
    //wire       pe_add, pe_pool, pe_acc;
    //wire[6:0]                                   load_cstate     ;
    assign pe_mac = (i_npe_mode == PARA_MODE_CONV || i_npe_mode == PARA_MODE_DEPTHCONV);
    assign pe_fc  = (i_npe_mode == PARA_MODE_FC);
    //for load feature
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) load_state <= LOAD_PE_MAC0;
        else          load_state <= load_state_next;
    end
    
    always @(*) begin
        case (load_state)
            LOAD_PE_MAC0    : load_state_next = (pe_mac && i_mdata_vld && i_pe_en[1]) ? LOAD_PE_MAC1 : LOAD_PE_MAC0;
            LOAD_PE_MAC1    : load_state_next = (i_mdata_vld && i_pe_en[2]) ? LOAD_PE_MAC2 : LOAD_PE_MAC0;
            LOAD_PE_MAC2    : load_state_next = (i_mdata_vld && i_pe_en[3]) ? LOAD_PE_MAC3 : LOAD_PE_MAC0;
            LOAD_PE_MAC3    : load_state_next = (i_mdata_vld && i_pe_en[4]) ? LOAD_PE_MAC4 : LOAD_PE_MAC0;
            LOAD_PE_MAC4    : load_state_next = (i_mdata_vld && i_pe_en[5]) ? LOAD_PE_MAC5 : LOAD_PE_MAC0;
            LOAD_PE_MAC5    : load_state_next = (i_mdata_vld && i_pe_en[6]) ? LOAD_PE_MAC6 : LOAD_PE_MAC0;
            LOAD_PE_MAC6    : load_state_next = (i_mdata_vld && i_pe_en[7]) ? LOAD_PE_MAC7 : LOAD_PE_MAC0;
            LOAD_PE_MAC7    : load_state_next = LOAD_PE_MAC0;
            default         : load_state_next = LOAD_PE_MAC0;
        endcase
    end
    //assign load_cstate = load_state;
    assign pe_mac_ld_en = pe_mac ? (load_state & {8{i_mdata_vld}}) : ((pe_fc | pe_add_en | pe_acc_en | pe_max_en)? {7'h0, i_mdata_vld} : 8'h0);
    //for simulation
//    assign o_pe_mac =  pe_mac;
//    assign o_load_state = load_state;
//    assign o_mac_ld_en  = pe_mac_ld_en;
//    assign mdata_1 = mdata[1];
//    assign wdata_1 = wdata[1];
//    assign o_mac_out_en = pe_mac_out_en;
//    assign o_w_mac_out_en = pe_mac_output_en;
    
    assign pe_mac_en    = i_pe_en;    
    
    //for output result
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)           r_output_pe_en <= 7'h0;
        else if (i_pe_conv_out) r_output_pe_en <= i_pe_en;
        else                    r_output_pe_en <= r_output_pe_en;
    end
    
    assign output_pe_en = i_pe_conv_out ? i_pe_en : r_output_pe_en;
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) output_state <= OUTPUT_PE_MAC0;
        else          output_state <= output_state_next;
    end
    
    always @(*) begin
        case (output_state)
            OUTPUT_PE_MAC0    : output_state_next = (i_pe_conv_out && output_pe_en[1]) ? OUTPUT_PE_MAC1 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC1    : output_state_next = output_pe_en[2] ? OUTPUT_PE_MAC2 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC2    : output_state_next = output_pe_en[3] ? OUTPUT_PE_MAC3 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC3    : output_state_next = output_pe_en[4] ? OUTPUT_PE_MAC4 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC4    : output_state_next = output_pe_en[5] ? OUTPUT_PE_MAC5 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC5    : output_state_next = output_pe_en[6] ? OUTPUT_PE_MAC6 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC6    : output_state_next = output_pe_en[7] ? OUTPUT_PE_MAC7 : OUTPUT_PE_MAC0;
            OUTPUT_PE_MAC7    : output_state_next = OUTPUT_PE_MAC0;
            default           : output_state_next = OUTPUT_PE_MAC0;
        endcase
    end
    
    assign pe_mac_output_en = pe_mac ? (output_state & {output_pe_en[7:1], output_pe_en[0] & i_pe_conv_out}) :
                         (pe_fc ? {7'h0, i_pe_en[0] & i_pe_fc_out} : 8'h0);
    
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) pe_mac_out_en <= 0;
        else         pe_mac_out_en <= pe_mac_output_en;
    end
    
    assign pe_mac_clear = pe_mac_out_en;
    
    genvar i;
    generate
        for(i = 0; i < PE_COL_NUM; i = i + 1) begin : inst_mac_loop
            assign w_idata    [i] = (i_npe_mode == PARA_MODE_DEPTHCONV) ? wdata    [0] : wdata    [i];
            assign w_idata_vld[i] = (i_npe_mode == PARA_MODE_DEPTHCONV) ? wdata_vld[0] : wdata_vld[i];
            pe_mac # (
                .DATA_WIDTH             (DATA_WIDTH         ), 
                .DATA_NUM               (DATA_COPIES        )
            )mac_inst0(
                .i_clk                  (i_clk              ),
                .i_rst_n                (i_rst_n            ),
                .i_mode                 (i_npe_mode         ),
                .i_mac_en               (pe_mac_en   [i]    ),        
                .i_mac_id               (i           [2:0]  ), 
                .i_wdata                (w_idata     [i]    ),
                .i_wdata_vld            (w_idata_vld [i]    ),
                .i_mdata                (mdata       [0]    ),
                .i_mdata_vld            (pe_mac_ld_en[i]    ),
                .i_mac_clear            (pe_mac_clear[i]    ),
                .o_wdata                (wdata       [i+1]  ),
                .o_wdata_vld            (wdata_vld   [i+1]  ),
                .o_mdata                (mdata       [i+1]  ),
                .o_mdata_vld            (mdata_vld   [i+1]  ),
                .o_mac_result           (mac_result  [i]    )                 
            );        
        end
    endgenerate
    
//////////////////////////////////////////////////////////////////////////////

////////////////////////////////// MAX //////////////////////////////////////    
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) pe_max_out_en <= 0;
        else         pe_max_out_en <= pe_max_en && i_pe_max_out;
    end
     
    assign pe_max_en     = (i_npe_mode == PARA_MODE_POOL);
    assign pe_max_clear  =  pe_max_out_en;
    
    pe_max # (
        .DATA_WIDTH             (DATA_WIDTH         ), 
        .DATA_COPIES            (DATA_COPIES        )
    )max_inst(
        .i_clk                  (i_clk              ), 
		.i_rst_n                (i_rst_n            ), 
		.i_mdata                (mdata    [1]       ), //notion here
		.i_mdata_vld            (mdata_vld[1]       ), 
		.o_max_result           (max_result         ), 
		.i_max_clear            (pe_max_clear       ), 
		.i_max_en               (pe_max_en          )
	);
/////////////////////////////////////////////////////////////////////////////

//////////////////////////////// ADD ////////////////////////////////////////    
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) pe_add_out_en <= 0;
        else         pe_add_out_en <= pe_add_en && i_wdata_vld;
    end
    
    assign pe_add_en = (i_npe_mode == PARA_MODE_ADD);
    
    pe_add # (
        .DATA_WIDTH             (DATA_WIDTH         ), 
        .DATA_COPIES            (DATA_COPIES        )
    )add_inst(
        .i_wdata                (wdata    [1]       ), //notion here
        .i_wdata_vld            (wdata_vld[1]       ), 
		.i_mdata                (mdata    [1]       ), 
		.i_mdata_vld            (mdata_vld[1]       ), 
		.o_add_result           (add_result         )
    );
///////////////////////////////////////////////////////////////////////////

////////////////////////////////// ACC ////////////////////////////////////
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) pe_acc_out_en <= 0;
        else         pe_acc_out_en <= pe_acc_en && i_pe_max_out;
    end
    
    assign pe_acc_en    = (i_npe_mode == PARA_MODE_ACC);
    assign pe_acc_clear =  pe_acc_out_en;
    
    pe_acc #(
        .DATA_WIDTH             (DATA_WIDTH         ), 
        .DATA_COPIES            (DATA_COPIES        )
    )acc_inst(
        .i_clk                  (i_clk              ), 
        .i_rst_n                (i_rst_n            ), 
        .i_mdata                (mdata    [1]       ), //notion here
        .i_mdata_vld            (mdata_vld[1]       ), 
        .o_acc_result           (acc_result         ), 
        .i_acc_clear            (pe_acc_clear       ), 
        .i_acc_en               (pe_acc_en          )
    );
////////////////////////////////////////////////////////////////////////////

///////////////////////////////// Sort /////////////////////////////////////    
    assign sort_clear  = i_sorter_op & i_sorter_out;
    assign sort_out_en = sort_clear;
    
    pe_sort sorter(
        //output
        .sorter_result  (sort_result  ),
        .sorter_valid   (sort_valid   ),
        .last_sort_o    (last_sort_o  ),
        //input
        .sys_clk        (i_clk        ),
        .sys_rst_n      (i_rst_n      ),
        .sorter_en      (mdata_vld[0] ),
        .sorter_clr     (sort_clear   ),
        .sorter_in      (mdata    [0] ),
        .last_sort      (i_sorter_out )
    );
///////////////////////////////////////////////////////////////////////////// 

//////////////////////////////// OutPut /////////////////////////////////////
    assign o_npe_result_vld = |pe_mac_out_en | pe_max_out_en | pe_acc_out_en | pe_add_out_en | sort_out_en;
    
    always @(*) begin
        case ({pe_add_out_en, pe_acc_out_en, pe_max_out_en, pe_mac_out_en,sort_out_en})
            12'b000000000010    : o_npe_result = mac_result[0];
            12'b000000000100    : o_npe_result = mac_result[1];
            12'b000000001000    : o_npe_result = mac_result[2];
            12'b000000010000    : o_npe_result = mac_result[3];
            12'b000000100000    : o_npe_result = mac_result[4];
            12'b000001000000    : o_npe_result = mac_result[5];
            12'b000010000000    : o_npe_result = mac_result[6];
            12'b000100000000    : o_npe_result = mac_result[7];
            12'b001000000000    : o_npe_result = max_result;
            12'b010000000000    : o_npe_result = acc_result;
            12'b100000000000    : o_npe_result = add_result; 
            12'b000000000001    : o_npe_result = {256'b0,sort_result}; 
            default             : o_npe_result = {DATA_COPIES*2*DATA_WIDTH{1'b0}};
        endcase
    end    
    
/////////////////////////////////////////////////////////////////////////////  
endmodule
`default_nettype wire