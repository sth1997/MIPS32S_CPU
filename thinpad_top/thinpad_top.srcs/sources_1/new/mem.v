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
    
    //cp0
	input wire                  cp0_reg_we_i,
	input wire[4:0]             cp0_reg_write_addr_i,
	input wire[`RegBus]         cp0_reg_data_i,
    input wire[31: 0]           excepttype_i,
	input wire[`RegBus]         current_inst_addr_i,
	input wire                  is_in_delayslot_i,
	input wire[`RegBus]         cp0_status_i,
	input wire[`RegBus]         cp0_cause_i,
	input wire[`RegBus]         cp0_epc_i,
    //bypass
	input wire                  wb_cp0_reg_we,
	input wire[4: 0]            wb_cp0_reg_write_addr,
	input wire[`RegBus]         wb_cp0_reg_data,

	// to RAM
	output reg[`RegBus] 		mem_addr_output,
	output wire 				mem_we_output,	// write RAM or not
	output reg[3: 0]			mem_sel_output,
	output reg[`RegBus]			mem_data_output,
	output reg 					mem_ce_output,

	output reg[`RegAddrBus]		waddr_output,
	output reg                  wreg_output,
	output reg[`RegBus]			wdata_output,
    
    //cp0
	output reg                  cp0_reg_we_o,
	output reg[4:0]             cp0_reg_write_addr_o,
	output reg[`RegBus]         cp0_reg_data_o,
	output reg[31: 0]           excepttype_o,
	output wire[`RegBus]        current_inst_addr_o,
	output wire[`RegBus]        cp0_epc_o,
	output wire                 is_in_delayslot_o
);

	reg mem_we;
    reg[`RegBus] cp0_status;
	reg[`RegBus] cp0_cause;
	reg[`RegBus] cp0_epc;
    
	assign mem_we_output = mem_we & (~(|excepttype_o));
    assign is_in_delayslot_o = is_in_delayslot_i;
	assign current_inst_addr_o = current_inst_addr_i;
    assign cp0_epc_o = cp0_epc;	
	
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
            
            cp0_reg_we_o <= `WriteDisable;
		  	cp0_reg_write_addr_o <= 5'b00000;
		  	cp0_reg_data_o <= `ZeroWord;	
		end 
		else begin
		  	waddr_output <= waddr_input;
			wreg_output <= wreg_input;
			wdata_output <= wdata_input;	
			
			mem_addr_output <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_output <= 4'b1111;
			mem_ce_output <= `ChipDisable;
            
            cp0_reg_we_o <= cp0_reg_we_i;
		  	cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
		  	cp0_reg_data_o <= cp0_reg_data_i;

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
    
    always @ (*) begin
		if(rst == `RstEnable) begin
			excepttype_o <= `ZeroWord;
		end else begin
			excepttype_o <= `ZeroWord;	
			if(current_inst_addr_i != `ZeroWord) begin
				if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) &&
				 	(cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin
					excepttype_o <= 32'h00000001;        //interrupt
				end 
				else if(excepttype_i[8] == 1'b1) begin
			  		excepttype_o <= 32'h00000008;        //syscall
				end
				else if(excepttype_i[9] == 1'b1) begin
					excepttype_o <= 32'h0000000a;        //inst_invalid
				end
				else if(excepttype_i[10] == 1'b1) begin 
					excepttype_o <= 32'h0000000b;        // ADEL
				end
				else if(excepttype_i[11] == 1'b1) begin 
					excepttype_o <= 32'h0000000c;        // ADES
				end 
				else if(excepttype_i[12] == 1'b1) begin  
					excepttype_o <= 32'h0000000e;        //eret
				end
			end	
		end
	end
    
    always @ (*) begin
		if(rst == `RstEnable) begin
			cp0_status <= `ZeroWord;
		end 
		else if((wb_cp0_reg_we == `WriteEnable) && 
				(wb_cp0_reg_write_addr == `CP0_REG_STATUS ))begin
			cp0_status <= wb_cp0_reg_data;
		end 
		else begin
		  	cp0_status <= cp0_status_i;
		end
	end

	always @ (*) begin
		if(rst == `RstEnable) begin
			cp0_epc <= `ZeroWord;
		end 
		else if((wb_cp0_reg_we == `WriteEnable) && 
				(wb_cp0_reg_write_addr == `CP0_REG_EPC ))begin
			cp0_epc <= wb_cp0_reg_data;
		end 
		else begin
		  	cp0_epc <= cp0_epc_i;
		end
	end

  	always @ (*) begin
		if(rst == `RstEnable) begin
			cp0_cause <= `ZeroWord;
		end 
		else if((wb_cp0_reg_we == `WriteEnable) && 
				(wb_cp0_reg_write_addr == `CP0_REG_CAUSE ))begin
			cp0_cause[9: 8] <= wb_cp0_reg_data[9: 8];
			cp0_cause[22] <= wb_cp0_reg_data[22];
			cp0_cause[23] <= wb_cp0_reg_data[23];
		end 
		else begin
		  	cp0_cause <= cp0_cause_i;
		end
	end

	endmodule