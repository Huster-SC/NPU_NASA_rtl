`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 21:55:40
// Design Name: 
// Module Name: iob_sim
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


module iob_sim();
    reg clk;
    reg rst;
    //external data input port for axi bram controller
    reg           i_iob_extern_en    ;
    reg  [11:0]   i_iob_bramctl_addr ;
    reg           i_iob_bramctl_en   ;
    wire [255:0]  o_iob_bramctl_rdata;
    reg           i_iob_bramctl_we   ;
    reg  [255:0]  i_iob_bramctl_wdata;
    
    //internal port
    reg  [11:0]   i_iob_raddr ;
    reg           i_iob_rd_en ;
    reg           i_iob_pad_en;
    reg  [11:0]   i_iob_waddr ;
    reg           i_iob_wr_en ;
    reg  [255:0]  i_iob_wdat  ;
    reg           i_rsel      ;//'1' r;'0'w
    reg           i_wsel      ;
    wire [255:0]  o_mdata     ;
    wire          o_mdata_vld ;
    
    IO_Buffer
    sim_iob(clk, rst, i_iob_extern_en, i_iob_bramctl_addr, i_iob_bramctl_en, o_iob_bramctl_rdata, i_iob_bramctl_we, i_iob_bramctl_wdata,
            i_iob_raddr, i_iob_rd_en, i_iob_pad_en, i_iob_waddr, i_iob_wr_en, i_iob_wdat, i_rsel, i_wsel, o_mdata, o_mdata_vld);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        rst <= 1;
        i_iob_extern_en <= 0;
        i_iob_bramctl_addr <= 0;
        i_iob_bramctl_en <= 0;
        i_iob_bramctl_we <= 0;
        i_iob_bramctl_wdata <= 0;
        i_iob_waddr <= 0;
        i_iob_wr_en <= 0;
        i_iob_wdat <= 0;
        i_rsel <= 1;
        i_wsel <= 0;
    end
    
    initial begin
            i_iob_raddr <= 0;
            i_iob_rd_en <= 0;
            i_iob_pad_en <= 0;
        #25 i_iob_pad_en <= 1;
        #10 i_iob_pad_en <= 0;
            i_iob_raddr <= 1;
            i_iob_rd_en <= 1;
        #10 i_iob_raddr <= 2;
            i_iob_rd_en <= 1;
        #10 i_iob_raddr <= 3;
            i_iob_rd_en <= 1;
        #10 i_iob_raddr <= 0;
            i_iob_rd_en <= 0;
        #10 i_iob_raddr <= 1;
            i_iob_rd_en <= 1;
        #10 i_iob_raddr <= 2;
            i_iob_rd_en <= 1;
        #10 i_iob_raddr <= 3;
            i_iob_rd_en <= 1;
        #10 i_iob_raddr <= 0;
            i_iob_rd_en <= 0;
    end
    
endmodule
