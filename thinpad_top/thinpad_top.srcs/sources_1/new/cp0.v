`timescale 1ns / 1ps
`include "CONST.v"

module cp0_reg (
   
    input wire clk,
    input wire rst,
    
    input wire we_input,
    input wire[4: 0] waddr_input,
    input wire[4: 0] raddr_input,
    input wire[`RegBus] data_input,

    input wire[7: 0] int_input,
    input wire[31:0] excepttype_input,  
    input wire[`RegBus] current_inst_addr_input,
    input wire is_in_delayslot_input,
    input wire[`RegBus] unaligned_addr_input,
    input wire[`RegBus] badvaddr_input,
    
    output wire[`RegBus] exc_vec_addr_output,
    output reg[`RegBus] data_output,
    output reg[`RegBus] count_output,
    output reg[`RegBus] compare_output,
    output reg[`RegBus] status_output,
    output reg[`RegBus] cause_output,
    output reg[`RegBus] epc_output,
    output reg[`RegBus] ebase_output,
    output reg timer_int_output,
    output reg[`RegBus] index_output,
    output reg[`RegBus] entrylo0_output,
    output reg[`RegBus] entrylo1_output,
    output reg[`RegBus] badvaddr_output,
    output reg[`RegBus] entryhi_output,
    output reg[`RegBus] random_output,
    input wire[`TLB_WRITE_STRUCT_WIDTH - 1: 0] tlb_write_struct
);
	assign exc_vec_addr_output = {2'b10, ebase_output[29:12], 12'b0};
    wire tlb_write_switch;
    wire [`TLB_INDEX_WIDTH - 1: 0] tlb_write_index;
    wire [`TLB_ENTRY_WIDTH - 1: 0] tlb_write_entry;
	assign {tlb_write_switch, tlb_write_index, tlb_write_entry} = tlb_write_struct;

    always @(posedge clk) begin 
        if(rst == `RstEnable) begin
            count_output <= `ZeroWord;
            compare_output <= `ZeroWord;
            status_output <= 32'h10000000; //CU0 = 1
            cause_output<= `ZeroWord;
            epc_output <= `ZeroWord;
            ebase_output <= 32'h80001000;
            timer_int_output <= 1'b0;
            entrylo0_output <= `ZeroWord;
            entrylo1_output <= `ZeroWord;
            badvaddr_output <= `ZeroWord;
            entryhi_output <= `ZeroWord;
            index_output <= `ZeroWord;
            random_output <= `ZeroWord;
        end 
        else begin
            count_output <= count_output + 1;
            cause_output[15: 8] <= int_input;
            random_output <= random_output + 1;
        
            if(compare_output != `ZeroWord && count_output == compare_output) begin
                timer_int_output <= 1'b1;
            end

            if(we_input == `WriteEnable) begin
                case (waddr_input)
                    `CP0_REG_COUNT: begin
                        count_output <= data_input;
                    end
                    `CP0_REG_COMPARE: begin
                        compare_output <= data_input;
                        timer_int_output <= 1'b0;
                    end
                    `CP0_REG_STATUS:    begin
                        status_output[28] <= data_input[28]; //CU0
                        status_output[15: 8] <= data_input[15: 8]; //IM
                        status_output[4] <= data_input[4]; //user mode - 0, kenerl mode - 1
                        status_output[1: 0] <= data_input[1: 0]; //EXL, IE
                    end
                    `CP0_REG_EPC:   begin
                        epc_output <= data_input;
                    end
                    `CP0_REG_CAUSE: begin
                        cause_output[9: 8] <= data_input[9: 8];
                        cause_output[23] <= data_input[23];
                    end             
                    `CP0_REG_EBASE: begin
                        ebase_output[29: 12] <= data_input[29: 12];
                    end
                    `CP0_REG_INDEX: begin 
                        index_output[3: 0] <= data_input[3: 0];
                    end
                    `CP0_REG_ENTRYLO0: begin 
                        entrylo0_output[25: 6] <= data_input[25: 6];
                        entrylo0_output[2: 0] <= data_input[2: 0];
                    end
                    `CP0_REG_ENTRYLO1: begin 
                        entrylo1_output[25: 6] <= data_input[25: 6];
                        entrylo1_output[2: 0] <= data_input[2: 0];
                    end
                    `CP0_REG_BADVADDR: begin 
                        badvaddr_output <= data_input;
                    end
                    `CP0_REG_ENTRYHI: begin 
                        entryhi_output[31: 13] <= data_input[31: 13];
                        entryhi_output[7: 0] <= data_input[7: 0];
                    end
                    `CP0_TLBR: begin
                        if (tlb_write_switch == `TLB_READ_R) begin
                            {entryhi_output[31: 13], entrylo1_output[25: 6], entrylo1_output[2: 1], entrylo0_output[25: 6], entrylo0_output[2: 1]} <= tlb_write_entry;
                        end
                    end
                    `CP0_TLBP: begin
                        if (tlb_write_switch == `TLB_READ_P) begin
                            if (tlb_write_entry[0] == 1'b0) begin
                                index_output <= {{28{1'b0}}, tlb_write_index};
                            end else begin
                                index_output <= {32{1'b1}};
                            end
                        end
                    end
                endcase
            end

            
            case (excepttype_input)
                32'h00000001: begin  // interruption 
                    if(is_in_delayslot_input == `InDelaySlot) begin
                         epc_output <= current_inst_addr_input - 4;
                         cause_output[31] <= 1'b1;
                     end 
                     else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                     end
                     status_output[1] <= 1'b1;
                     cause_output[6: 2] <= 5'b00000;
                end
                32'h00000008: begin  // syscall
                    if(is_in_delayslot_input == `InDelaySlot) begin
                         epc_output <= current_inst_addr_input - 4;
                         cause_output[31] <= 1'b1;
                     end 
                     else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                     end
                     status_output[1] <= 1'b1;
                     cause_output[6: 2] <= 5'b01000;
                end
                32'h0000000a: begin  // invalid instruction
                    if(is_in_delayslot_input == `InDelaySlot) begin
                         epc_output <= current_inst_addr_input - 4;
                         cause_output[31] <= 1'b1;
                     end 
                     else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                     end
                     status_output[1] <= 1'b1;
                     cause_output[6: 2] <= 5'b01010;
                end
                32'h0000000b: begin  // ADEL
                    if(is_in_delayslot_input == `InDelaySlot) begin
                         epc_output <= current_inst_addr_input - 4;
                         cause_output[31] <= 1'b1;
                     end 
                     else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                     end
                     status_output[1] <= 1'b1;
                     cause_output[6: 2] <= 5'b00100;
                     badvaddr_output <= unaligned_addr_input;
                end
                32'h0000000c: begin  // ADES
                    if(is_in_delayslot_input == `InDelaySlot) begin
                         epc_output <= current_inst_addr_input - 4;
                         cause_output[31] <= 1'b1;
                     end 
                     else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                     end
                     status_output[1] <= 1'b1;
                     cause_output[6: 2] <= 5'b00101;
                     badvaddr_output <= unaligned_addr_input;
                end
                32'h0000000e: begin  // eret
                     status_output[1] <= 1'b0;
                end
                32'h0000000f: begin  // TLBL, inst
                    if(is_in_delayslot_input == `InDelaySlot) begin
                        epc_output <= current_inst_addr_input - 4;
                        cause_output[31] <= 1'b1;
                    end 
                    else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                    end
                    status_output[1] <= 1'b1;
                    cause_output[6: 2] <= 5'b00010;
                    badvaddr_output <= badvaddr_input;
                    entryhi_output[31: 13] <= badvaddr_input[31: 13];
                end
                32'h00000010: begin   // TLB mod
                    if(is_in_delayslot_input == `InDelaySlot) begin
                        epc_output <= current_inst_addr_input - 4;
                        cause_output[31] <= 1'b1;
                    end 
                    else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                    end
                    status_output[1] <= 1'b1;
                    cause_output[6: 2] <= 5'b00001;
                    badvaddr_output <= badvaddr_input;
                    entryhi_output[31: 13] <= badvaddr_input[31: 13];
                end
                32'h00000011: begin    // TLBL DATA 
                    if(is_in_delayslot_input == `InDelaySlot) begin
                        epc_output <= current_inst_addr_input - 4;
                        cause_output[31] <= 1'b1;
                    end 
                    else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                    end
                    status_output[1] <= 1'b1;
                    cause_output[6: 2] <= 5'b00010;
                    badvaddr_output <= badvaddr_input;
                    entryhi_output[31: 13] <= badvaddr_input[31: 13];
                end
                32'h00000012: begin    // TLBS 
                    if(is_in_delayslot_input == `InDelaySlot) begin
                        epc_output <= current_inst_addr_input - 4;
                        cause_output[31] <= 1'b1;
                    end 
                    else begin 
                        epc_output <= current_inst_addr_input;
                        cause_output[31] <= 1'b0;
                    end
                    status_output[1] <= 1'b1;
                    cause_output[6: 2] <= 5'b00011;
                    badvaddr_output <= badvaddr_input;
                    entryhi_output[31: 13] <= badvaddr_input[31: 13];
                end
                default: begin
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            data_output <= `ZeroWord;
        end 
        else begin
            case (raddr_input) 
                `CP0_REG_COUNT: begin
                    data_output <= count_output;
                end
                `CP0_REG_COMPARE: begin
                    data_output <= compare_output;    
                end
                `CP0_REG_STATUS: begin
                    data_output <= status_output;
                end
                `CP0_REG_EPC: begin
                    data_output <= epc_output;
                end
                `CP0_REG_CAUSE: begin
                    data_output <= {cause_output[31], 7'b0, cause_output[23],7'b0, int_input, 1'b0, cause_output[6: 2], 2'b00};
                end             
                `CP0_REG_EBASE: begin
                    data_output <= {2'b10, ebase_output[29: 12], 12'b0};        
                end
                `CP0_REG_INDEX: begin
                    data_output <= {index_output[31], 27'b0, index_output[3: 0]};
                end
                `CP0_REG_ENTRYLO0: begin 
                    data_output <= {2'b0, entrylo0_output[29: 6], 3'b0, entrylo0_output[2: 0]};
                end
                `CP0_REG_ENTRYLO1: begin 
                    data_output <= {2'b0, entrylo1_output[29: 6], 3'b0, entrylo1_output[2: 0]};
                end
                `CP0_REG_BADVADDR: begin 
                    data_output <= badvaddr_output;
                end
                `CP0_REG_ENTRYHI: begin 
                    data_output <= {entryhi_output[31: 13], 5'b0, entryhi_output[7: 0]};
                end
            endcase        
        end
    end

endmodule









module hilo_reg(
    input wire rst,
    input wire clk,
    input wire we,
    input wire[`RegBus] hi_input,
    input wire[`RegBus] lo_input,
    output reg[`RegBus] hi_output,
    output reg[`RegBus] lo_output
    );

	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			hi_output <= `ZeroWord;
			lo_output <= `ZeroWord;
		end
		else if(we == `WriteEnable) begin
			hi_output <= hi_input;
			lo_output <= lo_input;
		end
	end
	
endmodule
