`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/05 16:07:11
// Design Name: 
// Module Name: Reg_Dir
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
module Reg_Dir(
    input wire clk,
	input wire rst,
	
	input wire write_enable,
	input wire[`RegAddrBus]	  waddr,
	input wire[`RegBus]		  wdata,
	
	input wire read_enable_1,
	input wire[`RegAddrBus] raddr1,
	output reg[`RegBus] rdata1,
	
	input wire read_enable_2,
	input wire[`RegAddrBus] raddr2,
	output reg[`RegBus] rdata2,
	input wire[5:0] sw,
	output wire[15:0] reg_out
	
    );
    reg[`RegBus]  regs[0: `RegNum - 1];
    
	assign reg_out = sw[5]?regs[sw[4:0]][31:16]:regs[sw[4:0]][15:0];
	
    always @ (posedge clk) 
        begin
            if (rst == `RstDisable) 
                begin
                    if((write_enable == `WriteEnable) && (waddr != `RegNumLog2'h0)) 
                        begin
                            regs[waddr] <= wdata;
                        end
                end
        end
    
    always @ (*) 
        begin
            if(rst == `RstEnable) 
                begin
                    rdata1 <= `ZeroWord;
                end 
            else if(raddr1 == `RegNumLog2'h0) 
                begin
                    rdata1 <= `ZeroWord;
                end 
            else if((raddr1 == waddr) && (write_enable == `WriteEnable)&& (read_enable_1 == `ReadEnable)) 
                begin
                    rdata1 <= wdata;
                end 
            else if(read_enable_1 == `ReadEnable) 
                begin
                    rdata1 <= regs[raddr1];
                end 
            else 
                begin
                    rdata1 <= `ZeroWord;
                end
        end

    always @ (*) 
        begin
            if(rst == `RstEnable) 
                begin
                    rdata2 <= `ZeroWord;
                end 
            else if(raddr2 == `RegNumLog2'h0) 
                begin
                    rdata2 <= `ZeroWord;
                end 
            else if((raddr2 == waddr) && (write_enable == `WriteEnable) && (read_enable_2 == `ReadEnable)) 
                begin
                    rdata2 <= wdata;
                end 
            else if(read_enable_2 == `ReadEnable) 
                begin
                    rdata2 <= regs[raddr2];
                end 
            else 
                begin
                    rdata2 <= `ZeroWord;
                end
        end
endmodule
