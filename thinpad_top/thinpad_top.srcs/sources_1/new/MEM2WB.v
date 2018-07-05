`include "CONST.v"

module MEM2WB(

	input wire clk,
	input wire rst,

	input wire[5: 0] stall,

	// from mem	
	input wire[`RegAddrBus] mem_waddr,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
	// exception
	input wire flush_flag,

	// to wb
	output reg[`RegAddrBus] wb_waddr,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata
);


	always @ (posedge clk) 
        begin
            if ((rst == `RstEnable)||(flush_flag == 1'b1)) 
                begin
                    wb_waddr <= `NOPRegAddr;
                    wb_wreg <= `WriteDisable;
                    wb_wdata <= `ZeroWord;	
                end 
            else if(stall[4] == `Stop && stall[5] == `NoStop) 
                begin
                    wb_waddr <= `NOPRegAddr;
                    wb_wreg <= `WriteDisable;
                    wb_wdata <= `ZeroWord; 	  
                end 
            else if(stall[4] == `NoStop) 
                begin
                    wb_waddr <= mem_waddr;
                    wb_wreg <= mem_wreg;
                    wb_wdata <= mem_wdata;
                end //if
        end
			

endmodule