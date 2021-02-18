`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/27 22:16:06
// Design Name: 
// Module Name: relu
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


module relu(
    input calculate_en,
	input [511:0] bias_data,
	
	output reg [511:0] o_relu_data
  );
    
    wire bias_signed[31:0];
    
    initial begin
        o_relu_data <= 0;
    end
    
    genvar i;
    generate  
	   for (i= 0; i< 32; i= i+1)begin
	       assign bias_signed[i] = (bias_data[(i+1)*16-1]==1'b1);
		   always@(*)begin
		      if(calculate_en)
		  		o_relu_data[(i+1)*16-1:i*16]= bias_signed[i]?16'h0:bias_data[(i+1)*16-1:i*16];
		      else 
		  		o_relu_data[(i+1)*16-1:i*16]= bias_data[(i+1)*16-1:i*16];
		   end
	   end
    endgenerate
    
endmodule
