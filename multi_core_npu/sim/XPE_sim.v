`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/11 21:51:41
// Design Name: 
// Module Name: XPE_sim
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


module XPE_sim();
    //from top
    reg clk;
    reg rst;
    
    //from schedule
    reg calculate_enble;
    
    reg i_sorter_op;
    
    //from decoder
    reg [3:0]mode;
    reg [1:0]xpe_mode;
    reg [4:0]part_num;
    reg [7:0]out_piece;
    reg [7:0]addr_start_b;
    reg [3:0]i_q_encode;
    reg [3:0]w_q_encode;
    reg [3:0]o_q_encode;
    reg [7:0]avg_pooling_coe;
    
    //from NPE
    reg [511:0] npe_data_out;
    reg         npe_data_valid;
    
    //from wagu
    reg pe_out_en;
    
    //from bias buffer
    reg [511:0] bias_data;
    reg         bias_data_valid;
    
    //from Oagu
    reg calculate_end;
    
    //to bias buffer
    wire [7:0] o_b_addr;
    wire       o_rd_en;
    
    //to IO buffer
    wire [255:0] o_xpe_data_out;
    wire         o_xpe_data_valid;
    
    wire [511:0] o_relu_out ;
    wire [511:0] o_final_round; 
    wire [255:0] o_round_out;
    
    XPE
    sim_XPE(clk, rst, calculate_enble, i_sorter_op, mode, xpe_mode, part_num, out_piece, addr_start_b,
            i_q_encode, w_q_encode, o_q_encode, avg_pooling_coe, npe_data_out, npe_data_valid, pe_out_en, bias_data, bias_data_valid,
            calculate_end, o_b_addr, o_rd_en, o_xpe_data_out, o_xpe_data_valid, o_relu_out, o_final_round,o_round_out);
    
    initial begin
        clk <= 0;
        forever #5 clk <= ~clk;
    end
    
    initial begin
        calculate_enble     = 1'd0;
        #10 calculate_enble = 1'd1;
        #10 calculate_enble = 1'd0;
    end
    
    initial begin
        rst         <= 1;
        i_sorter_op <= 1'b0;
        mode        <= 4'd3;
        xpe_mode    <= 2'd1;
        part_num    <= 5'd1;
        out_piece   <= 8'd1;
        addr_start_b<= 8'd0;
        i_q_encode  <= 4'd1;
        w_q_encode  <= 4'd1;
        o_q_encode  <= 4'd1;
        avg_pooling_coe <= 8'd1;
        pe_out_en <= 0;
        bias_data <= 0;
        bias_data_valid <= 0;
        calculate_end <= 0;
    end
    
    initial begin
        npe_data_out     <= 0;
        npe_data_valid   <= 0;
        
        #35 npe_data_out   <= 512'd3;
            npe_data_valid <= 1;
        //#10 npe_data_valid <= 0;
        
        #10 npe_data_out   <= 512'd5;
            npe_data_valid <= 1;
        //#10 npe_data_valid <= 0;
        
        #10 npe_data_out   <= 512'd7;
            npe_data_valid <= 1;
        #10 npe_data_valid <= 0;
    end

endmodule
