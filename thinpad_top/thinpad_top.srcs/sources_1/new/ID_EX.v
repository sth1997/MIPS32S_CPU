`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/05 12:44:58
// Design Name: 
// Module Name: ID_EX
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

module ID_EX(
	input wire clk,
	input wire rst,
	input wire[5:0] bubble_notice,

	input wire[`AluOpBus] id_aluop,
	input wire[`AluSelBus] id_alusel,
	input wire[`RegBus] id_reg1,
	input wire[`RegBus] id_reg2,
	input wire[`RegAddrBus] id_wd,
	input wire id_wreg,
	
	input wire id_is_in_delayslot,
	input wire[`RegBus] id_link_addr,
	input wire next_inst_in_delayslot_input,
	
    input wire[`RegBus] id_inst,


    input wire flush_flag,
    input wire[`RegBus] id_current_inst_addr,

	output reg[`AluOpBus] ex_aluop,
	output reg[`AluSelBus] ex_alusel,
	output reg[`RegBus] ex_reg1,
	output reg[`RegBus] ex_reg2,
	output reg[`RegAddrBus] ex_wd,
	output reg ex_wreg,
	
	output reg ex_is_in_delayslot,
	output reg[`RegBus] ex_link_addr,
	
	output reg is_in_delayslot_output,

    output reg[`RegBus] ex_inst
	
);

	always @ (posedge clk) 
        begin
            if ((rst == `RstEnable)||(flush_flag == 1'b1)) 
                begin
                    ex_aluop <= `EXE_NOP_OP;
                    ex_alusel <= `EXE_RES_NOP;
                    ex_reg1 <= `ZeroWord;
                    ex_reg2 <= `ZeroWord;
                    ex_wd <= `NOPRegAddr;
                    ex_wreg <= `WriteDisable;
                    ex_link_addr <= `ZeroWord;
                    ex_is_in_delayslot <= `NotInDelaySlot;
                    is_in_delayslot_output <= `NotInDelaySlot;
                    ex_inst <= `ZeroWord;
                end 
            else if(bubble_notice[2] == `Stop && bubble_notice[3] == `NoStop) 
                begin
                    ex_aluop <= `EXE_NOP_OP;
                    ex_alusel <= `EXE_RES_NOP;
                    ex_reg1 <= `ZeroWord;
                    ex_reg2 <= `ZeroWord;
                    ex_wd <= `NOPRegAddr;
                    ex_wreg <= `WriteDisable;	
                    ex_link_addr <= `ZeroWord;
                    ex_is_in_delayslot <= `NotInDelaySlot;	
                    ex_inst <= `ZeroWord;	
                end 
            else if(bubble_notice[2] == `NoStop) begin		
                ex_aluop <= id_aluop;
                ex_alusel <= id_alusel;
                ex_reg1 <= id_reg1;
                ex_reg2 <= id_reg2;
                ex_wd <= id_wd;
                ex_wreg <= id_wreg;		
                ex_link_addr <= id_link_addr;
                ex_is_in_delayslot <= id_is_in_delayslot;
                is_in_delayslot_output <= next_inst_in_delayslot_input;
                ex_inst <= id_inst;
            end
        end
	
endmodule