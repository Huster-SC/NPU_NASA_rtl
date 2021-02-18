`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/10/29 17:43:41
// Design Name: 
// Module Name: Globle_Buffer
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


module Globle_Buffer(
    //from Top
    input        clk,
    input        rst,
    //external data input port for axi bram controller
    input        i_gb_bramctl_en    ,
    input [12:0] i_gb_bramctl_addr  ,
    input        i_gb_bramctl_we    ,
    input [255:0]i_gb_bramctl_wdata ,
    output[255:0]o_gb_bramctl_data  ,
    output       o_gb_bramctl_vld   ,        
    //internal port
    input [12:0] i_gb_raddr        ,
    input        i_gb_rd_en        ,
    input        i_gb_pad_en       ,
    input [12:0] i_gb_waddr        ,
    input        i_gb_wr_en        ,
    input [255:0]i_gb_wdata        ,
    output[255:0]o_data            ,
    output       o_data_vld            
    );
    
    wire [12:0] read_addr;
    wire [12:0] write_addr;
    wire [255:0]write_data;
    wire        write_en;
    wire [255:0]data_out;
    
    reg r_gb_bramctl_vld;
    reg r_data_vld;
    
    assign read_addr  = i_gb_bramctl_addr  | i_gb_raddr;
    assign write_addr = i_gb_bramctl_addr  | i_gb_waddr;
    assign write_data = i_gb_bramctl_wdata | i_gb_wdata;
    assign write_en   = i_gb_bramctl_we    | i_gb_wr_en;
    
    assign o_data            = i_gb_pad_en ? 256'd0 : data_out; 
    assign o_gb_bramctl_data = data_out;
    assign o_data_vld        = r_data_vld;
    assign o_gb_bramctl_vld  = r_gb_bramctl_vld;
    
    initial begin
       r_data_vld       <= 0;
       r_gb_bramctl_vld <= 0; 
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_gb_bramctl_vld <= 0;
        else if(i_gb_bramctl_en && !i_gb_bramctl_we)
            r_gb_bramctl_vld <= 1;
        else
            r_gb_bramctl_vld <= 0;    
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_data_vld <= 0;
        else if(i_gb_rd_en || i_gb_pad_en)
            r_data_vld <= 1;
        else
            r_data_vld <= 0;        
    end
    
    GlobleBuffer_256X8192
    globle_buffer(
        .clka       (clk            ),   // input wire clka
        .ena        (1'b1           ),   // input wire ena
        .wea        (write_en       ),   // input wire [0 : 0] wea
        .addra      (write_addr     ),   // input wire [12 : 0] addra
        .dina       (write_data     ),   // input wire [255 : 0] dina
        .clkb       (clk            ),   // input wire clkb
        .enb        (1'b1           ),   // input wire enb
        .addrb      (read_addr      ),   // input wire [12 : 0] addrb
        .doutb      (data_out       )    // output wire [255 : 0] doutb      
    );
endmodule
