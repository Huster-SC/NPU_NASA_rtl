`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/22 15:28:35
// Design Name: 
// Module Name: router_sim
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


module router_sim();
    reg clk;
    reg rst;
    reg vertical_rotate;
    reg horizon_rotate;
    reg ip_router_exchange;
    reg [3:0]  row;
    reg [3:0]  col;
    reg [255:0]east_in_data;
    reg        east_in_en;
    wire[255:0]east_out_data;
    wire       east_out_en;
    reg [255:0]west_in_data;
    reg        west_in_en;
    wire[255:0]west_out_data;
    wire       west_out_en;
    reg [255:0]north_in_data;
    reg        north_in_en;
    wire[255:0]north_out_data;
    wire       north_out_en;
    reg [255:0]south_in_data;
    reg        south_in_en;
    wire[255:0]south_out_data;
    wire       south_out_en;
    reg [255:0]ip_in_data;
    reg        ip_in_en;
    wire[255:0]ip_out_data;
    wire       ip_out_en;
    
    Router
    sim_router(clk, rst, vertical_rotate, horizon_rotate, ip_router_exchange, row, col,
               east_in_data, east_in_en, east_out_data, east_out_en,
               west_in_data, west_in_en, west_out_data, west_out_en,
               north_in_data, north_in_en, north_out_data, north_out_en,
               south_in_data, south_in_en, south_out_data, south_out_en,
               ip_in_data, ip_in_en, ip_out_data, ip_out_en);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        rst <= 1;
        row <= 0;
        col <= 0;
        vertical_rotate <= 0;
        horizon_rotate  <= 0;
        ip_router_exchange <= 0;
        east_in_data <= 0;
        east_in_en   <= 0;
        west_in_data <= 0;
        west_in_en   <= 0;
        north_in_data<= 0;
        north_in_en  <= 0;
        south_in_data<= 0;
        south_in_en  <= 0;
        ip_in_data   <= 0;
        ip_in_en     <= 0;
    end
    
    initial begin
        #10 ip_in_data <= 256'd1;
            ip_in_en   <= 1;
        #10 ip_in_data <= 256'd0;
            ip_in_en   <= 0;
            horizon_rotate <= 1;
        #10 horizon_rotate <= 0;
        #10 ip_router_exchange <= 1;
        #10 ip_router_exchange <= 0;   
    end
    
endmodule
