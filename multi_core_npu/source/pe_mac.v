`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/23 21:35:36
// Design Name: 
// Module Name: pe_mac
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


module pe_mac #(
    parameter DATA_WIDTH = 8,
    parameter DATA_NUM   = 32 
) ( 
    input                                   i_clk      ,
    input                                   i_rst_n    ,
    input                                   i_mode     ,
    input                                   i_mac_en   ,        
    input  [2:0]                            i_mac_id   , 
    input  [DATA_NUM * DATA_WIDTH-1:0]      i_wdata    ,
    input                                   i_wdata_vld,
    input  [DATA_NUM * DATA_WIDTH-1:0]      i_mdata    ,
    input                                   i_mdata_vld,
    input                                   i_mac_clear,
    output [DATA_NUM * DATA_WIDTH-1:0]      o_wdata    ,
    output                                  o_wdata_vld,
    output [DATA_NUM * DATA_WIDTH-1:0]      o_mdata    ,
    output                                  o_mdata_vld,
    output [DATA_NUM * 2 * DATA_WIDTH-1:0]  o_mac_result
    
    // for simulation
//    output [5:0] o_count,
//    output [DATA_NUM * DATA_WIDTH - 1:0]  o_r_wdata,
//    output                                o_r_wdata_vld,
//    output [DATA_NUM * DATA_WIDTH - 1:0]  o_r_mdata,
//    output                                o_r_mdata_vld 
   );
    
    parameter CONV      = 4'd1;
    parameter DEPTHCONV = 4'd6;
    
    reg [5:0] count;
    reg [DATA_NUM * DATA_WIDTH - 1:0]  r_wdata    ;
    reg                                r_wdata_vld;
    reg [DATA_NUM * DATA_WIDTH - 1:0]  r_mdata    ;
    reg                                r_mdata_vld; 
    reg signed [2 * DATA_WIDTH - 1:0]  r_result[DATA_NUM - 1:0];
    reg signed [2 * DATA_WIDTH - 1:0]  post_result[DATA_NUM - 1:0];
        
    wire mac_clear;
    wire signed [DATA_WIDTH - 1:0]  data  [DATA_NUM - 1:0];
    wire signed [DATA_WIDTH - 1:0]  weight[DATA_NUM - 1:0];
    wire signed [2 * DATA_WIDTH - 1:0]  mul_result[DATA_NUM - 1:0]; 
    wire signed [2 * DATA_WIDTH - 1:0]  mac_result[DATA_NUM - 1:0];
    wire signed [2 * DATA_WIDTH - 1:0]  w_result  [DATA_NUM - 1:0];
    
    assign mac_clear   = ~i_mac_en | i_mac_clear;
    assign o_wdata_vld = r_wdata_vld;
    assign o_wdata     = r_wdata;
    assign o_mdata_vld = r_mdata_vld;
    assign o_mdata     = r_mdata;
    
    
    //for simulation
//    assign o_count = count;
//    assign o_r_wdata = r_wdata;
//    assign o_r_wdata_vld = r_wdata_vld;
//    assign o_r_mdata = r_mdata;
//    assign o_r_mdata_vld = r_mdata_vld;
    
    integer j;
    initial begin
        r_wdata     <= 0;
        r_wdata_vld <= 0;
        r_mdata     <= 0;
        r_mdata_vld <= 0;
    
        for(j = 0; j < DATA_NUM; j = j + 1)
            r_result[j] <= 0;
    end
    
    genvar i;
    generate
        for(i = 0; i < DATA_NUM; i = i + 1) begin : assign_loop
           assign data  [i]  = r_mdata[DATA_WIDTH * i +: DATA_WIDTH];
           assign weight[i]  = r_wdata[DATA_WIDTH * i +: DATA_WIDTH];
           assign mul_result[i] = (i_mode == DEPTHCONV) ? data[i] * weight[i] : data[count] * weight[i];
           assign mac_result[i] = r_result[i] + mul_result[i];
           always @(*) begin
                if ((mac_result[i][2*DATA_WIDTH-1] ^ r_result[i][2*DATA_WIDTH-1]) && 
                  (r_result[i][2*DATA_WIDTH-1] ^~ mul_result[i][2*DATA_WIDTH-1]))
                    post_result[i] = mac_result[i][2*DATA_WIDTH-1] ? 
                                   {1'b0, {2*DATA_WIDTH-1{1'b1}}} : 
                                   {1'b1, {2*DATA_WIDTH-1{1'b0}}};              
                else 
                    post_result[i] = mac_result[i];
            end
            assign w_result[i] = r_wdata_vld ? post_result[i] : r_result[i];
            always @(posedge i_clk or negedge i_rst_n) begin
                if (!i_rst_n)       r_result[i] <= {2*DATA_WIDTH{1'h0}};
                else if (mac_clear) r_result[i] <= {2*DATA_WIDTH{1'h0}};
                else                r_result[i] <= w_result[i];
            end
            assign o_mac_result[2*DATA_WIDTH*i+:2*DATA_WIDTH] = w_result[i];
        end
    endgenerate    
    
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n)
            count <= 0;
        else begin
            if(r_wdata_vld) begin
                if(count == DATA_NUM - 1)
                    count <= 0;
                else
                    count <= count + 1;
            end else begin
                count <= 0;
            end    
        end
    end
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_wdata_vld <= 1'b0;
            r_mdata_vld <= 1'b0;
        end
        else begin
            r_wdata_vld <= i_wdata_vld;
            r_mdata_vld <= i_mdata_vld;
        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_wdata     <= {DATA_NUM * DATA_WIDTH{1'h0}};
        end else if (!i_mac_en) begin
            r_wdata     <= {DATA_NUM * DATA_WIDTH{1'h0}};
        end else if (i_wdata_vld) begin
            r_wdata     <= i_wdata;
        end else begin
            r_wdata     <= r_wdata; 
        end    
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_mdata     <= {DATA_NUM * DATA_WIDTH{1'h0}};
        end else if (!i_mac_en) begin
            r_mdata     <= {DATA_NUM * DATA_WIDTH{1'h0}};
        end else if (i_mdata_vld) begin
            r_mdata     <= i_mdata;
        end else begin
            r_mdata     <= r_mdata;
        end
    end
    
endmodule
