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
    output wire[`RegBus] exc_vec_addr_o,

    output reg[`RegBus] data_o,

    output reg[`RegBus] count_o,
    output reg[`RegBus] compare_o,
    output reg[`RegBus] status_o,
    output reg[`RegBus] cause_o,
    output reg[`RegBus] epc_o,
    output reg[`RegBus] ebase_o,

    output reg timer_int_o

);
	assign exc_vec_addr_o = {2'b10, ebase_o[29:12], 12'b0};

    always @(posedge clk) begin 
        if(rst == `RstEnable) begin
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            status_o <= 32'h10000000; //CU0 = 1
            cause_o<= `ZeroWord;
            epc_o <= `ZeroWord;
            ebase_o <= 32'h80001000;
            timer_int_o <= 1'b0;
        end 
        else begin
            count_o <= count_o + 1;
            cause_o[15: 8] <= int_i;
        
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
                end
                32'h0000000e: begin  // eret
                     status_o[1] <= 1'b0;
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
            endcase  //case addr_i          
        end    //if
    end      //always

endmodule