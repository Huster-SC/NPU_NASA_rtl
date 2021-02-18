`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/29 22:04:44
// Design Name: 
// Module Name: sort_sim
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


module sort_sim();
     //output
        wire   [255:0]sorter_result;
        wire   sorter_valid ;
        wire   last_sort_o;
  
//input
        reg   sys_clk;
        reg   sys_rst_n;
        reg   sorter_en;
        reg   sorter_clr;
        reg   last_sort;
        reg   [255:0]sorter_in;
    
    pe_sort
    sort_sim(sorter_result, sorter_valid, last_sort_o, sys_clk, sys_rst_n, sorter_en, sorter_clr, last_sort, sorter_in);
    
    initial begin
        sys_clk <= 0;
        forever #5 sys_clk <= ~sys_clk;
    end
    
    initial begin
        sys_rst_n <= 1;
        sorter_en <= 0;
        sorter_in <= 0;
        sorter_clr <= 1;
        #10 sorter_clr <= 0;
            sorter_in <= 256'h1f_1e_1d_1c_1b_1a_19_18_17_16_15_14_13_12_11_10_0f_0e_0d_0c_0b_0a_09_08_07_06_05_04_03_02_01_00;
        #10 sorter_en <= 1;
            
        #10 sorter_en <= 0; 
    end
    
endmodule
