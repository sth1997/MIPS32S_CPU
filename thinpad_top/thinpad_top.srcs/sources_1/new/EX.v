`include "CONST.v"

module EX(

	input wire rst,
	
	input wire[`AluOpBus] aluop_input,
	input wire[`AluSelBus] alusel_input,
	input wire[`RegBus] reg1_input,
	input wire[`RegBus] reg2_input,
	input wire[`RegAddrBus] waddr_input,
	input wire wreg_input,
	input wire is_in_delayslot_input,
	input wire[`RegBus] link_addr_input,
	input wire[`RegBus] inst_input,
	
	//hilo_reg
	input wire[`RegBus] hi_input,
	input wire[`RegBus] lo_input,

	input wire mem_whilo_input,
	input wire[`RegBus] mem_hi_input,
	input wire[`RegBus] mem_lo_input,
	
	input wire wb_whilo_input,
	input wire[`RegBus] wb_hi_input,
	input wire[`RegBus] wb_lo_input,
	
	output reg whilo_output,
	output reg[`RegBus] hi_output,
	output reg[`RegBus] lo_output,
	
	input wire mem_cp0_reg_we,
	input wire[4: 0] mem_cp0_reg_write_addr,
	input wire[`RegBus] mem_cp0_reg_data,
	
	input wire wb_cp0_reg_we,
	input wire[4: 0] wb_cp0_reg_write_addr,
	input wire[`RegBus] wb_cp0_reg_data,
	
	input wire[`RegBus] cp0_reg_data_input,


	input wire[31: 0] excepttype_input,
	input wire[`RegBus] current_inst_addr_input,

	output reg[`RegAddrBus] waddr_output,
	output reg wreg_output,
	output reg[`RegBus] wdata_output,
	
	output reg[4: 0] cp0_reg_read_addr_output,	
	output reg cp0_reg_we_output,
	output reg[4: 0] cp0_reg_write_addr_output,
	output reg[`RegBus] cp0_reg_data_output,


	output wire[`AluOpBus] aluop_output,
	output wire[`RegBus] mem_addr_output,
	output wire[`RegBus] reg2_output,
	
	output wire[31: 0] excepttype_output,
	output wire[`RegBus] current_inst_addr_output,
	
	output wire is_in_delayslot_output
);

	reg[`RegBus] logicout;
	reg[`RegBus] shiftres;
	reg[`RegBus] moveres;
	reg[`RegBus] arithres;
	reg[`RegBus] HI;
	reg[`RegBus] LO;

	wire reg1_lt_reg2;
	wire[`RegBus] reg2_input_mux;
	wire[`RegBus] result_sum;
	
	wire[`RegBus] mult_op1;
	wire[`RegBus] mult_op2;
	wire[`DoubleRegBus] hilo_temp;
	reg[`DoubleRegBus] mulres;
	
	wire is_ADEL, is_ADES;
    assign is_ADES = (aluop_output == `EXE_SW_OP && mem_addr_output[1: 0] != 2'b00);
    assign is_ADEL = (aluop_output == `EXE_LHU_OP && mem_addr_output[0] != 1'b0) || (aluop_output == `EXE_LW_OP && mem_addr_output[1: 0] != 2'b00);

	assign current_inst_addr_output = current_inst_addr_input;
	assign is_in_delayslot_output = is_in_delayslot_input;
	assign excepttype_output = {excepttype_input[31: 12], is_ADES, is_ADEL, excepttype_input[9: 0]};
	
	always @ (*) 
		begin 
			if(rst == `RstEnable) 
				begin	
					{HI, LO} <= {`ZeroWord, `ZeroWord};
				end
			else if(mem_whilo_input == `WriteEnable) 
				begin
					{HI, LO} <= {mem_hi_input, mem_lo_input};
				end
			else if(wb_whilo_input == `WriteEnable) 
				begin
					{HI, LO} <= {wb_hi_input, wb_lo_input};
				end	
			else 
				begin
					{HI, LO} <= {hi_input, lo_input};
				end
		end
		
	always @ (*) 
		begin 
			if(rst == `RstEnable) 
				begin
					whilo_output <= `WriteDisable;
					hi_output <= `ZeroWord;
					lo_output <= `ZeroWord;
				end
			else 
				begin 
					case (aluop_input)
						`EXE_MTHI_OP: 
							begin 
								whilo_output <= `WriteEnable;
								hi_output <= reg1_input;
								lo_output <= LO;
							end
						`EXE_MTLO_OP: 
							begin 
								whilo_output <= `WriteEnable;
								hi_output <= HI;
								lo_output <= reg1_input;
							end
						`EXE_MULT_OP: 
							begin 
								whilo_output <= `WriteEnable;
								hi_output <= mulres[63: 32];
								lo_output <= mulres[31: 0];
							end
						default : 
							begin
								whilo_output <= `WriteDisable;
								hi_output <= `ZeroWord;
								lo_output <= `ZeroWord;
							end // default
					endcase
				end // else
		end
		
	assign mult_op1 = (reg1_input[31] == 1'b1)? (~reg1_input + 1): reg1_input;
    assign mult_op2 = (reg2_input[31] == 1'b1)? (~reg2_input + 1): reg2_input;
    assign hilo_temp = mult_op1 * mult_op2;
    always @ (*) 
    	begin 
			if(rst == `RstEnable) 
				begin
					mulres <= {`ZeroWord, `ZeroWord};
				end
			else if(aluop_input == `EXE_MULT_OP) 
				begin
					if(reg1_input[31] ^ reg2_input[31] == 1'b1) 
						begin
							mulres <= ~hilo_temp + 1;
						end
					else 
						begin
							mulres <= hilo_temp;
						end // else
				end	 // else if 
		end // always
	always @ (*) 
		begin
			if(rst == `RstEnable) 
				begin	
					moveres <= `ZeroWord;
				end
			else 
				begin 
					case (aluop_input)
						`EXE_MFHI_OP: 
							begin
								moveres <= HI;
							end
						`EXE_MFLO_OP: 
							begin
								moveres <= LO;
							end
						`EXE_MFC0_OP: 
							begin 
								cp0_reg_read_addr_output <= inst_input[15: 11];
								moveres <= cp0_reg_data_input;

								if(mem_cp0_reg_we == `WriteEnable && mem_cp0_reg_write_addr == inst_input[15: 11]) 
									begin 
										moveres <= mem_cp0_reg_data;
									end

								else if(wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_addr == inst_input[15: 11]) 
									begin 
										moveres <= wb_cp0_reg_data;
									end 
			 				end
						default : 
							begin
							end
					endcase
				end
		end

	always @ (*) 
		begin
			if(rst == `RstEnable) 
				begin
					cp0_reg_write_addr_output <= 5'b00000;
					cp0_reg_we_output <= `WriteDisable;
					cp0_reg_data_output <= `ZeroWord;
				end
			else if(aluop_input == `EXE_MTC0_OP) 
				begin
					cp0_reg_write_addr_output <= inst_input[15: 11];
					cp0_reg_we_output <= `WriteEnable;
					cp0_reg_data_output <= reg1_input;
				end 
			else if(aluop_input == `EXE_TLBR_OP) 
                begin
                    cp0_reg_write_addr_output <= `CP0_TLBR;
                    cp0_reg_we_output <= `WriteEnable;
                    cp0_reg_data_output <= `ZeroWord;
                end 
			else if(aluop_input == `EXE_TLBP_OP) 
                begin
                    cp0_reg_write_addr_output <= `CP0_TLBP;
                    cp0_reg_we_output <= `WriteEnable;
                    cp0_reg_data_output <= `ZeroWord;
                end 
			else
				begin
					cp0_reg_write_addr_output <= 5'b00000;
					cp0_reg_we_output <= `WriteDisable;
					cp0_reg_data_output <= `ZeroWord;
				end
		end
	always @ (*) 
        begin
            if(rst == `RstEnable) 
                begin
                    logicout <= `ZeroWord;
                end 
            else 
                begin
                    case (aluop_input)
                        `EXE_OR_OP: 
                            begin
                                logicout <= reg1_input | reg2_input;
                            end
                        `EXE_AND_OP: 
                            begin
                                logicout <= reg1_input & reg2_input;
                            end
                        `EXE_NOR_OP: 
                            begin
                                logicout <= ~(reg1_input | reg2_input);
                            end
                        `EXE_XOR_OP: 
                            begin
                                logicout <= reg1_input ^ reg2_input;
                            end
                        default: 
                            begin
                                logicout <= `ZeroWord;
                            end
                    endcase
                end
        end

	always @ (*) 
        begin
            if(rst == `RstEnable) 
                begin
                    shiftres <= `ZeroWord;
                end 
            else 
                begin
                    case (aluop_input)
                        `EXE_SLL_OP: 
                            begin
                                shiftres <= reg2_input << reg1_input[4: 0];
                            end
                        `EXE_SRL_OP: 
                            begin
                                shiftres <= reg2_input >> reg1_input[4: 0];
                            end
                        `EXE_SRA_OP: 
                            begin
                                shiftres <= ({32{reg2_input[31]}} << (6'd32 - {1'b0, reg1_input[4: 0]})) 
                                        | (reg2_input >> reg1_input[4: 0]);
                            end
                        default: 
                            begin
                                shiftres <= `ZeroWord;
                            end
                    endcase
                end 
        end 

	assign reg2_input_mux = ((aluop_input == `EXE_SUBU_OP) || (aluop_input == `EXE_SLT_OP))?
						(~reg2_input + 1): reg2_input;
    assign result_sum = reg1_input + reg2_input_mux;
    assign reg1_lt_reg2 = (aluop_input == `EXE_SLT_OP)? ((reg1_input[31] && !reg2_input[31]) 
    	|| (!reg1_input[31] && !reg2_input[31] && result_sum[31])
    	|| (reg1_input[31] && reg2_input[31] && result_sum[31]))
    	: (reg1_input < reg2_input);

    always @ (*) 
        begin 
            if(rst == `RstEnable) 
                begin
                    arithres <= `ZeroWord;
                end
            else 
                begin 
                    case (aluop_input)
                        `EXE_SLT_OP, `EXE_SLTU_OP: 
                            begin
                                arithres <= reg1_lt_reg2;
                            end
                        `EXE_ADDIU_OP, `EXE_ADDU_OP, `EXE_SUBU_OP: 
                            begin
                                arithres <= result_sum;
                            end    		
                        default: 
                            begin 
                                arithres <= `ZeroWord;
                            end
                    endcase
                end
        end

    assign aluop_output = aluop_input;
    assign mem_addr_output = reg1_input + {{16{inst_input[15]}}, inst_input[15: 0]};
    assign reg2_output = reg2_input;	

 	always @ (*) 
        begin
            waddr_output <= waddr_input;	 	 	
            wreg_output <= wreg_input;
            case (alusel_input) 
                `EXE_RES_LOGIC: 
                    begin
                        wdata_output <= logicout;
                    end
                `EXE_RES_SHIFT:	
                    begin
                        wdata_output <= shiftres;
                    end
                `EXE_RES_MOVE: 
                    begin
                        wdata_output <= moveres;
                    end
                `EXE_RES_ARITHMETIC: 
                    begin
                        wdata_output <= arithres;
                    end
                `EXE_RES_JUMP_BRANCH: 
                    begin 
                        wdata_output <= link_addr_input;
                    end
                default: 
                    begin
                        wdata_output <= `ZeroWord;
                    end
            endcase
        end	

endmodule
