`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 16:25:40
// Design Name: 
// Module Name: ID
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

module ID(
    input wire rst,
    
    input wire[`InstAddrBus] pc_input,				// 32bit, address
    input wire[`InstBus] inst_input,

    input wire[`RegBus] reg1_data_input,
    input wire[`RegBus] reg2_data_input,

    input wire ex_wreg_input,
    input wire[`RegAddrBus] ex_waddr_input,
    input wire[`RegBus] ex_wdata_input,
    
    input wire mem_wreg_input,
    input wire[`RegAddrBus] mem_waddr_input,
    input wire[`RegBus] mem_wdata_input,

    input wire is_in_delayslot_input,

    input wire[`AluOpBus] ex_aluop_input,

    output reg reg1_read_output,         
    output reg reg2_read_output,     
    output reg[`RegAddrBus] reg1_addr_output,        
    output reg[`RegAddrBus] reg2_addr_output,           
    
    output reg[`AluOpBus] aluop_output,            
    output reg[`AluSelBus] alusel_output,        
    output reg[`RegBus] reg1_output,            
    output reg[`RegBus] reg2_output,
    output reg[`RegAddrBus] waddr_output,               
    output reg wreg_output,           

    output reg next_inst_in_delayslot_output,

    output reg branch_flag_output,
    output reg[`RegBus] branch_target_addr_output,
    output reg[`RegBus] link_addr_output,
    output reg is_in_delayslot_output,

    output wire[`RegBus] inst_output,
    output wire bubble_require,


    input wire is_tlbl_inst,
    output wire[31: 0] excepttype_output,
    output wire[`RegBus] current_inst_addr_output
    );
    reg bubble_require_wait_for_reg1_load;
    reg bubble_require_wait_for_reg2_load;
    wire pre_inst_is_load;
    reg[`RegBus] imm;
    wire[`RegBus] branch_addr;
    wire[`RegBus] pc_plus_4;
    wire[`RegBus] pc_plus_8;
    reg excepttype_is_syscall;
	reg excepttype_is_eret;
	reg instvalid;
    
    assign current_inst_addr_output = pc_input;
    
    assign pre_inst_is_load = ((ex_aluop_input == `EXE_LB_OP) || (ex_aluop_input == `EXE_LBU_OP) ||(ex_aluop_input == `EXE_LHU_OP) || (ex_aluop_input == `EXE_LW_OP))? 1'b1: 1'b0;
    assign bubble_require = bubble_require_wait_for_reg1_load | bubble_require_wait_for_reg2_load;
    
    wire exc_is_tlbl_inst;
	assign exc_is_tlbl_inst = is_tlbl_inst && (pc_input != `ZeroWord);
    
    assign excepttype_output = {18'b0, exc_is_tlbl_inst, excepttype_is_eret, 2'b00, instvalid, excepttype_is_syscall, 8'b0};
    
    assign inst_output = inst_input;
    assign branch_addr = (pc_input + 4) + {{14{inst_input[15]}}, inst_input[15: 0], 2'b00};
    assign pc_plus_4 = pc_input + 4;
    assign pc_plus_8 = pc_input + 8;
    
    always @ (*) 
        begin
            if(rst == `RstEnable) 
                begin
                    reg1_output <= `ZeroWord;
                    bubble_require_wait_for_reg1_load <= `NoStop;
                end 
            else if(pre_inst_is_load == 1'b1 && ex_waddr_input == reg1_addr_output && reg1_read_output == 1'b1 ) 
                begin
                    bubble_require_wait_for_reg1_load <= `Stop;
                end
            else 
                begin
                    bubble_require_wait_for_reg1_load <= `NoStop;
                    if (reg1_read_output == 1'b1)
                        begin
                            if((ex_wreg_input == 1'b1) && (ex_waddr_input == reg1_addr_output)) 
                                begin
                                    reg1_output <= ex_wdata_input;
                                end
                            else if((mem_wreg_input == 1'b1) && (mem_waddr_input == reg1_addr_output)) 
                                begin
                                    reg1_output <= mem_wdata_input;
                                end
                            else
                                begin
                                    reg1_output <= reg1_data_input;
                                end 
                        end
                    else if(reg1_read_output == 1'b0) 
                        begin
                          reg1_output <= imm;
                        end 
                    else 
                        begin
                            reg1_output <= `ZeroWord;
                        end
                end
        end
    
    always @ (*) begin
        if(rst == `RstEnable) 
            begin
                reg2_output <= `ZeroWord;
                bubble_require_wait_for_reg2_load <= `NoStop;
            end 
        else if(pre_inst_is_load == 1'b1 && ex_waddr_input == reg2_addr_output && reg2_read_output == 1'b1 ) 
            begin
                bubble_require_wait_for_reg2_load <= `Stop;
            end
        else 
            begin
                bubble_require_wait_for_reg2_load <= `NoStop;
                if(reg2_read_output == 1'b1)
                    begin
                        if((ex_wreg_input == 1'b1) && (ex_waddr_input == reg2_addr_output)) 
                            begin
                                reg2_output <= ex_wdata_input;
                            end
                        else if((mem_wreg_input == 1'b1) && (mem_waddr_input == reg2_addr_output)) 
                            begin
                                reg2_output <= mem_wdata_input;
                            end
                        else 
                            begin
                              reg2_output <= reg2_data_input;
                            end
                    end
                else if(reg2_read_output == 1'b0) 
                    begin
                      reg2_output <= imm;
                    end 
                else 
                    begin
                        reg2_output <= `ZeroWord;
                    end
            end
    end

    always @ (*) begin
        if(rst == `RstEnable) 
            begin
                is_in_delayslot_output <= `NotInDelaySlot;
            end 
        else 
            begin
                is_in_delayslot_output <= is_in_delayslot_input;       
            end
    end
    
    always @ (*) 
        begin	
            if (rst == `RstEnable) 
                begin
                    aluop_output <= `EXE_NOP_OP;
                    alusel_output <= `EXE_RES_NOP;
                    waddr_output <= `NOPRegAddr;
                    wreg_output <= `WriteDisable;
                    reg1_read_output <= 1'b0;
                    reg2_read_output <= 1'b0;
                    reg1_addr_output <= `NOPRegAddr;
                    reg2_addr_output <= `NOPRegAddr;
                    imm <= `ZeroWord; 
                    link_addr_output <= `ZeroWord;
                    branch_target_addr_output <= `ZeroWord;
                    branch_flag_output <= `NotBranch;
                    next_inst_in_delayslot_output <= `NotInDelaySlot;
                end 
            else 
                begin
                    aluop_output <= `EXE_NOP_OP;
                    alusel_output <= `EXE_RES_NOP;
                    waddr_output <= inst_input[15:11];
                    wreg_output <= `WriteDisable;  
                    reg1_read_output <= 1'b0;
                    reg2_read_output <= 1'b0;
                    reg1_addr_output <= inst_input[25:21];
                    reg2_addr_output <= inst_input[20:16];
                    imm <= `ZeroWord;
                    link_addr_output <= `ZeroWord;
                    branch_target_addr_output <= `ZeroWord;
                    branch_flag_output <= `NotBranch;
                    next_inst_in_delayslot_output <= `NotInDelaySlot;
					excepttype_is_eret <= 1'b0;
					excepttype_is_syscall <= 1'b0;
					instvalid <= `InstInvalid;
                    case (inst_input[31:26])
                        `EXE_SPECIAL_INST:
                            begin
                                if(inst_input[31: 21] == 11'b00000000000) 
                                    begin
                                        if(inst_input[5:0] == `EXE_SLL) 
                                            begin
                                                wreg_output <= `WriteEnable;
                                                aluop_output <= `EXE_SLL_OP;
                                                alusel_output <= `EXE_RES_SHIFT;
                                                reg1_read_output <= 1'b0;
                                                reg2_read_output <= 1'b1;
                                                imm[4: 0] <= inst_input[10: 6];
                                                waddr_output <= inst_input[15: 11];
				  								instvalid <= `InstValid;
                                            end
                                        if(inst_input[5:0] == `EXE_SRL) 
                                            begin
                                                wreg_output <= `WriteEnable;
                                                aluop_output <= `EXE_SRL_OP;
                                                alusel_output <= `EXE_RES_SHIFT;
                                                reg1_read_output <= 1'b0;
                                                reg2_read_output <= 1'b1;
                                                imm[4: 0] <= inst_input[10: 6];
                                                waddr_output <= inst_input[15: 11];
				  								instvalid <= `InstValid;
                                            end
                                    end
                                case (inst_input[10:6])
                                    5'b00000:
                                        begin
                                            case (inst_input[5:0])
                                                `EXE_ADDU: 
                                                    begin
                                                        wreg_output <= `WriteEnable;
                                                        aluop_output <= `EXE_ADDU_OP;
                                                        alusel_output <= `EXE_RES_ARITHMETIC;
                                                        reg1_read_output <= 1'b1;
                                                        reg2_read_output <= 1'b1;
				  										instvalid <= `InstValid;
                                                    end
                                                `EXE_AND:
                                                    begin
                                                        wreg_output <= `WriteEnable;
                                                        aluop_output <= `EXE_AND_OP;
                                                        alusel_output <= `EXE_RES_LOGIC;
                                                        reg1_read_output <= 1'b1;
                                                        reg2_read_output <= 1'b1;
				  										instvalid <= `InstValid;
                                                    end
                                                `EXE_JR: 
                                                    begin
                                                        wreg_output <= `WriteDisable;
                                                        aluop_output <= `EXE_JR_OP;
                                                        alusel_output <= `EXE_RES_JUMP_BRANCH;
                                                        reg1_read_output <= 1'b1;
                                                        reg2_read_output <= 1'b0;
				  										instvalid <= `InstValid;
                                                        
                                                        link_addr_output <= `ZeroWord;
                                                        branch_target_addr_output <= reg1_output;
                                                        branch_flag_output <= `Branch;
                                                        next_inst_in_delayslot_output <= `InDelaySlot; 
                                                    end
                                                `EXE_OR:
                                                    begin
                                                        wreg_output <= `WriteEnable;
                                                        aluop_output <= `EXE_OR_OP;
                                                        alusel_output <= `EXE_RES_LOGIC;
				  										instvalid <= `InstValid;
                                                        reg1_read_output <= 1'b1;
                                                        reg2_read_output <= 1'b1;
                                                    end
                                                `EXE_XOR:
                                                    begin
                                                        wreg_output <= `WriteEnable;
                                                        aluop_output <= `EXE_XOR_OP;
                                                        alusel_output <= `EXE_RES_LOGIC;
				  										instvalid <= `InstValid;
                                                        reg1_read_output <= 1'b1;
                                                        reg2_read_output <= 1'b1;
                                                    end
                                                `EXE_SYSCALL: 
                                                	begin 
							  							wreg_output <= `WriteDisable;
							  							aluop_output <= `EXE_SYSCALL_OP;
							  							alusel_output <= `EXE_RES_NOP;
							  							reg1_read_output <= 1'b0;
							  							reg2_read_output <= 1'b0;
							  							instvalid <= `InstValid;
							  							excepttype_is_syscall <= 1'b1;
													end
                                                default:
                                                    begin
                                                    
                                                    end
                                            endcase //case (inst_input[5:0])
                                        end
                                endcase //case (inst_input[10:6])
                            end
                        `EXE_ADDIU:
                            begin                
                                wreg_output <= `WriteEnable;        
                                aluop_output <= `EXE_ADDIU_OP;                
                                alusel_output <= `EXE_RES_ARITHMETIC; 
                                reg1_read_output <= 1'b1;  
				  				instvalid <= `InstValid;              
                                reg2_read_output <= 1'b0;          
                                imm <= {{16{inst_input[15]}}, inst_input[15:0]};        
                                waddr_output <= inst_input[20:16];   
                            end
                        `EXE_ANDI: 			
                            begin                //ANDI
                                wreg_output <= `WriteEnable;        
                                aluop_output <= `EXE_AND_OP;
                                alusel_output <= `EXE_RES_LOGIC; 
                                reg1_read_output <= 1'b1;    
                                reg2_read_output <= 1'b0;           
				  				instvalid <= `InstValid;  
                                imm <= {16'h0, inst_input[15:0]};
                                waddr_output <= inst_input[20:16];
                            end
                        `EXE_BEQ: 
                            begin
                                wreg_output <= `WriteDisable;
                                aluop_output <= `EXE_BEQ_OP;
                                alusel_output <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_output <= 1'b1; 
				  				instvalid <= `InstValid;  
                                reg2_read_output <= 1'b1;
                                if(reg1_output == reg2_output) 
                                    begin
                                        link_addr_output <= `ZeroWord;
                                        branch_target_addr_output <= branch_addr;
                                        branch_flag_output <= `Branch;
                                        next_inst_in_delayslot_output <= `InDelaySlot;
                                    end
                            end
                        `EXE_BGTZ: 
                            begin
                                wreg_output <= `WriteDisable;
                                aluop_output <= `EXE_BGTZ_OP;
                                alusel_output <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_output <= 1'b1;
                                reg2_read_output <= 1'b0;
                                if((reg1_output[31] == 1'b0) && (reg1_output != `ZeroWord)) 
                                    begin
                                        link_addr_output <= `ZeroWord;
                                        branch_target_addr_output <= branch_addr;
                                        branch_flag_output <= `Branch;
                                        next_inst_in_delayslot_output <= `InDelaySlot;
                                    end 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_BNE: 
                            begin
                                wreg_output <= `WriteDisable;
                                aluop_output <= `EXE_BNE_OP;
                                alusel_output <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_output <= 1'b1;
                                reg2_read_output <= 1'b1;
                                if(reg1_output != reg2_output)
                                    begin
                                        link_addr_output <= `ZeroWord;
                                        branch_target_addr_output <= branch_addr;
                                        branch_flag_output <= `Branch;
                                        next_inst_in_delayslot_output <= `InDelaySlot;
                                    end 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_J: 
                            begin
                                wreg_output <= `WriteDisable;
                                aluop_output <= `EXE_J_OP;
                                alusel_output <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_output <= 1'b0;
                                reg2_read_output <= 1'b0;
                                
                                link_addr_output <= `ZeroWord;
                                branch_target_addr_output <= {pc_plus_4[31: 28], inst_input[25: 0], 2'b00};
                                branch_flag_output <= `Branch;
                                next_inst_in_delayslot_output <= `InDelaySlot; 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_JAL: 
                            begin
                                wreg_output <= `WriteEnable;
                                aluop_output <= `EXE_JAL_OP;
                                alusel_output <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_output <= 1'b0;
                                reg2_read_output <= 1'b0;
                                waddr_output <= 5'b11111;
                                
                                link_addr_output <= pc_plus_8;
                                branch_target_addr_output <= {pc_plus_4[31: 28], inst_input[25: 0], 2'b00};
                                branch_flag_output <= `Branch;
                                next_inst_in_delayslot_output <= `InDelaySlot;   
				  				instvalid <= `InstValid;  
                            end
                        `EXE_LB: 
                            begin
                                wreg_output <= `WriteEnable;
                                aluop_output <= `EXE_LB_OP;
                                alusel_output <= `EXE_RES_LOAD_STORE;
                                reg1_read_output <= 1'b1;
                                reg2_read_output <= 1'b0;
                                waddr_output <= inst_input[20: 16]; 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_LUI: 			
                            begin 
                                wreg_output <= `WriteEnable;        
                                aluop_output <= `EXE_OR_OP;   
                                alusel_output <= `EXE_RES_LOGIC; 
                                reg1_read_output <= 1'b1;
                                reg2_read_output <= 1'b0;          
                                imm <= {inst_input[15:0], 16'h0};        
                                waddr_output <= inst_input[20:16]; 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_LW:
                            begin
                                wreg_output <= `WriteEnable;
                                aluop_output <= `EXE_LW_OP;
                                alusel_output <= `EXE_RES_LOAD_STORE;
                                reg1_read_output <= 1'b1;
                                reg2_read_output <= 1'b0;
                                waddr_output <= inst_input[20: 16]; 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_ORI: 			
                            begin        
                                wreg_output <= `WriteEnable;        
                                aluop_output <= `EXE_OR_OP;
                                alusel_output <= `EXE_RES_LOGIC; 
                                reg1_read_output <= 1'b1;    
                                reg2_read_output <= 1'b0;          
                                imm <= {16'h0, inst_input[15:0]};   
                                waddr_output <= inst_input[20:16]; 
				  				instvalid <= `InstValid;  
                            end
                        `EXE_SB: 
                            begin
                                wreg_output <= `WriteDisable;
                                aluop_output <= `EXE_SB_OP;
                                alusel_output <= `EXE_RES_LOAD_STORE;
                                reg1_read_output <= 1'b1; 
				  				instvalid <= `InstValid;  
                                reg2_read_output <= 1'b1;
                            end
                        `EXE_SW: 
                            begin
                                wreg_output <= `WriteDisable;
                                aluop_output <= `EXE_SW_OP;
                                alusel_output <= `EXE_RES_LOAD_STORE;
                                reg1_read_output <= 1'b1; 
				  				instvalid <= `InstValid;  
                                reg2_read_output <= 1'b1;
                            end
                        `EXE_XORI: 			
                            begin
                                wreg_output <= `WriteEnable;        
                                aluop_output <= `EXE_XOR_OP;
                                alusel_output <= `EXE_RES_LOGIC; 
                                reg1_read_output <= 1'b1;   
				  				instvalid <= `InstValid;    
                                reg2_read_output <= 1'b0;          
                                imm <= {16'h0, inst_input[15:0]};    
                                waddr_output <= inst_input[20:16];  
                            end
                            
                            
                            
                        default:
                            begin
                            
                            end
                    endcase //case (inst_input[31:26])
                    
                    
                	if(inst_input[31: 21] == 11'b01000000000 && inst_input[10: 0] == 11'b00000000000) 
		            	begin 
					  		aluop_output <= `EXE_MFC0_OP;
					  		alusel_output <= `EXE_RES_MOVE;
					  		waddr_output <= inst_input[20: 16];
					  		wreg_output <= `WriteEnable;
					  		instvalid <= `InstValid;
					  		reg1_read_output <= 1'b0;
					  		reg2_read_output <= 1'b0;	
					  	end
				  	
				  	
				  	if(inst_input[31: 21] == 11'b01000000100 && (inst_input[10: 0] == 11'b00000000000 || inst_input[10: 0] == 11'b00000000001 
				  		|| inst_input[10: 0] == 11'b00000000010  || inst_input[10: 0] == 11'b00000000011 )) 
					  	begin 
					  		aluop_output <= `EXE_MTC0_OP;
					  		alusel_output <= `EXE_RES_NOP;
					  		wreg_output <= `WriteDisable;
					  		instvalid <= `InstValid;
					  		reg1_read_output <= 1'b1;
					  		reg1_addr_output <= inst_input[20: 16];
					  		reg2_read_output <= 1'b0;	
					  	end	

				  	//eret
				  	if(inst_input == `EXE_ERET) 
					  	begin 
					  		wreg_output <= `WriteDisable;
					  		aluop_output <= `EXE_ERET_OP;
					  		alusel_output <= `EXE_RES_NOP;
					  		reg1_read_output <= 1'b0;
					  		reg2_read_output <= 1'b0;
					  		instvalid <= `InstValid;
					  		excepttype_is_eret <= 1'b1;
					  	end
				  	
				  	if(inst_input == `EXE_TLBWI) 
				  		begin
					  		wreg_output <= `WriteDisable; // don't write reg_files
					  		aluop_output <= `EXE_TLBWI_OP;
					  		alusel_output <= `EXE_RES_NOP;
					  		reg1_read_output <= 1'b0;
					  		reg2_read_output <= 1'b0;
					  		instvalid <= `InstValid;
						end
                    if(inst_input == `EXE_TLBWR) 
                        begin
                            wreg_output <= `WriteDisable; // don't write reg_files
                            aluop_output <= `EXE_TLBWR_OP;
                            alusel_output <= `EXE_RES_NOP;
                            reg1_read_output <= 1'b0;
                            reg2_read_output <= 1'b0;
                            instvalid <= `InstValid;
                        end
                    if(inst_input == `EXE_TLBR)
                        begin
                            aluop_output <= `EXE_TLBR_OP;
                            alusel_output <= `EXE_RES_NOP;
                            wreg_output <= `WriteDisable;
                            instvalid <= `InstValid;
                            reg1_read_output <= 1'b0;
                            reg2_read_output <= 1'b0; 
                        end
                    if(inst_input == `EXE_TLBP)
                        begin
                            aluop_output <= `EXE_TLBP_OP;
                            alusel_output <= `EXE_RES_NOP;
                            wreg_output <= `WriteDisable;
                            instvalid <= `InstValid;
                            reg1_read_output <= 1'b0;
                            reg2_read_output <= 1'b0; 
                        end
                end
        end
    
endmodule
