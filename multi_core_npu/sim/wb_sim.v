`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 19:26:47
// Design Name: 
// Module Name: wb_sim
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


module wb_sim();
    reg clk;
    reg rst;
    //external data input port for axi bram controller
    reg           i_wb_bramctl_en   ;
    reg  [11:0]   i_wb_bramctl_addr ;
    reg           i_wb_bramctl_we   ;
    reg  [255:0]  i_wb_bramctl_wdata;
    
    //internal port
    reg [11:0]    i_wb_raddr  ;
    reg           i_wb_rd_en  ; 
    wire[255:0]   o_wdata     ;
    wire          o_wdata_vld ;
    
    Wb_Buffer 
    sim_wb(clk, rst, i_wb_bramctl_en, i_wb_bramctl_addr, i_wb_bramctl_we, i_wb_bramctl_wdata,
            i_wb_raddr, i_wb_rd_en, o_wdata, o_wdata_vld);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        rst <= 1;
        i_wb_bramctl_en <= 0;
        i_wb_bramctl_addr <= 0;
        i_wb_bramctl_we <= 0;
        i_wb_bramctl_wdata <= 0;
    end
    
    initial begin
            i_wb_raddr <= 0;
            i_wb_rd_en <= 0;
        #25 i_wb_raddr <= 0;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 1;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 2;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 3;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 4;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 0;
            i_wb_rd_en <= 0;
        #20 i_wb_raddr <= 2;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 3;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 4;
            i_wb_rd_en <= 1;
        #10 i_wb_raddr <= 0;
            i_wb_rd_en <= 0;
    end
    
endmodule
