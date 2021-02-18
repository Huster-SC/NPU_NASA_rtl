`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/29 21:26:59
// Design Name: 
// Module Name: max16
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


module max16(
sub_data0 ,
sub_data1 ,
sub_data2 ,
sub_data3 ,
sub_data4 ,
sub_data5 ,
sub_data6 ,
sub_data7 ,
sub_data8 ,
sub_data9 ,
sub_data10,
sub_data11,
sub_data12,
sub_data13,
sub_data14,
sub_data15,
max_out
    );
parameter Data_Width = 8;  
parameter Index_Width=16;

//input   [Data_Width*16-1:0] data_in;
output [Index_Width + Data_Width - 1 :0] max_out;

input  [Index_Width + Data_Width - 1 :0] sub_data0 ;
input  [Index_Width + Data_Width - 1 :0] sub_data1 ;
input  [Index_Width + Data_Width - 1 :0] sub_data2 ;
input  [Index_Width + Data_Width - 1 :0] sub_data3 ;
input  [Index_Width + Data_Width - 1 :0] sub_data4 ;
input  [Index_Width + Data_Width - 1 :0] sub_data5 ;
input  [Index_Width + Data_Width - 1 :0] sub_data6 ;
input  [Index_Width + Data_Width - 1 :0] sub_data7 ;
input  [Index_Width + Data_Width - 1 :0] sub_data8 ;
input  [Index_Width + Data_Width - 1 :0] sub_data9 ;
input  [Index_Width + Data_Width - 1 :0] sub_data10;
input  [Index_Width + Data_Width - 1 :0] sub_data11;
input  [Index_Width + Data_Width - 1 :0] sub_data12;
input  [Index_Width + Data_Width - 1 :0] sub_data13;
input  [Index_Width + Data_Width - 1 :0] sub_data14;
input  [Index_Width + Data_Width - 1 :0] sub_data15;   


wire  [Index_Width + Data_Width - 1 :0] s1_r1;
wire  [Index_Width + Data_Width - 1 :0] s1_r2;
wire  [Index_Width + Data_Width - 1 :0] s1_r3;
wire  [Index_Width + Data_Width - 1 :0] s1_r4;
wire  [Index_Width + Data_Width - 1 :0] s1_r5;
wire  [Index_Width + Data_Width - 1 :0] s1_r6;
wire  [Index_Width + Data_Width - 1 :0] s1_r7;
wire  [Index_Width + Data_Width - 1 :0] s1_r8;

wire  [Index_Width + Data_Width - 1 :0] s2_r1;
wire  [Index_Width + Data_Width - 1 :0] s2_r2;
wire  [Index_Width + Data_Width - 1 :0] s2_r3;
wire  [Index_Width + Data_Width - 1 :0] s2_r4; 

wire  [Index_Width + Data_Width - 1 :0] s3_r1;
wire  [Index_Width + Data_Width - 1 :0] s3_r2; 

max_signed max_signed_11(.ain(sub_data0),.bin(sub_data1),.max_out(s1_r1)); 
max_signed max_signed_12(.ain(sub_data2),.bin(sub_data3),.max_out(s1_r2));
max_signed max_signed_13(.ain(sub_data4),.bin(sub_data5),.max_out(s1_r3));
max_signed max_signed_14(.ain(sub_data6),.bin(sub_data7),.max_out(s1_r4));

max_signed max_signed_15(.ain(sub_data8),.bin(sub_data9),.max_out(s1_r5)); 
max_signed max_signed_16(.ain(sub_data10),.bin(sub_data11),.max_out(s1_r6));
max_signed max_signed_17(.ain(sub_data12),.bin(sub_data13),.max_out(s1_r7));
max_signed max_signed_18(.ain(sub_data14),.bin(sub_data15),.max_out(s1_r8));
//////////////////////////////////////////////////////////////////////////////////////////
max_signed max_signed_21(.ain(s1_r1),.bin(s1_r2),.max_out(s2_r1)); 
max_signed max_signed_22(.ain(s1_r3),.bin(s1_r4),.max_out(s2_r2));
max_signed max_signed_23(.ain(s1_r5),.bin(s1_r6),.max_out(s2_r3));
max_signed max_signed_24(.ain(s1_r7),.bin(s1_r8),.max_out(s2_r4));
////////////////////////////////////////////////////////////////////////////////////
max_signed max_signed_31(.ain(s2_r1),.bin(s2_r2),.max_out(s3_r1));
max_signed max_signed_32(.ain(s2_r3),.bin(s2_r4),.max_out(s3_r2));
////////////////////////////////////////////////////////////////////////////////////////
max_signed max_signed_41(.ain(s3_r1),.bin(s3_r2),.max_out(max_out));
endmodule
