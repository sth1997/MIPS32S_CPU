`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/08 22:31:56
// Design Name: 
// Module Name: SERIAL
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

module SERIAL(
    input wire clk_50M,
    input wire rst_i,
    
    output wire txd,
    input  wire rxd,
    
    input  wire wb_stb_i,
    input  wire wb_cyc_i,
    output reg wb_ack_o,
    input  wire [31: 0] wb_addr_i,
    input  wire [ 3: 0] wb_sel_i,
    input  wire wb_we_i,
    input  wire [31: 0] wb_data_i,
    output reg [31: 0] wb_data_o
    );
    reg [7:0] regs[0 : 15];
    
    wire [7:0] ext_uart_rx;
    reg  [7:0] ext_uart_tx;
    wire ext_uart_ready, ext_uart_busy;
    reg ext_uart_start, ext_uart_clear;
    
    // Wishbone read/write accesses
    wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
    wire wb_wr  = wb_acc & wb_we_i;       // WISHBONE write access
    wire wb_rd  = wb_acc & ~wb_we_i; 
    
    async_receiver #(.ClkFrequency(`SERIAL_CLK_FREQUENCE),.Baud(`BAUD_RATE)) 
        ext_uart_r(
            .clk(clk_50M),
            .RxD(rxd),
            .RxD_data_ready(ext_uart_ready),
            .RxD_clear(ext_uart_clear),
            .RxD_data(ext_uart_rx)
        );
        
    always @(posedge clk_50M) begin
        ext_uart_clear <= 1'b0;
        wb_ack_o <= 1'b0;
        ext_uart_start <= 1'b0;
        if (rst_i == 1'b1) begin
            wb_ack_o <= 1'b0;
            ext_uart_start <= 1'b0;
            ext_uart_clear <= 1'b0;
        end 
        else if (wb_acc == 1'b0) begin
            wb_ack_o <= 1'b0;
            wb_data_o <= 32'h00000000;
            ext_uart_start <= 1'b0;
            ext_uart_clear <= 1'b0;
        end
        else begin
            if (wb_addr_i == 32'hBFD003F8) begin 
            /*
                if(ext_uart_ready)begin
                    wb_data_o[7:0] <= ext_uart_rx;
                end
                if(!ext_uart_busy)begin 
                    ext_uart_tx <= wb_data_i[7:0];
                    ext_uart_start <= 1;
                end else begin 
                    ext_uart_start <= 0;
                end
                */
                if (wb_rd) begin
                    if (ext_uart_ready) begin
                        wb_data_o[31:8] <= 24'h000000;
                        wb_data_o[7:0] <= ext_uart_rx;
                        ext_uart_clear <= 1'b1;
                        wb_ack_o <= 1'b1;
                    end else begin
                        wb_ack_o <= 1'b0;
                    end
                end else begin
                    if (!ext_uart_busy) begin
                        ext_uart_tx <= wb_data_i[7:0];
                        ext_uart_start <= 1;
                        wb_ack_o <= 1'b1;
                    end else begin
                    
                    end
                end
            end else if (wb_addr_i == 32'hBFD003FC) begin
                if (wb_rd) begin
                    wb_data_o <= {30'h00000000, ext_uart_ready, !ext_uart_busy};
                    wb_ack_o <= 1'b1;
                end else begin
                    wb_ack_o <= 1'b1;
                end
            end else begin
                //TODO exception
                wb_ack_o <= 1'b1;
            end
        end
    end
    
    async_transmitter #(.ClkFrequency(`SERIAL_CLK_FREQUENCE),.Baud(`BAUD_RATE)) 
        ext_uart_t(
            .clk(clk_50M),
            .TxD(txd),
            .TxD_busy(ext_uart_busy),
            .TxD_start(ext_uart_start),
            .TxD_data(ext_uart_tx)
        );

endmodule
