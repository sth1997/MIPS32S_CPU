`include "CONST.v"

module MEM2WB(

	input wire clk,
	input wire rst,

	input wire[5: 0] bubble_flag,

	// from mem	
	input wire[`RegAddrBus] mem_waddr,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,
	
	input wire mem_cp0_reg_we,
	input wire[4:0] mem_cp0_reg_write_addr,
	input wire[`RegBus] mem_cp0_reg_data,
	// exception
	input wire flush_flag,

	// to wb
	output reg[`RegAddrBus] wb_waddr,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata,
	output reg wb_cp0_reg_we,
	output reg[4:0] wb_cp0_reg_write_addr,
	output reg[`RegBus] wb_cp0_reg_data
);


	always @ (posedge clk) 
        begin
            if ((rst == `RstEnable)||(flush_flag == 1'b1)) 
                begin
                    wb_waddr <= `NOPRegAddr;
                    wb_wreg <= `WriteDisable;
                    wb_wdata <= `ZeroWord;	
                    wb_cp0_reg_we <= `WriteDisable;
					wb_cp0_reg_write_addr <= 5'b00000;
					wb_cp0_reg_data <= `ZeroWord;
                end 
            else if(bubble_flag[4] == `Stop && bubble_flag[5] == `NoStop) 
                begin
                    wb_waddr <= `NOPRegAddr;
                    wb_wreg <= `WriteDisable;
                    wb_wdata <= `ZeroWord; 	  
                    wb_cp0_reg_we <= `WriteDisable;
					wb_cp0_reg_write_addr <= 5'b00000;
					wb_cp0_reg_data <= `ZeroWord;
                end 
            else if(bubble_flag[4] == `NoStop) 
                begin
                    wb_waddr <= mem_waddr;
                    wb_wreg <= mem_wreg;
                    wb_wdata <= mem_wdata;
                    wb_cp0_reg_we <= mem_cp0_reg_we;
					wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
					wb_cp0_reg_data <= mem_cp0_reg_data;
                end //if
        end
			

endmodule
