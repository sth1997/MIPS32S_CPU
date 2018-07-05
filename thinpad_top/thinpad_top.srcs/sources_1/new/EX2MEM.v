`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/05 15:21:43
// Design Name: 
// Module Name: EX2MEM
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

module ex_mem(

	input wire clk,
	input wire rst,
	
	input wire[5: 0] bubble_notice,

	input wire[`RegAddrBus] ex_waddr,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata,

	input wire[`AluOpBus] ex_aluop,
	input wire[`RegBus] ex_mem_addr,
	input wire[`RegBus] ex_reg2,

	input wire flush_flag,
    input wire[`RegBus] ex_current_inst_addr,
    input wire ex_is_in_delayslot,
    
	output reg[`RegAddrBus] mem_waddr,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,

	output reg[`AluOpBus] mem_aluop,
	output reg[`RegBus] mem_mem_addr,
	output reg[`RegBus] mem_reg2,

	output reg[`RegBus] mem_current_inst_addr,
	output reg mem_is_in_delayslot		
	
);


	always @ (posedge clk) 
        begin
            if ((rst == `RstEnable)||(flush_flag == 1'b1)) 
                begin
                    mem_waddr <= `NOPRegAddr;
                    mem_wreg <= `WriteDisable;
                    mem_wdata <= `ZeroWord;	
                    mem_aluop <= `EXE_NOP_OP;
                    mem_mem_addr <= `ZeroWord;
                    mem_reg2 <= `ZeroWord;
                    mem_current_inst_addr <= `ZeroWord;
                    mem_is_in_delayslot <= `NotInDelaySlot;
                end
            else if(bubble_notice[3] == `Stop && bubble_notice[4] == `NoStop) 
                begin
                    mem_waddr <= `NOPRegAddr;
                    mem_wreg <= `WriteDisable;
                    mem_wdata <= `ZeroWord;
                    mem_aluop <= `EXE_NOP_OP;
                    mem_mem_addr <= `ZeroWord;
                    mem_reg2 <= `ZeroWord;	
                    mem_current_inst_addr <= `ZeroWord;
                    mem_is_in_delayslot <= `NotInDelaySlot;			  				    
                end 
            else if(bubble_notice[3] == `NoStop) 
                begin
                    mem_waddr <= ex_waddr;
                    mem_wreg <= ex_wreg;
                    mem_wdata <= ex_wdata;	
                    mem_aluop <= ex_aluop;
                    mem_mem_addr <= ex_mem_addr;
                    mem_reg2 <= ex_reg2;
                    mem_current_inst_addr <= ex_current_inst_addr;
                    mem_is_in_delayslot <= ex_is_in_delayslot;
                end 
        end
			

endmodule
