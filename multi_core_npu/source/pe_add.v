`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/27 15:32:23
// Design Name: 
// Module Name: pe_add
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


module pe_add #(
    parameter   DATA_WIDTH      =   8   ,
    parameter   DATA_COPIES     =   32  
) (
        input  wire[DATA_COPIES*DATA_WIDTH-1:0]     i_wdata         ,
        input  wire                                 i_wdata_vld     ,
        input  wire[DATA_COPIES*DATA_WIDTH-1:0]     i_mdata         ,
        input  wire                                 i_mdata_vld     ,
        output wire[DATA_COPIES*2*DATA_WIDTH-1:0]   o_add_result  
   );
   //////////////////////////////////////////////////////////////////////////////////
    wire signed [DATA_WIDTH-1:0]                addend[DATA_COPIES-1:0]         ;
    wire signed [DATA_WIDTH-1:0]                augend[DATA_COPIES-1:0]         ;
    wire signed [DATA_WIDTH:0]                  c_result[DATA_COPIES-1:0]       ;
//////////////////////////////////////////////////////////////////////////////////
    genvar i;
    generate
        for (i = 0; i < DATA_COPIES; i = i + 1) begin : assign_loop
//            assign addend[i]   = i_mdata_vld ? i_mdata[DATA_WIDTH*i+:DATA_WIDTH] : {DATA_WIDTH{1'b0}};
//            assign augend[i]   = i_wdata_vld ? i_wdata[DATA_WIDTH*i+:DATA_WIDTH] : {DATA_WIDTH{1'b0}};
            assign addend[i]   = i_mdata[DATA_WIDTH*i+:DATA_WIDTH];
            assign augend[i]   = i_wdata[DATA_WIDTH*i+:DATA_WIDTH];
            assign c_result[i] = i_wdata_vld ? addend[i] + augend[i] : {DATA_WIDTH + 1{1'b0}};
            assign o_add_result[2*DATA_WIDTH*i+:2*DATA_WIDTH] = {{DATA_WIDTH - 1{c_result[i][DATA_WIDTH]}}, c_result[i]};
        end
    endgenerate
//////////////////////////////////////////////////////////////////////////////////   
endmodule
