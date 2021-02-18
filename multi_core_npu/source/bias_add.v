`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/28 20:24:04
// Design Name: 
// Module Name: bias_add
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


module bias_add # (
    parameter DATA_WIDTH = 16 
)(
    input  [511:0]npe_data,
    input         npe_data_valid,
    input  [511:0]bias_data,
    output [511:0]bias_data_out,
    output        bias_data_out_valid
);
    parameter Max_Value = $signed(16'h7fff);
    parameter Min_Value = $signed(16'h8000);
    
    wire signed [DATA_WIDTH-1:0] w_npe_data [31:0];
    wire signed [DATA_WIDTH-1:0] w_bias_data[31:0];
    wire signed [DATA_WIDTH-1:0] c_result   [31:0];
    wire signed [DATA_WIDTH-1:0] w_result   [31:0];
    
    assign bias_data_out_valid = npe_data_valid; 
    
    genvar i;
    generate
        for(i = 0; i < 32; i = i +1)begin
            assign w_npe_data [i] = npe_data [ ((i+1) * 16 - 1) : (i*16) ];
            assign w_bias_data[i] = bias_data[ ((i+1) * 16 - 1) : (i*16) ];
            assign c_result   [i] = w_npe_data [i] + w_bias_data[i];
            assign w_result   [i] = ((w_npe_data[i][DATA_WIDTH-1] == w_bias_data[i][DATA_WIDTH-1]) && (c_result[i][DATA_WIDTH-1] ^ w_npe_data[DATA_WIDTH-1]))
                                    ? (c_result[i][DATA_WIDTH-1] ?  Max_Value : Min_Value) : c_result[i];   
            assign bias_data_out[ ((i+1) * 16 - 1 ):  (i*16) ] = npe_data_valid ? w_result[i] : 16'd0;
        end
    endgenerate 
    
endmodule
