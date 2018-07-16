`timescale 1ns / 1ps
`include "CONST.v"

module cp0_reg (
   
    input wire clk,
    input wire rst,
    
    input wire we_i,
    input wire[4: 0] waddr_i,
    input wire[4: 0] raddr_i,
    input wire[`RegBus] data_i,

    input wire[7: 0] int_i,
    input wire[31:0] excepttype_i,  
    input wire[`RegBus] current_inst_addr_i,
    input wire is_in_delayslot_i,
    input wire[`RegBus] unaligned_addr_i,
    input wire[`RegBus] badvaddr_i,
    
    output wire[`RegBus] exc_vec_addr_o,
    output reg[`RegBus] data_o,
    output reg[`RegBus] count_o,
    output reg[`RegBus] compare_o,
    output reg[`RegBus] status_o,
    output reg[`RegBus] cause_o,
    output reg[`RegBus] epc_o,
    output reg[`RegBus] ebase_o,
    output reg timer_int_o,
    output reg[`RegBus] index_o,
    output reg[`RegBus] entrylo0_o,
    output reg[`RegBus] entrylo1_o,
    output reg[`RegBus] badvaddr_o,
    output reg[`RegBus] entryhi_o,
    output reg[`RegBus] random_o,
    input wire[`TLB_WRITE_STRUCT_WIDTH - 1: 0] tlb_write_struct
);
	assign exc_vec_addr_o = {2'b10, ebase_o[29:12], 12'b0};
    wire tlb_write_switch;
    wire [`TLB_INDEX_WIDTH - 1: 0] tlb_write_index;
    wire [`TLB_ENTRY_WIDTH - 1: 0] tlb_write_entry;
	assign {tlb_write_switch, tlb_write_index, tlb_write_entry} = tlb_write_struct;

    always @(posedge clk) begin 
        if(rst == `RstEnable) begin
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            status_o <= 32'h10000000; //CU0 = 1
            cause_o<= `ZeroWord;
            epc_o <= `ZeroWord;
            ebase_o <= 32'h80001000;
            timer_int_o <= 1'b0;
            entrylo0_o <= `ZeroWord;
            entrylo1_o <= `ZeroWord;
            badvaddr_o <= `ZeroWord;
            entryhi_o <= `ZeroWord;
            index_o <= `ZeroWord;
            random_o <= `ZeroWord;
        end 
        else begin
            count_o <= count_o + 1;
            cause_o[15: 8] <= int_i;
            random_o <= random_o + 1;
        
            if(compare_o != `ZeroWord && count_o == compare_o) begin
                timer_int_o <= 1'b1;
            end

            if(we_i == `WriteEnable) begin
                case (waddr_i)
                    `CP0_REG_COUNT: begin
                        count_o <= data_i;
                    end
                    `CP0_REG_COMPARE: begin
                        compare_o <= data_i;
                        timer_int_o <= 1'b0;
                    end
                    `CP0_REG_STATUS:    begin
                        status_o[28] <= data_i[28]; //CU0
                        status_o[15: 8] <= data_i[15: 8]; //IM
                        status_o[4] <= data_i[4]; //user mode - 0, kenerl mode - 1
                        status_o[1: 0] <= data_i[1: 0]; //EXL, IE
                    end
                    `CP0_REG_EPC:   begin
                        epc_o <= data_i;
                    end
                    `CP0_REG_CAUSE: begin
                        cause_o[9: 8] <= data_i[9: 8];
                        cause_o[23] <= data_i[23];
                    end             
                    `CP0_REG_EBASE: begin
                        ebase_o[29: 12] <= data_i[29: 12];
                    end
                    `CP0_REG_INDEX: begin 
                        index_o[3: 0] <= data_i[3: 0];
                    end
                    `CP0_REG_ENTRYLO0: begin 
                        entrylo0_o[25: 6] <= data_i[25: 6];
                        entrylo0_o[2: 0] <= data_i[2: 0];
                    end
                    `CP0_REG_ENTRYLO1: begin 
                        entrylo1_o[25: 6] <= data_i[25: 6];
                        entrylo1_o[2: 0] <= data_i[2: 0];
                    end
                    `CP0_REG_BADVADDR: begin 
                        badvaddr_o <= data_i;
                    end
                    `CP0_REG_ENTRYHI: begin 
                        entryhi_o[31: 13] <= data_i[31: 13];
                        entryhi_o[7: 0] <= data_i[7: 0];
                    end
                    `CP0_TLBR: begin
                        if (tlb_write_switch == `TLB_READ_R) begin
                            {entryhi_o[31: 13], entrylo1_o[25: 6], entrylo1_o[2: 1], entrylo0_o[25: 6], entrylo0_o[2: 1]} <= tlb_write_entry;
                        end
                    end
                    `CP0_TLBP: begin
                        if (tlb_write_switch == `TLB_READ_P) begin
                            if (tlb_write_entry[0] == 1'b0) begin
                                index_o <= {{28{1'b0}}, tlb_write_index};
                            end else begin
                                index_o <= {32{1'b1}};
                            end
                        end
                    end
                endcase
            end

            
            case (excepttype_i)
                32'h00000001: begin  // interruption 
                    if(is_in_delayslot_i == `InDelaySlot) begin
                         epc_o <= current_inst_addr_i - 4;
                         cause_o[31] <= 1'b1;
                     end 
                     else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                     end
                     status_o[1] <= 1'b1;
                     cause_o[6: 2] <= 5'b00000;
                end
                32'h00000008: begin  // syscall
                    if(is_in_delayslot_i == `InDelaySlot) begin
                         epc_o <= current_inst_addr_i - 4;
                         cause_o[31] <= 1'b1;
                     end 
                     else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                     end
                     status_o[1] <= 1'b1;
                     cause_o[6: 2] <= 5'b01000;
                end
                32'h0000000a: begin  // invalid instruction
                    if(is_in_delayslot_i == `InDelaySlot) begin
                         epc_o <= current_inst_addr_i - 4;
                         cause_o[31] <= 1'b1;
                     end 
                     else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                     end
                     status_o[1] <= 1'b1;
                     cause_o[6: 2] <= 5'b01010;
                end
                32'h0000000b: begin  // ADEL
                    if(is_in_delayslot_i == `InDelaySlot) begin
                         epc_o <= current_inst_addr_i - 4;
                         cause_o[31] <= 1'b1;
                     end 
                     else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                     end
                     status_o[1] <= 1'b1;
                     cause_o[6: 2] <= 5'b00100;
                     badvaddr_o <= unaligned_addr_i;
                end
                32'h0000000c: begin  // ADES
                    if(is_in_delayslot_i == `InDelaySlot) begin
                         epc_o <= current_inst_addr_i - 4;
                         cause_o[31] <= 1'b1;
                     end 
                     else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                     end
                     status_o[1] <= 1'b1;
                     cause_o[6: 2] <= 5'b00101;
                     badvaddr_o <= unaligned_addr_i;
                end
                32'h0000000e: begin  // eret
                     status_o[1] <= 1'b0;
                end
                32'h0000000f: begin  // TLBL, inst
                    if(is_in_delayslot_i == `InDelaySlot) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end 
                    else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6: 2] <= 5'b00010;
                    badvaddr_o <= badvaddr_i;
                    entryhi_o[31: 13] <= badvaddr_i[31: 13];
                end
                32'h00000010: begin   // TLB mod
                    if(is_in_delayslot_i == `InDelaySlot) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end 
                    else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6: 2] <= 5'b00001;
                    badvaddr_o <= badvaddr_i;
                    entryhi_o[31: 13] <= badvaddr_i[31: 13];
                end
                32'h00000011: begin    // TLBL DATA 
                    if(is_in_delayslot_i == `InDelaySlot) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end 
                    else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6: 2] <= 5'b00010;
                    badvaddr_o <= badvaddr_i;
                    entryhi_o[31: 13] <= badvaddr_i[31: 13];
                end
                32'h00000012: begin    // TLBS 
                    if(is_in_delayslot_i == `InDelaySlot) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end 
                    else begin 
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6: 2] <= 5'b00011;
                    badvaddr_o <= badvaddr_i;
                    entryhi_o[31: 13] <= badvaddr_i[31: 13];
                end
                default: begin
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end 
        else begin
            case (raddr_i) 
                `CP0_REG_COUNT: begin
                    data_o <= count_o;
                end
                `CP0_REG_COMPARE: begin
                    data_o <= compare_o;    
                end
                `CP0_REG_STATUS: begin
                    data_o <= status_o;
                end
                `CP0_REG_EPC: begin
                    data_o <= epc_o;
                end
                `CP0_REG_CAUSE: begin
                    data_o <= {cause_o[31], 7'b0, cause_o[23],7'b0, int_i, 1'b0, cause_o[6: 2], 2'b00};
                end             
                `CP0_REG_EBASE: begin
                    data_o <= {2'b10, ebase_o[29: 12], 12'b0};        
                end
                `CP0_REG_INDEX: begin
                    data_o <= {index_o[31], 27'b0, index_o[3: 0]};
                end
                `CP0_REG_ENTRYLO0: begin 
                    data_o <= {2'b0, entrylo0_o[29: 6], 3'b0, entrylo0_o[2: 0]};
                end
                `CP0_REG_ENTRYLO1: begin 
                    data_o <= {2'b0, entrylo1_o[29: 6], 3'b0, entrylo1_o[2: 0]};
                end
                `CP0_REG_BADVADDR: begin 
                    data_o <= badvaddr_o;
                end
                `CP0_REG_ENTRYHI: begin 
                    data_o <= {entryhi_o[31: 13], 5'b0, entryhi_o[7: 0]};
                end
            endcase        
        end
    end

endmodule