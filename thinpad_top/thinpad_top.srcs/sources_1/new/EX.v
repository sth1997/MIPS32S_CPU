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


	input wire[`RegBus] current_inst_addr_input,

	output reg[`RegAddrBus] waddr_output,
	output reg wreg_output,
	output reg[`RegBus] wdata_output,

	output wire[`AluOpBus] aluop_output,
	output wire[`RegBus] mem_addr_output,
	output wire[`RegBus] reg2_output,
	
	output wire[`RegBus] current_inputnst_addr_output,
	
	output wire is_inputn_delayslot_output
);

	reg[`RegBus] logicout;
	reg[`RegBus] shiftres;
	reg[`RegBus] moveres;
	reg[`RegBus] arithres;

	wire reg1_lt_reg2;
	wire[`RegBus] reg2_input_mux;
	wire[`RegBus] result_sum;

	assign current_inputnst_addr_output = current_inst_addr_input;
	assign is_inputn_delayslot_output = is_in_delayslot_input;


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