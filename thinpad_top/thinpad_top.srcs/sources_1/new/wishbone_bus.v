`include "CONST.v"

`define WB_IDLE 2'b00
`define WB_BUSY 2'b01
`define WB_WAIT_FOR_STALL 2'b11
module wishbone_bus(

    input wire clk,
    input wire rst,
    
    //ctrl interface
    input wire[5: 0] stall_input,
    input wire flush_input,
    
    //cpu interface
    input wire cpu_ce_input,
    input wire[`RegBus] cpu_data_input,
    input wire[`RegBus] cpu_addr_input,
    input wire cpu_we_input,
    input wire[3: 0] cpu_sel_input,
    output reg[`RegBus] cpu_data_output,
    
    //wishbone interface
    input wire[`RegBus] wishbone_data_input,
    input wire  wishbone_ack_input,
    output reg[`RegBus] wishbone_addr_output,
    output reg[`RegBus] wishbone_data_output,
    output reg  wishbone_we_output,
    output reg[3: 0] wishbone_sel_output,
    output reg wishbone_stb_output,
    output reg wishbone_cyc_output,

    output reg stallreq         
    
);

    reg[1: 0] wishbone_state;
    reg[`RegBus] rd_buf;

    wire[`RegBus] phy_wb_addr;
    assign phy_wb_addr = cpu_addr_input;

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            wishbone_state <= `WB_IDLE;
            wishbone_addr_output <= `ZeroWord;
            wishbone_data_output <= `ZeroWord;
            wishbone_we_output <= `WriteDisable;
            wishbone_sel_output <= 4'b0000;
            wishbone_stb_output <= 1'b0;
            wishbone_cyc_output <= 1'b0;
            rd_buf <= `ZeroWord;
        end else begin
            case (wishbone_state)
                `WB_IDLE:       begin
                    if((cpu_ce_input == 1'b1) && (flush_input == 1'b0)) begin
                        wishbone_stb_output <= 1'b1;
                        wishbone_cyc_output <= 1'b1;
                        wishbone_addr_output <= phy_wb_addr;
                        wishbone_data_output <= cpu_data_input;
                        wishbone_we_output <= cpu_we_input;
                        wishbone_sel_output <=  cpu_sel_input;
                        wishbone_state <= `WB_BUSY;
                        rd_buf <= `ZeroWord;        
                    end                         
                end
                `WB_BUSY:       begin
                    if(wishbone_ack_input == 1'b1) begin
                        wishbone_stb_output <= 1'b0;
                        wishbone_cyc_output <= 1'b0;
                        wishbone_addr_output <= `ZeroWord;
                        wishbone_data_output <= `ZeroWord;
                        wishbone_we_output <= `WriteDisable;
                        wishbone_sel_output <=  4'b0000;
                        wishbone_state <= `WB_IDLE;
                        if(cpu_we_input == `WriteDisable) begin
                            rd_buf <= wishbone_data_input;
                        end
                        
                        if(stall_input != 6'b000000) begin
                            wishbone_state <= `WB_WAIT_FOR_STALL;
                        end                 
                    end else if(flush_input == 1'b1) begin
                      wishbone_stb_output <= 1'b0;
                        wishbone_cyc_output <= 1'b0;
                        wishbone_addr_output <= `ZeroWord;
                        wishbone_data_output <= `ZeroWord;
                        wishbone_we_output <= `WriteDisable;
                        wishbone_sel_output <=  4'b0000;
                        wishbone_state <= `WB_IDLE;
                        rd_buf <= `ZeroWord;
                    end
                end
                `WB_WAIT_FOR_STALL:     begin
                    if(stall_input == 6'b000000) begin
                        wishbone_state <= `WB_IDLE;
                    end
                end
                default: begin
                end 
            endcase
        end
    end
            

    always @ (*) begin
        if(rst == `RstEnable) begin
            stallreq <= `NoStop;
            cpu_data_output <= `ZeroWord;
        end else begin
            stallreq <= `NoStop;
            case (wishbone_state)
                `WB_IDLE:       begin
                    if((cpu_ce_input == 1'b1) && (flush_input == 1'b0)) begin
                        stallreq <= `Stop;
                        cpu_data_output <= `ZeroWord;                
                    end
                end
                `WB_BUSY:       begin
                    if(wishbone_ack_input == 1'b1) begin
                        stallreq <= `NoStop;
                        if(wishbone_we_output == `WriteDisable) begin
                            cpu_data_output <= wishbone_data_input; 
                        end else begin
                          cpu_data_output <= `ZeroWord;
                        end                         
                    end else begin
                        stallreq <= `Stop;  
                        cpu_data_output <= `ZeroWord;                
                    end
                end
                `WB_WAIT_FOR_STALL:     begin
                    stallreq <= `NoStop;
                    cpu_data_output <= rd_buf;
                end
                default: begin
                end 
            endcase
        end
    end

endmodule