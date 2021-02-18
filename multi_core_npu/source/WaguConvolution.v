`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/09/19 18:03:19
// Design Name: 
// Module Name: Wagu
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


module WaguConvolution(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from IAGU
    input feature_load_end,
    
    //from decoder
    input [3:0] mode,
    input [12:0]addr_start_w,
    input [7:0] in_y_length,
    input [7:0] in_piece,
    input [7:0] out_x_length,
    input [7:0] out_y_length,
    input [7:0] out_piece,
    input [4:0] part_num,
    input [3:0] last_part,
    input [3:0] i_kernel,
    input [1:0] i_stride,
    input [1:0] i_pad,
    input [1:0] tilingtype,
    
    //to weight buffer
    output [12:0]o_w_addr,
    output       o_rd_en,
    
    //to IAGU
    output o_group_end,
    
    //to NPE
    output       o_conv_out,
    output [7:0] o_pe_en
    
    //for simulation
//    output [3:0] o_r_WorkState,
//    output [3:0] o_r_WorkState_next,
//    output [7:0] o_kernel_col,
//    output [7:0] o_kernel_row,
//    output [7:0] o_in_piece,
//    output [4:0] o_part_num,
//    output [7:0] o_out_piece,
//    output [7:0] o_row,
//    output [7:0] o_in_row,
//    output [5:0] o_group_cnt
    );
      
    //chanel_num in one piece
    parameter [5:0]group_num = 6'd32;
    
    //mode map
    parameter [3:0] CONV_MODE = 4'd1,
                    POOL_MODE = 4'd4,
                    FC_MODE   = 4'd2,
                    ADD_MODE  = 4'd3;
                    //MATRIX_MODE = 4'd6;
    
    //for state machine
    parameter [2:0] WBR_IDLE             = 3'd0,
                    WBR_START_READY       = 3'd1,
                    WBR_GEN_READY         = 3'd2,  
                    WBR_ADDR_GEN          = 3'd3,
                    WBR_ADJUST_FIRST_ADDR = 3'd4,
                    WBR_UPDATE_COORDINATE = 3'd5; 
    reg [3:0] r_WorkState, r_WorkState_next; 
    
    wire w_skip_row;
    wire w_continue_row;
    wire w_group_end;
    wire w_kernel_col_end;
    wire w_kernel_row_end;
    wire w_in_piece_end;
    wire w_part_end;
    wire w_out_piece_end;
    wire w_out_row_end;
    wire w_feature_weight_end;
    wire w_tiling_end;
    wire [12:0]w_pad_jump_size;
    wire [7:0] w_pe_en;
    wire [7:0] w_last_pe_en;
    
    reg [12:0]r_group_addr;
    reg [12:0]r_out_piece_addr;
    reg [5:0] r_group_cnt;
    reg [3:0] r_kernel_col;
    reg [3:0] r_kernel_row;
    reg [7:0] r_in_piece;
    reg [4:0] r_part_num;
    reg [7:0] r_out_piece;
    reg [7:0] r_out_row;
    reg [7:0] r_in_row;
    reg [7:0] r_pe_en;
    reg       r_group_end;
    reg       r_rd_en;
    reg       r_conv_out;
    
    assign o_group_end = r_group_end;
    assign o_w_addr    = r_group_addr;
    assign o_rd_en     = r_rd_en;
    //assign o_conv_out  = w_group_end && w_kernel_col_end && w_kernel_row_end && w_in_piece_end;
    assign o_conv_out = r_conv_out;
    assign o_pe_en    = r_pe_en;  
    
    assign w_pad_jump_size  = i_kernel * group_num;
    assign w_group_end      = (r_group_cnt  == group_num    - 1);
    assign w_kernel_col_end = (r_kernel_col == i_kernel     - 1);
    assign w_kernel_row_end = (r_kernel_row == i_kernel     - 1);
    assign w_in_piece_end   = (r_in_piece   == in_piece     - 1);
    assign w_part_end       = (r_part_num   == part_num     - 1);
    assign w_out_piece_end  = (r_out_piece  == out_piece    - 1);
    assign w_out_row_end    = (r_out_row    == out_y_length - 1);
    
    
    assign w_tiling_end = w_kernel_col_end && w_kernel_row_end && w_in_piece_end 
                          && w_part_end && w_out_piece_end && w_out_row_end;
    
    assign w_skip_row     = ((tilingtype == 2'b01 || tilingtype == 2'b11) && (r_in_row + r_kernel_row < i_pad)) ? 1'b1 : 1'b0;
    assign w_continue_row = ((tilingtype == 2'b10 && r_in_row + r_kernel_row >= in_y_length) || (tilingtype == 2'b11 && r_in_row + r_kernel_row >= in_y_length + i_pad)) ? 1'b1 : 1'b0;
    
    assign w_last_pe_en = (last_part == 1) ? 8'b00000001 :
                         ((last_part == 2) ? 8'b00000011 :
                         ((last_part == 3) ? 8'b00000111 :
                         ((last_part == 4) ? 8'b00001111 :
                         ((last_part == 5) ? 8'b00011111 :
                         ((last_part == 6) ? 8'b00111111 :
                         ((last_part == 7) ? 8'b01111111 : 
                         ((last_part == 8) ? 8'b11111111 : 8'b0)))))));
    assign w_pe_en = w_part_end ? w_last_pe_en : 8'b11111111;
    
    //for simulation
//    assign o_r_WorkState = r_WorkState;
//    assign o_r_WorkState_next = r_WorkState_next;
//    assign o_kernel_col = r_kernel_col;
//    assign o_kernel_row = r_kernel_row;
//    assign o_group_cnt  = r_group_cnt;
//    assign o_in_piece   = r_in_piece;
//    assign o_part_num   = r_part_num;
//    assign o_out_piece  = r_out_piece;
//    assign o_row        = r_out_row;
//    assign o_in_row     = r_in_row;
    
    //for output
    initial begin
        r_group_addr <= 0;
        r_rd_en      <= 0;
        r_group_end  <= 0;
        r_conv_out   <= 0;
        r_pe_en      <= 0;
        
        r_part_num   <= 0;    
    end
    
    always@(*) begin
        r_rd_en     <= (r_WorkState == WBR_ADDR_GEN);
        r_group_end <= w_group_end;
    end
    
    //state machine for generating weight address 
    always@(posedge clk or negedge rst) begin
        if (!rst)
            r_WorkState <= WBR_IDLE ;
        else 
            r_WorkState <= r_WorkState_next;
    end
    
    always @(*) begin
        if (!rst)
            r_WorkState_next = WBR_IDLE;
        else
            case (r_WorkState)
                WBR_IDLE: begin
                    if(mode == CONV_MODE && start_calculate)
                        r_WorkState_next = WBR_START_READY;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                WBR_START_READY: begin
                    if(feature_load_end)
                       r_WorkState_next = WBR_GEN_READY;                                                                
                    else
                       r_WorkState_next = r_WorkState; 
                end
                
                WBR_GEN_READY:begin
                    if(!w_skip_row && !w_continue_row)
                        r_WorkState_next = WBR_ADDR_GEN;
                    else if(w_tiling_end)
                        r_WorkState_next = WBR_IDLE;                                  
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                WBR_ADDR_GEN: begin
                    if (w_group_end) 
                        r_WorkState_next = WBR_ADJUST_FIRST_ADDR;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                WBR_ADJUST_FIRST_ADDR: begin
                 //here: need to consider both feature and weight tiling end 
                    if(w_tiling_end)
                        r_WorkState_next = WBR_IDLE;        
                    else 
                        r_WorkState_next = WBR_UPDATE_COORDINATE;
                end
                
                WBR_UPDATE_COORDINATE: begin
                    r_WorkState_next = WBR_START_READY;
                end
                
                default:
                    r_WorkState_next = WBR_IDLE;
            endcase
    end
       
    //generate weight buffer address
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_group_addr     <= 0;
            r_out_piece_addr <= 0;
            //r_rd_en          <= 0;
        end else if(r_WorkState == WBR_IDLE) begin
            if(start_calculate) begin
                r_group_addr     <= addr_start_w;
                r_out_piece_addr <= addr_start_w;
                //r_rd_en          <= 0;
            end else begin   
                r_group_addr     <= 0;
                r_out_piece_addr <= 0;
                //r_rd_en          <= 0;
            end            
        end else if(r_WorkState == WBR_ADJUST_FIRST_ADDR) begin
            if(w_out_piece_end && w_part_end && w_in_piece_end && w_kernel_row_end && w_kernel_col_end) begin//next row
                r_out_piece_addr <= addr_start_w;
                r_group_addr     <= addr_start_w;        
            end else if(w_part_end && w_in_piece_end && w_kernel_row_end && w_kernel_col_end) begin//next out_piece
                r_out_piece_addr <= r_group_addr;
                r_group_addr     <= r_group_addr;
            end else if(w_in_piece_end && w_kernel_row_end && w_kernel_col_end) begin//next part 
                r_group_addr     <= r_out_piece_addr;
            end
        end else if(r_WorkState == WBR_GEN_READY) begin
            if(w_skip_row && w_kernel_col_end)
                r_group_addr <= r_group_addr + w_pad_jump_size;     
            else if(w_continue_row && w_kernel_col_end)
                r_group_addr <= r_group_addr + w_pad_jump_size;
            else 
                r_group_addr <= r_group_addr;
        end else if(r_WorkState == WBR_ADDR_GEN) begin
            if(r_group_cnt == group_num) begin
                r_group_addr <= r_group_addr;
                //r_rd_en      <= 0;
            end else begin  
                r_group_addr <= r_group_addr + 1;
                //r_rd_en      <= 1;
            end
        end else begin
            r_group_addr     <= r_group_addr;
            r_out_piece_addr <= r_out_piece_addr;
            //r_rd_en          <= 0;
        end     
    end
    
    //Loop 7: group count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_group_cnt <= 0;
        else if(start_calculate || r_WorkState == WBR_GEN_READY)
            r_group_cnt <= 0;
        else if(r_WorkState == WBR_ADDR_GEN) begin
            if(r_group_cnt == group_num)
                r_group_cnt <= 0;
            else 
                r_group_cnt <= r_group_cnt + 1; 
        end else
            r_group_cnt <= 0;
    end
    
    //Loop 6: kernel column count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_kernel_col <= 0;
        else if(start_calculate)
            r_kernel_col <= 0;
        else if(r_WorkState_next == WBR_GEN_READY) begin
            if(w_skip_row || w_continue_row) begin
                if(w_kernel_col_end)
                    r_kernel_col <= 0;
                else 
                    r_kernel_col <= r_kernel_col + 1;
            end else
                r_kernel_col <= r_kernel_col;       
        end else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end)
                r_kernel_col <= 0;
            else 
                r_kernel_col <= r_kernel_col + 1;
        end else
            r_kernel_col <= r_kernel_col;
    end
    
    //Loop 5: kernel row count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_kernel_row <= 0;
        else if(start_calculate)
            r_kernel_row <= 0;
        else if(r_WorkState_next == WBR_GEN_READY) begin
            if(w_skip_row || w_continue_row)
                if(w_kernel_col_end)
                    if(w_kernel_row_end)
                        r_kernel_row <= 0;
                    else
                        r_kernel_row <= r_kernel_row + 1;
                else
                    r_kernel_row <= r_kernel_row;
            else
                r_kernel_row <= r_kernel_row;
        end else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end)
                if(w_kernel_row_end)
                    r_kernel_row <= 0;
                else
                    r_kernel_row <= r_kernel_row + 1;
             else
                r_kernel_row <= r_kernel_row;
        end else 
            r_kernel_row <= r_kernel_row;
    end
    
    //Loop 4: input piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_in_piece <= 0;
        else if(start_calculate)
            r_in_piece <= 0;
        else if(r_WorkState_next == WBR_GEN_READY) begin
            if(w_skip_row || w_continue_row)
                if(w_kernel_col_end && w_kernel_row_end)
                    if(w_in_piece_end)
                        r_in_piece <= 0;
                    else
                        r_in_piece <= r_in_piece + 1;
                else
                    r_in_piece <= r_in_piece;
            else
                r_in_piece <= r_in_piece;
        end else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end)
                if(w_in_piece_end)
                    r_in_piece <= 0;
                else
                    r_in_piece <= r_in_piece + 1;
            else
                r_in_piece <= r_in_piece;
        end else
            r_in_piece <= r_in_piece;
    end
    
    //Loop 3: part count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_part_num <= 0;
        else if(start_calculate)
            r_part_num <= 0;
        else if(r_WorkState_next == WBR_GEN_READY) begin
            if(w_skip_row || w_continue_row)
                if(w_kernel_col_end && w_kernel_row_end && w_in_piece_end)
                    if(w_part_end)
                        r_part_num <= 0;
                    else
                        r_part_num <= r_part_num + 1;
                else
                    r_part_num <= r_part_num;
            else
                r_part_num <= r_part_num;
        end else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end && w_in_piece_end)
                if(w_part_end)
                    r_part_num <= 0;
                else
                    r_part_num <= r_part_num + 1;
            else
                r_part_num <= r_part_num;
        end else
            r_part_num <= r_part_num;
    end
    
    //Loop 2: output piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_out_piece <= 0;
        else if(start_calculate)
            r_out_piece <= 0;
        else if(r_WorkState_next == WBR_GEN_READY) begin
            if(w_skip_row || w_continue_row)
                if(w_kernel_col_end && w_kernel_row_end && w_in_piece_end && w_part_end)
                    if(w_out_piece_end)
                        r_out_piece <= 0;
                    else
                        r_out_piece <= r_out_piece + 1;
                else
                    r_out_piece <= r_out_piece;
            else
                r_out_piece <= r_out_piece;
        end
        else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end && w_in_piece_end && w_part_end)
                if(w_out_piece_end)
                    r_out_piece <= 0;
                else
                    r_out_piece <= r_out_piece + 1;
            else
                r_out_piece <= r_out_piece;            
        end else
            r_out_piece <= r_out_piece;
    end
    
    //Loop 1: output row count 
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_out_row <= 0;
            r_in_row  <= 0;
        end else if(r_WorkState == WBR_IDLE) begin
            r_out_row <= 0;
            r_in_row  <= 0;
        end else if(r_WorkState_next == WBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end && w_in_piece_end && w_part_end && w_out_piece_end) begin
                if(w_out_row_end) begin 
                    r_out_row <= 0;
                    r_in_row  <= 0;
                end else begin
                    r_out_row <= r_out_row + 1;
                    r_in_row  <= r_in_row + i_stride;
                end       
            end else begin
                r_out_row <= r_out_row;
                r_in_row  <= r_in_row;
            end      
        end else begin
            r_out_row <= r_out_row;
            r_in_row  <= r_in_row;
        end
    end
    
    //need to consider when to output result
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_conv_out <= 0;
        else if(start_calculate)
            r_conv_out <= 0;
        else if(r_WorkState_next == WBR_ADJUST_FIRST_ADDR) begin
            if(w_kernel_col_end && w_in_piece_end)
                if(tilingtype == 2'b10)
                    if(r_in_row + r_kernel_row == in_y_length - 1
                       || (r_in_row + r_kernel_row < in_y_length - 1 && r_kernel_row == i_kernel - 1))
                        r_conv_out <= 1;
                    else
                        r_conv_out <= 0;
                else if(tilingtype == 2'b11)
                    if(r_in_row + r_kernel_row == in_y_length + i_pad - 1
                       || (r_in_row + r_kernel_row < in_y_length + i_pad - 1 && r_kernel_row == i_kernel - 1))
                        r_conv_out <= 1;
                    else
                        r_conv_out <= 0;            
                else if(w_kernel_row_end)
                    r_conv_out <= 1;
                else
                    r_conv_out <= 0;     
        end else 
            r_conv_out <= 0;    
    end
    
    //need to decide next pe_en(which pe to be used)
    always @(posedge clk or negedge rst) begin
        if (!rst)
            r_pe_en <= 0;
        else
            if (start_calculate || r_conv_out)
                r_pe_en <= w_pe_en;
            else
                r_pe_en <= r_pe_en;
    end
    
endmodule
