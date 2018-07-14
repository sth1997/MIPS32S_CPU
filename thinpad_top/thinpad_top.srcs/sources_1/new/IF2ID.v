`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 15:51:57
// Design Name: 
// Module Name: IF2ID
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
`include "CONST.v"

module IF2ID(
    input wire clk, 
    input wire rst,
    input wire [5 : 0] bubble_notice,
    input wire flush_flag,
    input wire [`InstAddrBus] PC_input,
    input wire [`InstBus] inst_input,
    
    input wire is_inst_tlbl_input,
    output reg is_inst_tlbl_output,
    
    output reg [`InstAddrBus] PC_output,
    output reg [`InstBus] inst_output
    );
    always @ (posedge clk) 
        begin
            if (rst == `RstEnable) 
                begin
                    PC_output <= `ZeroWord;
                    inst_output <= `ZeroWord;
                    is_inst_tlbl_output <= 1'b0;
                end 
            else if (flush_flag == 1'b1)
                begin
                      PC_output <= `ZeroWord;
                      inst_output <= `ZeroWord;
                      is_inst_tlbl_output <= 1'b0;
                end
            else if (bubble_notice[1] == `NoStop) 
                begin
                    PC_output <= PC_input;
                    inst_output <= (is_inst_tlbl_input ? `ZeroWord: inst_input);
                    is_inst_tlbl_output <= is_inst_tlbl_input;
                end
            else if (bubble_notice[2] == `NoStop) 
                begin 
                    PC_output <= `ZeroWord;
                    inst_output <= `ZeroWord;
                    is_inst_tlbl_output <= 1'b0;
                end
        end
endmodule
