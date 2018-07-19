`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 14:34:45
// Design Name: 
// Module Name: IF_PC_Reg
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

module IF_PC_Reg(
    input wire clk, 
    input wire rst,
    input wire [5 : 0] bubble_notice,
    input wire branch_flag,
    input wire[`RegBus] branch_target_address_input,
    input wire flush_flag,
    input wire [`RegBus] new_PC_address,
    
    output reg[`RegBus] PC_output,
    output reg[`RegBus] chip_enable_flag
    );
    always @(posedge clk)
        begin
            if (rst == `RstEnable)
                begin
                    chip_enable_flag <= `ChipDisable;
                end
            else
                begin
                    chip_enable_flag <= `ChipEnable;
                end
            if (chip_enable_flag == `ChipDisable) 
                begin
                    PC_output <= 32'h90800000;
                end
            else
                begin
                    if (flush_flag == 1'b1)
                        begin
                            PC_output <= new_PC_address;
                        end
                    else
                        begin
                            if (bubble_notice[0] == `NoStop)
                                begin
                                    if (branch_flag == `Branch)
                                        begin
                                            PC_output <= branch_target_address_input;
                                        end
                                    else
                                        begin
                                            PC_output <= PC_output + 4'h4;
                                        end
                                end
                        end
                end
        end
endmodule
