`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/29 21:38:34
// Design Name: 
// Module Name: sort_E1
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


module sort_E1(
///input//////////////////////////////////
sys_clk,
sys_rst_n,
sorter_clr,
sort_in,
sort_en,
last_sort,	
/////output/////////////////////////////////
E1H_sorter_out0,
E1H_sorter_out1,
E1H_sorter_out2,
E1H_sorter_out3,
E1H_sorter_out4,
E1L_sorter_out0,
E1L_sorter_out1,
E1L_sorter_out2,
E1L_sorter_out3,
E1L_sorter_out4,
E1_sort_en,
E1_last_sort,
E1_index_counter
    );
 parameter IDLE = 3'b000;
parameter ITERATION0 = 3'b001;
parameter ITERATION1 = 3'b011;
parameter ITERATION2 = 3'b010;
parameter ITERATION3 = 3'b110;
parameter ITERATION4 = 3'b100;

parameter Data_Width = 8;  
parameter Index_Width=16;
parameter Num_Inputs = 16;
parameter MIN = 8'h80;
input sys_clk      ;
input sys_rst_n   ;
input sorter_clr   ;
input [Data_Width*Num_Inputs*2-1 : 0] sort_in   ;
input last_sort ;	

input sort_en      ;

output reg [Index_Width + Data_Width - 1 :0] E1H_sorter_out0;
output reg [Index_Width + Data_Width - 1 :0] E1H_sorter_out1;
output reg [Index_Width + Data_Width - 1 :0] E1H_sorter_out2;
output reg [Index_Width + Data_Width - 1 :0] E1H_sorter_out3;
output reg [Index_Width + Data_Width - 1 :0] E1H_sorter_out4;
output reg [Index_Width + Data_Width - 1 :0] E1L_sorter_out0;
output reg [Index_Width + Data_Width - 1 :0] E1L_sorter_out1;
output reg [Index_Width + Data_Width - 1 :0] E1L_sorter_out2;
output reg [Index_Width + Data_Width - 1 :0] E1L_sorter_out3;
output reg [Index_Width + Data_Width - 1 :0] E1L_sorter_out4;
output reg E1_sort_en;
output reg [Index_Width-1 :0] E1_index_counter;
output reg E1_last_sort;

reg sort_enL0;
reg sort_enL1;
reg sort_enL2;
reg sort_enL3;
reg sort_enL4; 
reg sort_enL5;

reg last_sortL0;
reg last_sortL1;
reg last_sortL2;
reg last_sortL3;
reg last_sortL4; 
reg last_sortL5;
reg [Index_Width -1 :0] index_counter; 

reg [Data_Width*Num_Inputs-1 : 0]sort_in_LL;
reg [Data_Width*Num_Inputs-1 : 0]sort_in_LH;

wire [Index_Width + Data_Width - 1 :0] max_out_L;
wire [Index_Width + Data_Width - 1 :0] max_out_H;
reg [2:0] cur_state ;
reg [2:0] next_state;
always @(posedge sys_clk, negedge sys_rst_n)
begin
	if(!sys_rst_n)
	begin
		sort_in_LL <=  0;
		sort_in_LH <= 0;
		index_counter <= 0;
	end else if(sorter_clr)
	begin
		sort_in_LL <= 0;
		sort_in_LH <= 0;
		index_counter <= 0;
	end else if(sort_en)
	begin
		sort_in_LL <= sort_in[Data_Width*Num_Inputs-1:0];
		sort_in_LH <= sort_in[Data_Width*Num_Inputs*2-1 : Data_Width*Num_Inputs];
		index_counter <= index_counter + 1'b1;
	end else if(cur_state != IDLE) begin
		case(max_out_L[Index_Width + Data_Width -1 : Data_Width])
			16'h0: sort_in_LL[7:0]    <= MIN;
			16'h1: sort_in_LL[15:8]   <= MIN;
			16'h2: sort_in_LL[23:16]  <= MIN;
			16'h3: sort_in_LL[31:24]  <= MIN;
			16'h4: sort_in_LL[39:32]  <= MIN;
			16'h5: sort_in_LL[47:40]  <= MIN;
			16'h6: sort_in_LL[55:48]  <= MIN;
			16'h7: sort_in_LL[63:56]  <= MIN;
			16'h8: sort_in_LL[71:64]  <= MIN;
			16'h9: sort_in_LL[79:72]  <= MIN;
			16'ha: sort_in_LL[87:80]  <= MIN;
			16'hb: sort_in_LL[95:88]  <= MIN;
			16'hc: sort_in_LL[103:96] <= MIN;
			16'hd: sort_in_LL[111:104]<= MIN;
			16'he: sort_in_LL[119:112]<= MIN;
			16'hf: sort_in_LL[127:120]<= MIN;
		default: ;
			
		endcase
		
		case(max_out_H[Index_Width + Data_Width -1 : Data_Width])
		
		  16'h10: sort_in_LH[7:0]    <= MIN;
			16'h11: sort_in_LH[15:8]   <= MIN;
			16'h12: sort_in_LH[23:16]  <= MIN;
			16'h13: sort_in_LH[31:24]  <= MIN;
			16'h14: sort_in_LH[39:32]  <= MIN;
			16'h15: sort_in_LH[47:40]  <= MIN;
			16'h16: sort_in_LH[55:48]  <= MIN;
			16'h17: sort_in_LH[63:56]  <= MIN;
			16'h18: sort_in_LH[71:64]  <= MIN;
			16'h19: sort_in_LH[79:72]  <= MIN;
			16'h1a: sort_in_LH[87:80]  <= MIN;
			16'h1b: sort_in_LH[95:88]  <= MIN;
			16'h1c: sort_in_LH[103:96] <= MIN;
			16'h1d: sort_in_LH[111:104]<= MIN;
			16'h1e: sort_in_LH[119:112]<= MIN;
			16'h1f: sort_in_LH[127:120]<= MIN;
		default: ;
			
		endcase
	end
end



always @(posedge sys_clk, negedge sys_rst_n)
begin
	if(!sys_rst_n)
	begin
		cur_state  <= 3'b0;
		next_state <= 3'b0;
	end else if(sorter_clr)
	begin
	    cur_state  <= 3'b0;
		next_state <= 3'b0;
		end
	else begin
		cur_state <= next_state;
	end	
end

always @(*)
begin
	case(cur_state)
	IDLE: begin
		if(sort_en)
			next_state = ITERATION0;
		else next_state = cur_state;
	end
	ITERATION0: next_state = ITERATION1;
	ITERATION1: next_state = ITERATION2;
	ITERATION2: next_state = ITERATION3;
	ITERATION3: next_state = ITERATION4;
	ITERATION4: next_state = IDLE;
	default: next_state = 3'bx;
	endcase
end

always @(posedge sys_clk, negedge sys_rst_n)
begin
	if(!sys_rst_n)
	begin
		E1H_sorter_out0 <= 0;
		E1H_sorter_out1 <= 0;
		E1H_sorter_out2 <= 0;
		E1H_sorter_out3 <= 0;
		E1H_sorter_out4 <= 0;
		E1L_sorter_out0 <= 0;
		E1L_sorter_out1 <= 0;
		E1L_sorter_out2 <= 0;
		E1L_sorter_out3 <= 0;
		E1L_sorter_out4 <= 0;
		E1_sort_en      <= 0;
		E1_index_counter<= 0; 
		sort_enL0 <= 0;
		sort_enL1 <= 0; 
		sort_enL2 <= 0;
		sort_enL3 <= 0;
		sort_enL4 <= 0; 
		sort_enL5 <= 0;  
		last_sortL0 <= 0;  
		last_sortL1 <= 0; 
		last_sortL2 <= 0; 
		last_sortL3 <= 0; 
		last_sortL4 <= 0; 
		last_sortL5 <= 0; 
		E1_last_sort<= 0; 

	end else if(sorter_clr)
	begin
		E1H_sorter_out0 <= 0;
		E1H_sorter_out1 <= 0;
		E1H_sorter_out2 <= 0;
		E1H_sorter_out3 <= 0;
		E1H_sorter_out4 <= 0;
		E1L_sorter_out0 <= 0;
		E1L_sorter_out1 <= 0;
		E1L_sorter_out2 <= 0;
		E1L_sorter_out3 <= 0;
		E1L_sorter_out4 <= 0;
		E1_sort_en      <= 0;
		E1_index_counter<= 0;
		sort_enL0 <= 0;
		sort_enL1 <= 0; 
		sort_enL2 <= 0;
		sort_enL3 <= 0;
		sort_enL4 <= 0; 
		sort_enL5 <= 0;
		last_sortL0 <= 0;  
		last_sortL1 <= 0; 
		last_sortL2 <= 0; 
		last_sortL3 <= 0; 
		last_sortL4 <= 0; 
		last_sortL5 <= 0; 
		E1_last_sort<= 0; 
	end else begin
		sort_enL0 <= sort_en;
		sort_enL1 <= sort_enL0 ;
		sort_enL2 <= sort_enL1;
		sort_enL3 <= sort_enL2;
		sort_enL4 <= sort_enL3; 
		sort_enL5 <= sort_enL4; 
		E1_sort_en      <= sort_enL5;
		
		last_sortL0   <= last_sort;
		last_sortL1   <= last_sortL0 ;
		last_sortL2   <= last_sortL1;
		last_sortL3   <= last_sortL2;
		last_sortL4   <= last_sortL3; 
		last_sortL5   <= last_sortL4; 
		E1_last_sort  <= last_sortL5;
		if(cur_state == ITERATION0)
		begin
			E1H_sorter_out0 <= max_out_H;
			E1L_sorter_out0  <= max_out_L;
			
		end else if(cur_state == ITERATION1)
		begin
			E1H_sorter_out1 <= max_out_H;
			E1L_sorter_out1  <= max_out_L;
			
		end  else if(cur_state == ITERATION2)
		begin
			E1H_sorter_out2 <= max_out_H;
			E1L_sorter_out2  <= max_out_L;
			
		end  else if(cur_state == ITERATION3)
		begin
			E1H_sorter_out3 <= max_out_H;
			E1L_sorter_out3  <= max_out_L;
			
		end  else if(cur_state == ITERATION4)
		begin
			E1H_sorter_out4 <= max_out_H;
			E1L_sorter_out4  <= max_out_L;
			
			E1_index_counter<= index_counter;
		end
	end
end
max16 max16_L (
.sub_data0 ({16'h0,sort_in_LL[7:0    ]}),
.sub_data1 ({16'h1,sort_in_LL[15:8   ]}),
.sub_data2 ({16'h2,sort_in_LL[23:16  ]}),
.sub_data3 ({16'h3,sort_in_LL[31:24  ]}),
.sub_data4 ({16'h4,sort_in_LL[39:32  ]}),
.sub_data5 ({16'h5,sort_in_LL[47:40  ]}),
.sub_data6 ({16'h6,sort_in_LL[55:48  ]}),
.sub_data7 ({16'h7,sort_in_LL[63:56  ]}),
.sub_data8 ({16'h8,sort_in_LL[71:64  ]}),
.sub_data9 ({16'h9,sort_in_LL[79:72  ]}),
.sub_data10({16'ha,sort_in_LL[87:80  ]}),
.sub_data11({16'hb,sort_in_LL[95:88  ]}),
.sub_data12({16'hc,sort_in_LL[103:96 ]}),
.sub_data13({16'hd,sort_in_LL[111:104]}),
.sub_data14({16'he,sort_in_LL[119:112]}),
.sub_data15({16'hf,sort_in_LL[127:120]}),
.max_out   (max_out_L)
);

max16 max16_H (
.sub_data0 ({16'h10,sort_in_LH[7:0    ]}),
.sub_data1 ({16'h11,sort_in_LH[15:8   ]}),
.sub_data2 ({16'h12,sort_in_LH[23:16  ]}),
.sub_data3 ({16'h13,sort_in_LH[31:24  ]}),
.sub_data4 ({16'h14,sort_in_LH[39:32  ]}),
.sub_data5 ({16'h15,sort_in_LH[47:40  ]}),
.sub_data6 ({16'h16,sort_in_LH[55:48  ]}),
.sub_data7 ({16'h17,sort_in_LH[63:56  ]}),
.sub_data8 ({16'h18,sort_in_LH[71:64  ]}),
.sub_data9 ({16'h19,sort_in_LH[79:72  ]}),
.sub_data10({16'h1a,sort_in_LH[87:80  ]}),
.sub_data11({16'h1b,sort_in_LH[95:88  ]}),
.sub_data12({16'h1c,sort_in_LH[103:96 ]}),
.sub_data13({16'h1d,sort_in_LH[111:104]}),
.sub_data14({16'h1e,sort_in_LH[119:112]}),
.sub_data15({16'h1f,sort_in_LH[127:120]}),
.max_out   (max_out_H)
);   
    
endmodule
