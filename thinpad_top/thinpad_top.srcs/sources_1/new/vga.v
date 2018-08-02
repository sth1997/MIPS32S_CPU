`timescale 1ns / 1ps
//
// WIDTH: bits in register hdata & vdata
// HSIZE: horizontal size of visible field 
// HFP: horizontal front of pulse
// HSP: horizontal stop of pulse
// HMAX: horizontal max size of value
// VSIZE: vertical size of visible field 
// VFP: vertical front of pulse
// VSP: vertical stop of pulse
// VMAX: vertical max size of value
// HSPP: horizontal synchro pulse polarity (0 - negative, 1 - positive)
// VSPP: vertical synchro pulse polarity (0 - negative, 1 - positive)
//
`define H_CHAR_NUM 100
`define V_CHAR_NUM 6'b100000
`define FLUSH_STEP 5
module vga
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    input wire rst,
    input wire[7:0] data_from_serial,
    input wire serial_data_enable,
    output wire[2:0] red,
    output wire[2:0] green,
    output wire[1:0] blue,
    output wire hsync,
    output wire vsync,
    output reg [WIDTH - 1:0] hdata,
    output reg [WIDTH - 1:0] vdata,
    output wire data_enable
);
reg [5:0] startline;
reg [5:0] char_pos_line;
reg [6:0] char_pos_column;
reg [6:0] endline[0:63];

always @ (posedge clk) begin
    if (rst == 1'b1) begin
        startline <= 6'b000000;
        char_pos_line <= 6'b000000;
        char_pos_column <= 7'b0000000;
        endline[6'b000000] <= 7'b0000000;
    end else if (serial_data_enable) begin
        if (data_from_serial == 8'h0A) begin
            endline[char_pos_line] <= char_pos_column;
            char_pos_column <= 7'b0000000;
            if (char_pos_line == (startline + `V_CHAR_NUM - 6'b000001)) begin
                char_pos_line <= char_pos_line + 1;
                startline <= startline + `FLUSH_STEP;
            end else begin
                char_pos_line <= char_pos_line + 1;
            end
        end else if ((data_from_serial == 8'h08)||(data_from_serial == 8'h7f)) begin
            if (char_pos_column > 0) begin
                char_pos_column <= char_pos_column -1;
            end
        end else begin
            if (char_pos_column == (`H_CHAR_NUM - 1)) begin
                endline[char_pos_line] <= char_pos_column;
                char_pos_column <= 7'b0000000;
                if (char_pos_line == (startline + `V_CHAR_NUM - 6'b000001)) begin
                    char_pos_line <= char_pos_line + 1;
                    startline <= startline + `FLUSH_STEP;
                end else begin
                    char_pos_line <= char_pos_line + 1;
                end
            end else begin
                char_pos_column <= char_pos_column + 1;
            end
        end
    end
end

wire [5:0] out_pos_line;
wire [6:0] out_pos_column;
wire [8:0] char_raw, char_real;

assign out_pos_line = vdata[9:4];
assign out_pos_column = hdata[9:3];

video_char_mem vga_ram0 (
    .wea(serial_data_enable),
    .clka(clk), .addra({char_pos_line, char_pos_column}), .dina({1'b0, data_from_serial}),
    .clkb(clk), .addrb({out_pos_line+startline, out_pos_column}), .doutb(char_raw)
);
assign char_real = (data_enable && 
    (((char_pos_line-startline > out_pos_line) && (endline[out_pos_line+startline] >= out_pos_column)) 
    || ((char_pos_line-startline == out_pos_line) && (char_pos_column >  out_pos_column)))
    ) ? char_raw : {9'b000000000};
    
    
wire [7:0] char_pic_line;
Font_Rom font_rom0 (
    .clk(clk),
    .addr({  {19{1'b0}}, char_real, vdata[3:0]  }),
    .fontRow(char_pic_line)
);
wire color;
assign color = char_pic_line[(~hdata[2:0])+1];
assign red = {3{color}};
assign green = {3{color}};
assign blue = {2{color}};
// init
initial begin
    hdata <= 0;
    vdata <= 0;
end

// hdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1))
        hdata <= 0;
    else
        hdata <= hdata + 1;
end

// vdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1)) 
    begin
        if (vdata == (VMAX - 1))
            vdata <= 0;
        else
            vdata <= vdata + 1;
    end
end

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule