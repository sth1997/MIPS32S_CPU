`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮�?关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮�?关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时�?1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信�?
    output wire uart_rdn,         //读串口信号，低有�?
    output wire uart_wrn,         //写串口信号，低有�?
    input wire uart_dataready,    //串口数据准备�?
    input wire uart_tbre,         //发�?�数据标�?
    input wire uart_tsre,         //数据发�?�完毕标�?

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共�?
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire base_ram_ce_n,       //BaseRAM片�?�，低有�?
    output wire base_ram_oe_n,       //BaseRAM读使能，低有�?
    output wire base_ram_we_n,       //BaseRAM写使能，低有�?

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire ext_ram_ce_n,       //ExtRAM片�?�，低有�?
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有�?
    output wire ext_ram_we_n,       //ExtRAM写使能，低有�?

    //直连串口信号
    output wire txd,  //直连串口发�?�端
    input  wire rxd,  //直连串口接收�?

    //Flash存储器信号，参�?? JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效�?16bit模式无意�?
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧�?
    output wire flash_ce_n,         //Flash片�?�信号，低有�?
    output wire flash_oe_n,         //Flash读使能信号，低有�?
    output wire flash_we_n,         //Flash写使能信号，低有�?
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash�?16位模式时请设�?1

    //USB 控制器信号，参�?? SL811 芯片手册
    output wire sl811_a0,
    inout  wire[7:0] sl811_d,
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参�?? DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素�?3�?
    output wire[2:0] video_green,  //绿色像素�?3�?
    output wire[1:0] video_blue,   //蓝色像素�?2�?
    output wire video_hsync,       //行同步（水平同步）信�?
    output wire video_vsync,       //场同步（垂直同步）信�?
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐�?
);

    wire rst;
    wire clk_o;
    assign rst = reset_btn;
    assign clk_o = clk_11M0592;

    //inst wb
    wire [31:0] inst_data_i;
    wire [31:0] inst_data_o;
    wire [31:0] inst_addr_i;
    wire [3:0] inst_sel_i;
    wire inst_we_i;
    wire inst_cyc_i;
    wire inst_stb_i;
    wire inst_ack_o;
    //data wb
    wire [31:0] data_data_i;
    wire [31:0] data_data_o;
    wire [31:0] data_addr_i;
    wire [3:0] data_sel_i;
    wire data_we_i;
    wire data_cyc_i;
    wire data_stb_i;
    wire data_ack_o;
    // sram wb
    wire [31:0] sram_data_i;
    wire [31:0] sram_data_o;
    wire [31:0] sram_addr_o;
    wire [3:0] sram_sel_o;
    wire sram_we_o;
    wire sram_cyc_o;
    wire sram_stb_o;
    wire sram_ack_i;

CPU_TOP CPU_TOP0(
        .clk(clk_o),
        .rst(rst),
    
        .rom_ce_output(),
        
        .iwishbone_data_input(inst_data_o),
        .iwishbone_ack_input(inst_ack_o),
        .iwishbone_addr_output(inst_addr_i),
        .iwishbone_data_output(inst_data_i),
        .iwishbone_we_output(inst_we_i),
        .iwishbone_sel_output(inst_sel_i),
        .iwishbone_stb_output(inst_stb_i),
        .iwishbone_cyc_output(inst_cyc_i),

        .dwishbone_data_input(data_data_o),
        .dwishbone_ack_input(data_ack_o),
        .dwishbone_addr_output(data_addr_i),
        .dwishbone_data_output(data_data_i),
        .dwishbone_we_output(data_we_i),
        .dwishbone_sel_output(data_sel_i),
        .dwishbone_stb_output(data_stb_i),
        .dwishbone_cyc_output(data_cyc_i),
        
        .ram_ce_output()
    );
    
sram_top sram_top0(
        .clk_i(clk_o),
        .rst_i(rst),
       
        .wb_stb_i(sram_stb_o),
        .wb_cyc_i(sram_cyc_o),
        .wb_ack_o(sram_ack_i),
        .wb_addr_i(sram_addr_o),
        .wb_sel_i(sram_sel_o),
        .wb_we_i(sram_we_o),
        .wb_data_i(sram_data_o),
        .wb_data_o(sram_data_i),
        .baseram_addr(base_ram_addr),
        .baseram_data(base_ram_data),
        .baseram_be(base_ram_be_n),
        .baseram_ce(base_ram_ce_n),
        .baseram_oe(base_ram_oe_n),
        .baseram_we(base_ram_we_n),
        .extram_addr(ext_ram_addr),
        .extram_data(ext_ram_data),
        .extram_be(ext_ram_be_n),
        .extram_ce(ext_ram_ce_n),
        .extram_oe(ext_ram_oe_n),
        .extram_we(ext_ram_we_n),
        .uart_rdn(uart_rdn),      
        .uart_wrn(uart_wrn),       
        .uart_dataready(uart_dataready),   
        .uart_tbre(uart_tbre),     
        .uart_tsre(uart_tsre)
    );
    
//wb_conmax
wb_conmax_top wb_conmax_top0(
    .clk_i(clk_o), .rst_i(rst),

    // Master 0 Interface
    .m0_data_i(data_data_i), 
    .m0_data_o(data_data_o), 
    .m0_addr_i(data_addr_i), 
    .m0_sel_i(data_sel_i), 
    .m0_we_i(data_we_i), 
    .m0_cyc_i(data_cyc_i),
    
    .m0_stb_i(data_stb_i), 
    .m0_ack_o(data_ack_o), 
    .m0_err_o(), 
    .m0_rty_o(),

    // Master 1 Interface


    .m1_data_i(inst_data_i), 
    .m1_data_o(inst_data_o), 
    .m1_addr_i(inst_addr_i), 
    .m1_sel_i(inst_sel_i), 
    .m1_we_i(inst_we_i), 
    .m1_cyc_i(inst_cyc_i),
    
    .m1_stb_i(inst_stb_i), 
    .m1_ack_o(inst_ack_o), 
    .m1_err_o(), 
    .m1_rty_o(),

    // Master 2 Interface
    
    .m2_data_i(`ZeroWord), 
    .m2_data_o(), 
    .m2_addr_i(`ZeroWord), 
    .m2_sel_i(4'b0000), 
    .m2_we_i(1'b0), 
    .m2_cyc_i(1'b0),
    
    .m2_stb_i(1'b0), 
    .m2_ack_o(), 
    .m2_err_o(), 
    .m2_rty_o(),

    // Master 3 Interface
    
    .m3_data_i(`ZeroWord), 
    .m3_data_o(), 
    .m3_addr_i(`ZeroWord), 
    .m3_sel_i(4'b0000), 
    .m3_we_i(1'b0), 
    .m3_cyc_i(1'b0),
    
    .m3_stb_i(1'b0), 
    .m3_ack_o(), 
    .m3_err_o(), 
    .m3_rty_o(),

    // Master 4 Interface
    
    .m4_data_i(`ZeroWord), 
    .m4_data_o(), 
    .m4_addr_i(`ZeroWord), 
    .m4_sel_i(4'b0000), 
    .m4_we_i(1'b0), 
    .m4_cyc_i(1'b0),
    
    .m4_stb_i(1'b0), 
    .m4_ack_o(), 
    .m4_err_o(), 
    .m4_rty_o(),

    // Master 5 Interface
    
    .m5_data_i(`ZeroWord), 
    .m5_data_o(), 
    .m5_addr_i(`ZeroWord), 
    .m5_sel_i(4'b0000), 
    .m5_we_i(1'b0), 
    .m5_cyc_i(1'b0),
    
    .m5_stb_i(1'b0), 
    .m5_ack_o(), 
    .m5_err_o(), 
    .m5_rty_o(),

    // Master 6 Interface
    
    .m6_data_i(`ZeroWord), 
    .m6_data_o(), 
    .m6_addr_i(`ZeroWord), 
    .m6_sel_i(4'b0000), 
    .m6_we_i(1'b0), 
    .m6_cyc_i(1'b0),
    
    .m6_stb_i(1'b0), 
    .m6_ack_o(), 
    .m6_err_o(), 
    .m6_rty_o(),

    // Master 7 Interface
    
    .m7_data_i(`ZeroWord), 
    .m7_data_o(), 
    .m7_addr_i(`ZeroWord), 
    .m7_sel_i(4'b0000), 
    .m7_we_i(1'b0), 
    .m7_cyc_i(1'b0),
    
    .m7_stb_i(1'b0), 
    .m7_ack_o(), 
    .m7_err_o(), 
    .m7_rty_o(),

    // Slave 0 Interface: ram

    .s0_data_i(sram_data_i), 
    .s0_data_o(sram_data_o), 
    .s0_addr_o(sram_addr_o), 
    .s0_sel_o(sram_sel_o), 
    .s0_we_o(sram_we_o), 
    .s0_cyc_o(sram_cyc_o),
    
    .s0_stb_o(sram_stb_o), 
    .s0_ack_i(sram_ack_i), 
    .s0_err_i(1'b0), 
    .s0_rty_i(1'b0),

    

    // Slave 1 Interface: flash

    .s1_data_i(), 
    .s1_data_o(), 
    .s1_addr_o(), 
    .s1_sel_o(), 
    .s1_we_o(), 
    .s1_cyc_o(),
    
    .s1_stb_o(), 
    .s1_ack_i(1'b0), 
    .s1_err_i(1'b0), 
    .s1_rty_i(1'b0),

    // Slave 2 Interface: rom

    .s2_data_i(), 
    .s2_data_o(), 
    .s2_addr_o(), 
    .s2_sel_o(), 
    .s2_we_o(), 
    .s2_cyc_o(),
    
    .s2_stb_o(), 
    .s2_ack_i(1'b0), 
    .s2_err_i(1'b0), 
    .s2_rty_i(1'b0),
    
    

     //Slave 3 Interface: uart
    
    .s3_data_i(), 
    .s3_data_o(), 
    .s3_addr_o(), 
    .s3_sel_o(), 
    .s3_we_o(), 
    .s3_cyc_o(),
    
    .s3_stb_o(), 
    .s3_ack_i(1'b0), 
    .s3_err_i(1'b0), 
    .s3_rty_i(1'b0),

    // Slave 4 Interface: vga
    
    .s4_data_i(), 
    .s4_data_o(), 
    .s4_addr_o(), 
    .s4_sel_o(), 
    .s4_we_o(), 
    .s4_cyc_o(),
    
    .s4_stb_o(), 
    .s4_ack_i(1'b0), 
    .s4_err_i(1'b0), 
    .s4_rty_i(1'b0),
    // Slave 5 Interface
    
    .s5_data_i(), 
    .s5_data_o(), 
    .s5_addr_o(), 
    .s5_sel_o(), 
    .s5_we_o(), 
    .s5_cyc_o(),
    
    .s5_stb_o(), 
    .s5_ack_i(1'b0), 
    .s5_err_i(1'b0), 
    .s5_rty_i(1'b0),

    // Slave 6 Interface
    
    .s6_data_i(), 
    .s6_data_o(), 
    .s6_addr_o(), 
    .s6_sel_o(), 
    .s6_we_o(), 
    .s6_cyc_o(),
    
    .s6_stb_o(), 
    .s6_ack_i(1'b0), 
    .s6_err_i(1'b0), 
    .s6_rty_i(1'b0),

    // Slave 7 Interface
    
    .s7_data_i(), 
    .s7_data_o(), 
    .s7_addr_o(), 
    .s7_sel_o(), 
    .s7_we_o(), 
    .s7_cyc_o(),
    
    .s7_stb_o(), 
    .s7_ack_i(1'b0), 
    .s7_err_i(1'b0), 
    .s7_rty_i(1'b0),

    // Slave 8 Interface
    
    .s8_data_i(), 
    .s8_data_o(), 
    .s8_addr_o(), 
    .s8_sel_o(), 
    .s8_we_o(), 
    .s8_cyc_o(),
    
    .s8_stb_o(), 
    .s8_ack_i(1'b0), 
    .s8_err_i(1'b0), 
    .s8_rty_i(1'b0),

    // Slave 9 Interface
    
    .s9_data_i(), 
    .s9_data_o(), 
    .s9_addr_o(), 
    .s9_sel_o(), 
    .s9_we_o(), 
    .s9_cyc_o(),
    
    .s9_stb_o(), 
    .s9_ack_i(1'b0), 
    .s9_err_i(1'b0), 
    .s9_rty_i(1'b0),

    // Slave 10 Interface
    
    .s10_data_i(), 
    .s10_data_o(), 
    .s10_addr_o(), 
    .s10_sel_o(), 
    .s10_we_o(), 
    .s10_cyc_o(),
    
    .s10_stb_o(), 
    .s10_ack_i(1'b0), 
    .s10_err_i(1'b0), 
    .s10_rty_i(1'b0),

    // Slave 11 Interface
    
    .s11_data_i(), 
    .s11_data_o(), 
    .s11_addr_o(), 
    .s11_sel_o(), 
    .s11_we_o(), 
    .s11_cyc_o(),
    
    .s11_stb_o(), 
    .s11_ack_i(1'b0), 
    .s11_err_i(1'b0), 
    .s11_rty_i(1'b0),

    // Slave 12 Interface
    
    .s12_data_i(), 
    .s12_data_o(), 
    .s12_addr_o(), 
    .s12_sel_o(), 
    .s12_we_o(), 
    .s12_cyc_o(),
    
    .s12_stb_o(), 
    .s12_ack_i(1'b0), 
    .s12_err_i(1'b0), 
    .s12_rty_i(1'b0),

    // Slave 13 Interface
    
    .s13_data_i(), 
    .s13_data_o(), 
    .s13_addr_o(), 
    .s13_sel_o(), 
    .s13_we_o(), 
    .s13_cyc_o(),
    
    .s13_stb_o(), 
    .s13_ack_i(1'b0), 
    .s13_err_i(1'b0), 
    .s13_rty_i(1'b0),

    // Slave 14 Interface
    
    .s14_data_i(), 
    .s14_data_o(), 
    .s14_addr_o(), 
    .s14_sel_o(), 
    .s14_we_o(), 
    .s14_cyc_o(),
    
    .s14_stb_o(), 
    .s14_ack_i(1'b0), 
    .s14_err_i(1'b0), 
    .s14_rty_i(1'b0),

    // Slave 15 Interface
    
    .s15_data_i(), 
    .s15_data_o(), 
    .s15_addr_o(), 
    .s15_sel_o(), 
    .s15_we_o(), 
    .s15_cyc_o(),
    
    .s15_stb_o(), 
    .s15_ack_i(1'b0), 
    .s15_err_i(1'b0), 
    .s15_rty_i(1'b0)
    );

/* =========== Demo code begin =========== */
/*
// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number�?16进制显示在数码管上面
reg[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

reg[15:0] led_bits;
assign leds = led_bits;

always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin //复位按下，设置LED和数码管为初始�??
        number<=0;
        led_bits <= 16'h1;
    end
    else begin //每次按下时钟按钮，数码管显示值加1，LED循环左移
        number <= number+1;
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end

//直连串口接收发�?�演示，从直连串口收到的数据再发送出�?
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;

async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块�?9600无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标�?
        .RxD_clear(ext_uart_ready),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的�?字节数据
    );
    
always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
    if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
        ext_uart_avai <= 1;
    end else if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_avai <= 0;
    end
end
always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发�?�出�?
    if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_tx <= ext_uart_buffer;
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发�?�模块，9600无检验位
    ext_uart_t(
        .clk(clk_50M),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发�?�器忙状态指�?
        .TxD_start(ext_uart_start),    //�?始发送信�?
        .TxD_data(ext_uart_tx)        //待发送的数据
    );

//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐�?
    .vdata(),      //纵坐�?
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);
*/
/* =========== Demo code end =========== */

endmodule
