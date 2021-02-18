`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: SiChang
// 
// Create Date: 2020/10/29 14:47:45
// Design Name: 
// Module Name: IaguDepthConvolution
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


module IaguDepthConvolution(
    //from Top
    input clk,
    input rst,
    
    //from schedule
    input start_calculate,
    
    //from IAGU
    input weight_load_end,
    
    //from decoder
    input [12:0]addr_start_d,
    input [7:0] in_x_length,
    input [7:0] in_y_length,
    input [7:0] in_piece,
    input [7:0] out_y_length,
    input [4:0] part_num,
    input [3:0] last_part,
    input [3:0] i_kernel,
    input [1:0] i_stride,
    input [1:0] i_pad,
    input [1:0] tilingtype,
    
    //to IO buffer
    output [12:0]o_d_addr,
    output       o_rd_en,
    output       o_pad_en,
    
    //to WAGU
    output       o_feature_end
    );
    
    //Number of parallel PE arrays
    parameter [4:0] pe_col_num = 5'd8;
    
    //for state machine
    parameter [2:0] IBR_IDLE              = 3'd0,
                     IBR_GEN_READY         = 3'd1,
                     IBR_GEN_FIRST_ADDR    = 3'd2,
                     IBR_ADDR_GEN          = 3'd3,
                     IBR_JUDGE             = 3'd4,
                     IBR_UPDATE_COORDINATE = 3'd5,
                     IBR_WAIT_GROUP        = 3'd6;
    reg [2:0] r_WorkState,r_WorkState_next;
    
    wire skip_row;   
    wire first_addr_ready;
    wire load_feature_end;
    
    wire w_kernel_col_end;
    wire w_kernel_row_end;
    wire w_in_piece_end;
    wire w_part_end;
    wire w_out_row_end;
    wire w_tiling_end;
    
    wire [12:0] one_line_size;   
    wire [4 :0] group_num;
    wire [12:0] part_jump_size;
    
    wire signed [13:0] kernel_col_begin_addr;
    reg signed  [13:0] row_begin_addr;
    reg signed  [13:0] part_begin_addr;
    reg signed  [13:0] piece_begin_addr;
    reg signed  [13:0] kernel_row_begin_addr;
    
    reg [12:0]r_group_addr;
    reg [5:0] r_group_cnt;
    reg [3:0] r_kernel_col;
    reg [3:0] r_kernel_row;
    reg [7:0] r_in_piece;
    reg [4:0] r_part_num;
    reg [7:0] r_out_row;
    reg [7:0] r_in_row; 
    reg       r_rd_en;
    reg       r_pad_en;    
    //for computing first address of next feature group
    reg   r_start;
    reg   r1_start;
    reg   r2_start;
    reg   r3_start;
    reg   r4_start;
    //for output
    reg r_load_feature_end;
    
    assign one_line_size    = in_x_length   * in_piece;
    assign part_jump_size   = pe_col_num    * i_stride;
    
    assign o_feature_end    = r_load_feature_end;
    assign o_d_addr         = r_group_addr;
    assign o_rd_en          = r_rd_en;
    assign o_pad_en         = r_pad_en;
    
    assign w_kernel_col_end = (r_kernel_col == i_kernel     - 1);
    assign w_kernel_row_end = (r_kernel_row == i_kernel     - 1);
    assign w_in_piece_end   = (r_in_piece   == in_piece     - 1);
    assign w_part_end       = (r_part_num   == part_num     - 1);
    assign w_out_row_end    = (r_out_row    == out_y_length - 1);
    assign group_num        = w_part_end ? last_part : pe_col_num;
    assign load_feature_end = (r_group_cnt == group_num);
    assign first_addr_ready = r4_start;
    
    assign w_tiling_end = w_kernel_col_end && w_kernel_row_end && w_in_piece_end && w_part_end && w_out_row_end;
    
    assign skip_row =   (  (tilingtype == 2'b10 && r_in_row + r_kernel_row >= in_y_length) 
                        || (tilingtype == 2'b11 && r_in_row + r_kernel_row >= in_y_length + i_pad)
                        || (tilingtype == 2'b01 || tilingtype == 2'b11) && (r_in_row + r_kernel_row < i_pad)    ) ? 1'b1 : 1'b0; 
    
    initial begin
        r_group_addr <= 0;
        r_rd_en      <= 0;
        r_pad_en     <= 0;
        r_load_feature_end <= 0;
        r_part_num <= 0;
    end
    
    always@(*) begin
        r_rd_en <= (r_WorkState == IBR_ADDR_GEN);
        r_load_feature_end <= (r_WorkState == IBR_JUDGE);
    end
    
    //state machine for generating feature address 
    always@(posedge clk or negedge rst) begin
        if (!rst)
            r_WorkState <= IBR_IDLE;
        else 
            r_WorkState <= r_WorkState_next;
    end
    
    always @(*) begin
        if (!rst)
            r_WorkState_next = IBR_IDLE;
        else
            case (r_WorkState)
                IBR_IDLE: begin
                    if(start_calculate)
                        r_WorkState_next = IBR_GEN_READY;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                IBR_GEN_READY: begin
                    if(!skip_row)
                        r_WorkState_next = IBR_GEN_FIRST_ADDR;
                    else if(w_tiling_end)
                        r_WorkState_next = IBR_IDLE;
                    else
                        r_WorkState_next = r_WorkState;    
                end
                
                IBR_GEN_FIRST_ADDR: begin
                    if(first_addr_ready)
                        r_WorkState_next = IBR_ADDR_GEN;
                    else
                        r_WorkState_next = r_WorkState;    
                end 
                
                IBR_ADDR_GEN: begin
                    if(load_feature_end)
                        r_WorkState_next = IBR_JUDGE;
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                IBR_JUDGE: begin
                    //here: need to consider tiling end
                    if(w_tiling_end)
                        r_WorkState_next = IBR_IDLE;
                    else 
                        r_WorkState_next = IBR_UPDATE_COORDINATE;
                end  
                
                IBR_UPDATE_COORDINATE: begin
                    r_WorkState_next = IBR_WAIT_GROUP;    
                end

                IBR_WAIT_GROUP: begin
                    if(weight_load_end)
                        r_WorkState_next = IBR_GEN_READY;                                                              
                    else
                        r_WorkState_next = r_WorkState;
                end
                
                default:
                    r_WorkState_next = IBR_IDLE;
            endcase
    end
    
    //generate feature map address
    assign kernel_col_begin_addr = part_begin_addr + r_kernel_col + r_group_cnt * i_stride; 
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_group_addr <= 0;
            r_pad_en     <= 0;
        end else if(r_WorkState_next == IBR_IDLE) begin
            r_group_addr <= 0;
            r_pad_en     <= 0;
        end else if(r_WorkState_next == IBR_ADDR_GEN) begin
            if(r_group_cnt == group_num) begin 
                r_group_addr <= 0;
                r_pad_en     <= 0; 
            end else begin 
                r_group_addr <= addr_start_d + kernel_row_begin_addr + kernel_col_begin_addr - i_pad;
                r_pad_en     <= (r_part_num == 0 && kernel_col_begin_addr < i_pad || kernel_col_begin_addr >= in_x_length + i_pad);              
            end
        end else begin
            r_group_addr <= 0;
            r_pad_en     <= 0;
        end        
    end
    
    //group load count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_group_cnt <= 0;
        else if(start_calculate || r_WorkState_next == IBR_WAIT_GROUP)
            r_group_cnt <= 0;
        else if(r_WorkState_next == IBR_ADDR_GEN) begin
            if(r_group_cnt == group_num)
                r_group_cnt <= 0;
            else begin
                r_group_cnt <= r_group_cnt + 1; 
            end
        end else
            r_group_cnt <= 0;
    end
    
    //Loop 6: kernel column count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_kernel_col <= 0;
        else if(start_calculate)
            r_kernel_col <= 0;
        else if(r_WorkState_next == IBR_GEN_READY) begin
            if(skip_row) begin
                if(w_kernel_col_end)
                    r_kernel_col <= 0;
                else 
                    r_kernel_col <= r_kernel_col + 1;
            end else
                r_kernel_col <= r_kernel_col;
        end else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
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
        else if(r_WorkState_next == IBR_GEN_READY) begin
            if(skip_row)
                if(w_kernel_col_end)
                    if(w_kernel_row_end)
                        r_kernel_row <= 0;
                    else
                        r_kernel_row <= r_kernel_row + 1;
                else
                    r_kernel_row <= r_kernel_row;
            else
                r_kernel_row <= r_kernel_row;
        end else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
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
    
    //Loop 3: part count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_part_num <= 0;
        else if(start_calculate)
            r_part_num <= 0;
        else if(r_WorkState_next == IBR_GEN_READY) begin
            if(skip_row) begin
                if(w_kernel_col_end && w_kernel_row_end)
                    if(w_part_end)
                        r_part_num <= 0;
                    else
                        r_part_num <= r_part_num + 1;
                else
                    r_part_num <= r_part_num;
            end else
                r_part_num <= r_part_num;
        end else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end)
                if(w_part_end)
                    r_part_num <= 0;
                else
                    r_part_num <= r_part_num + 1;
            else
                r_part_num <= r_part_num;
        end else
            r_part_num <= r_part_num;
    end
    
    //Loop 4: input piece count
    always@(posedge clk or negedge rst) begin
        if(!rst)
            r_in_piece <= 0;
        else if(start_calculate)
            r_in_piece <= 0;
        else if(r_WorkState_next == IBR_GEN_READY) begin
            if(skip_row) begin
                if(w_kernel_col_end && w_kernel_row_end && w_part_end)
                    if(w_in_piece_end)
                        r_in_piece <= 0;
                    else
                        r_in_piece <= r_in_piece + 1;
                else
                    r_in_piece <= r_in_piece;
            end else
                r_kernel_col <= r_kernel_col;
        end else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end && w_part_end)
                if(w_in_piece_end)
                    r_in_piece <= 0;
                else
                    r_in_piece <= r_in_piece + 1;
            else
                r_in_piece <= r_in_piece;
        end else
            r_in_piece <= r_in_piece;
    end
    
    //Loop 1: output row count 
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r_out_row <= 0;
            r_in_row  <= 0;
        end else if(start_calculate) begin
            r_out_row <= 0;
            r_in_row  <= 0;
        end else if(r_WorkState_next == IBR_UPDATE_COORDINATE) begin
            if(w_kernel_col_end && w_kernel_row_end && w_part_end && w_in_piece_end) begin
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
    
    //compute first address of next group
    always@(posedge clk or negedge rst) begin
        if(!rst) 
            r_start <= 0;
        else
            r_start <= r_WorkState_next == IBR_GEN_FIRST_ADDR;
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            r1_start <= 1'd0;
            r2_start <= 1'd0;
            r3_start <= 1'd0;
            r4_start <= 1'd0;
        end else begin
            r1_start <= r_start;
            r2_start <= r1_start;
            r3_start <= r2_start;
            r4_start <= r3_start;
        end
    end  
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            row_begin_addr <= 0;
        else  if(start_calculate)
            row_begin_addr <= 0;
        else if(r_WorkState_next == IBR_GEN_FIRST_ADDR) begin
            if(r1_start) begin
                if(tilingtype == 2'b01 || tilingtype == 2'b11)
                    row_begin_addr <= (r_in_row - i_pad) * one_line_size;
                else 
                    row_begin_addr <= r_in_row * one_line_size;
            end else
                row_begin_addr <= row_begin_addr;    
        end else
            row_begin_addr <= row_begin_addr;       
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            part_begin_addr  <= 0;
            piece_begin_addr <= 0;
        end else if(start_calculate) begin
            part_begin_addr  <= 0;
            piece_begin_addr <= 0;
        end else if(r_WorkState_next == IBR_GEN_FIRST_ADDR) begin
            if(r2_start) begin
                part_begin_addr  <= r_part_num     * part_jump_size;
                piece_begin_addr <= row_begin_addr + r_in_piece * in_x_length;
            end else begin
                part_begin_addr  <= part_begin_addr;
                piece_begin_addr <= piece_begin_addr;
            end
        end else begin
            part_begin_addr  <= part_begin_addr;
            piece_begin_addr <= piece_begin_addr;
        end
    end
    
    always@(posedge clk or negedge rst) begin
        if(!rst)
            kernel_row_begin_addr <= 0;
        else if(start_calculate)
            kernel_row_begin_addr <= 0;
        else if(r_WorkState_next == IBR_GEN_FIRST_ADDR) begin
            if(r3_start)
                kernel_row_begin_addr <= piece_begin_addr + r_kernel_row * one_line_size;
            else
                kernel_row_begin_addr <= kernel_row_begin_addr;
        end else
            kernel_row_begin_addr <= kernel_row_begin_addr;
    end
    
endmodule
