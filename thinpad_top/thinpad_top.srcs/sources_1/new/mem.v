`include "CONST.v"

module mem(

	input wire					rst,
	
	//	
	input wire[`RegAddrBus]     waddr_input,
	input wire                  wreg_input,
	input wire[`RegBus]			wdata_input,
	input wire[`AluOpBus] 		aluop_input,
	input wire[`RegBus] 		mem_addr_input,
	input wire[`RegBus]			reg2_input,

	// from RAM
	input wire[`RegBus] 		mem_data_input,

	// to RAM
	output reg[`RegBus] 		mem_addr_output,
	output wire 				mem_we_output,	// write RAM or not
	output reg[3: 0]			mem_sel_output,
	output reg[`RegBus]			mem_data_output,
	output reg 					mem_ce_output,

	output reg[`RegAddrBus]		waddr_output,
	output reg                  wreg_output,
	output reg[`RegBus]			wdata_output
);

	reg mem_we;

	assign mem_we_output = mem_we;
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			waddr_output <= `NOPRegAddr;
			wreg_output <= `WriteDisable;
		  	wdata_output <= `ZeroWord;
		
			mem_addr_output <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_output <= 4'b0000;
			mem_data_output <= `ZeroWord;
			mem_ce_output <= `ChipDisable;
		end 
		else begin
		  	waddr_output <= waddr_input;
			wreg_output <= wreg_input;
			wdata_output <= wdata_input;
			
			mem_addr_output <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_output <= 4'b1111;
			mem_ce_output <= `ChipDisable;

			case (aluop_input)
				`EXE_LB_OP: begin 
					mem_addr_output <= mem_addr_input;
					mem_we <= `WriteDisable;
					mem_ce_output <= `ChipEnable;
					case (mem_addr_input[1: 0])
						2'b00: begin 
							wdata_output <= {{24{mem_data_input[7]}}, mem_data_input[7: 0]};
							mem_sel_output <= 4'b0001;
						end
						2'b01: begin
							wdata_output <= {{24{mem_data_input[15]}}, mem_data_input[15: 8]};
							mem_sel_output <= 4'b0010;
						end
						2'b10: begin
							wdata_output <= {{24{mem_data_input[23]}}, mem_data_input[23: 16]};
							mem_sel_output <= 4'b0100;
						end
						2'b11: begin
							wdata_output <= {{24{mem_data_input[31]}}, mem_data_input[31: 24]};
							mem_sel_output <= 4'b1000;
						end		
						default: begin
                            wdata_output <= `ZeroWord;
						end
					endcase
				end // exe_lb_op
				`EXE_LBU_OP: begin 
					mem_addr_output <= mem_addr_input;
					mem_we <= `WriteDisable;
					mem_ce_output <= `ChipEnable;
					case (mem_addr_input[1: 0])
						2'b00: begin 
							wdata_output <= {{24{1'b0}}, mem_data_input[7: 0]};
							mem_sel_output <= 4'b0001;
						end
						2'b01: begin
							wdata_output <= {{24{1'b0}}, mem_data_input[15: 8]};
							mem_sel_output <= 4'b0010; 
						end
						2'b10: begin
							wdata_output <= {{24{1'b0}}, mem_data_input[23: 16]};
							mem_sel_output <= 4'b0100;
						end
						2'b11: begin
							wdata_output <= {{24{1'b0}}, mem_data_input[31: 24]};
							mem_sel_output <= 4'b1000;
						end
						default: begin
                            wdata_output <= `ZeroWord;
						end
					endcase
				end // exe_lbu_op
				`EXE_LHU_OP: begin 
					mem_addr_output <= mem_addr_input;
					mem_we <= `WriteDisable;
					mem_ce_output <= `ChipEnable;
					case (mem_addr_input[1: 0])
						2'b00: begin 
							wdata_output <= {{16{1'b0}}, mem_data_input[15: 0]};
							mem_sel_output <= 4'b0011;
						end
						2'b10: begin
							wdata_output <= {{16{1'b0}}, mem_data_input[31: 15]};
							mem_sel_output <= 4'b1100;
						end
						default: begin
                            wdata_output <= `ZeroWord;
						end
					endcase
				end // exe_lhu_op
				`EXE_LW_OP: begin 
					mem_addr_output <= mem_addr_input;
					mem_we <= `WriteDisable;
					mem_ce_output <= `ChipEnable;
					wdata_output <= mem_data_input;
					mem_sel_output <= 4'b1111;
				end 
				`EXE_SB_OP: begin 
					mem_addr_output <= mem_addr_input;
					mem_we <= `WriteEnable;
					mem_ce_output <= `ChipEnable;
					mem_data_output <= {4{reg2_input[7: 0]}};
					case (mem_addr_input[1: 0])
						2'b00: begin 
							mem_sel_output <= 4'b0001;
						end
						2'b01: begin
							mem_sel_output <= 4'b0010;						
						end
						2'b10: begin
							mem_sel_output <= 4'b0100;						
						end
						2'b11: begin
							mem_sel_output <= 4'b1000;
						end
						default: begin
							mem_sel_output <= 4'b0000;
						end
					endcase
				end
				`EXE_SW_OP: begin 
					mem_addr_output <= mem_addr_input;
					mem_we <= `WriteEnable;
					mem_ce_output <= `ChipEnable;
					mem_data_output <= reg2_input;
					mem_sel_output <= 4'b1111;
				end 
				default : begin 
				end
			endcase // aluop_input
		end //if
	end //always

	endmodule