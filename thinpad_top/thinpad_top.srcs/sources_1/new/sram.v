module sram_top(
	input  wire            clk_i,
    input  wire            rst_i,
   
    input  wire            wb_stb_i,
    input  wire            wb_cyc_i,
    output reg         wb_ack_o,
    input  wire    [31: 0] wb_addr_i,
    input  wire    [ 3: 0] wb_sel_i,
    input  wire            wb_we_i,
    input  wire    [31: 0] wb_data_i,
    output reg [31: 0] wb_data_o,

	//CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    output wire [19:0] baseram_addr,
	inout wire [31:0] baseram_data,
	output wire [3:0] baseram_be,
	output wire baseram_ce,
	output wire baseram_oe,
	output wire baseram_we,
	output wire [19:0] extram_addr,
	inout wire [31:0] extram_data,
	output wire [3:0] extram_be,
	output wire extram_ce,
	output wire extram_oe,
	output wire extram_we
	);
	
	// Wishbone read/write accesses
    wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
    wire wb_wr  = wb_acc & wb_we_i;       // WISHBONE write access
    wire wb_rd  = wb_acc & ~wb_we_i;      // WISHBONE read access


	wire ram_selector = wb_addr_i[22];		//0-base 1-extra
	reg ram_oe = 1, ram_we = 1, ram_ce = 1;//低有效，0-enable

    //低有效，0-enable
	assign baseram_ce = ~(wb_acc & ~ram_selector & ~ram_ce);
	assign extram_ce = ~(wb_acc & ram_selector & ~ram_ce);
	assign baseram_oe = ram_selector | ram_oe;
	assign extram_oe = (~ram_selector) | ram_oe;
	assign baseram_we = ~(wb_wr & ~ram_selector & ~ram_we);
	assign extram_we = ~(wb_wr & ram_selector & ~ram_we);

	//assign wb_data_o = ram_selector ? extram_data : baseram_data;

	reg [31:0] data_to_write;
	assign baseram_data = (baseram_oe ^ (((wb_addr_i == 32'hBFD003F8)||(wb_addr_i == 32'hBFD003FC)) && (wb_rd))) ? data_to_write : {32{1'bz}};
	assign extram_data = extram_oe ? data_to_write : {32{1'bz}};
	assign baseram_addr = wb_addr_i[21:2];
	assign extram_addr = wb_addr_i[21:2];
	assign baseram_be = 4'b0000;
	assign extram_be = 4'b0000;

	reg [3:0] state;
	localparam IDLE = 4'b0000;
	localparam READ = 4'b0001;
	localparam WRITE0 = 4'b0100;
	localparam WRITE1 = 4'b0101;
	localparam READ_BEFORE_WRITE = 4'b0110;
	localparam READ_FROM_COMP = 4'b0010;
	localparam READ_FROM_COMP_FINISH = 4'b1010;
	localparam WRITE_TO_COMP_PRE = 4'b0011;
	localparam WRITE_TO_COMP_SND = 4'b0111;
	localparam WRITE_TO_COMP_FINISH = 4'b1111;
	localparam COMP_STATE_READ = 4'b1000;

	//all select
	wire all_select = wb_sel_i[3] & wb_sel_i[2] & wb_sel_i[1] & wb_sel_i[0];

	always @(posedge clk_i) begin
		if (rst_i == 1'b1) begin
			// reset
			state <= IDLE;
			wb_ack_o <= 1'b0;
			ram_ce <= 1;
			ram_oe <= 1;
			ram_we <= 1;
		end 
		else if (wb_acc == 1'b0) begin
			state <= IDLE;
			wb_ack_o <= 1'b0;
			wb_data_o <= 32'h00000000;
			ram_ce <= 1;
			ram_oe <= 1;
			ram_we <= 1;
		end
		else begin
			case(state)
				IDLE:begin
					if (wb_addr_i == 32'hBFD003F8) begin
						ram_ce <= 1;
						ram_oe <= 1;
						ram_we <= 1;
						wb_ack_o <= 1'b0;
						if (wb_rd) begin
							uart_rdn <= 1;
							state <= READ_FROM_COMP;
						end else begin
							uart_wrn <= 1;
							state <= WRITE_TO_COMP_PRE;
						end
					end 
					else if (wb_addr_i == 32'hBFD003FC) begin
						ram_ce <= 1;
						ram_oe <= 1;
						ram_we <= 1;
						wb_ack_o <= 1'b0;
						uart_rdn <= 1;
						state <= COMP_STATE_READ;
					end else begin
						ram_ce <= 0;
						wb_ack_o <= 1'b0;
						if (wb_rd) begin
							ram_oe <= 0;
							state <= READ;
						end
						else if (wb_wr&all_select) begin
							data_to_write <= wb_data_i;
							state <= WRITE0;
						end
						else if (wb_wr&(~all_select)) begin
							ram_oe <= 0;
							state <= READ_BEFORE_WRITE;
						end
					end
				end

				COMP_STATE_READ:begin
					wb_data_o[31:2] <= 30'h00000000;
					wb_data_o[0] <= 1;
					wb_data_o[1] <= uart_dataready;
					uart_rdn <= 1;
					wb_ack_o <= 1'b1;
					state <= IDLE;
				end

				READ:begin
					wb_data_o <= 32'h00000000;
					if (ram_selector) begin
						if (wb_sel_i[3]==1'b1)
							wb_data_o[31:24] <= extram_data[31:24];
						if (wb_sel_i[2]==1'b1)
							wb_data_o[23:16] <= extram_data[23:16];
						if (wb_sel_i[1]==1'b1)
							wb_data_o[15:8] <= extram_data[15:8];
						if (wb_sel_i[0]==1'b1)
							wb_data_o[7:0] <= extram_data[7:0]; 
					end else begin
						if (wb_sel_i[3]==1'b1)
							wb_data_o[31:24] <= baseram_data[31:24];
						if (wb_sel_i[2]==1'b1)
							wb_data_o[23:16] <= baseram_data[23:16];
						if (wb_sel_i[1]==1'b1)
							wb_data_o[15:8] <= baseram_data[15:8];
						if (wb_sel_i[0]==1'b1)
							wb_data_o[7:0] <= baseram_data[7:0];
					end
					wb_ack_o <= 1'b1;
					ram_oe <= 1;
					ram_ce <= 1;
					state <= IDLE;
				end

				WRITE0:begin
					ram_we <= 0;
					state <= WRITE1;
				end

				WRITE1:begin
					ram_we <= 1;
					wb_ack_o <= 1'b1;
					ram_ce <= 1;
					state <= IDLE;
				end

				READ_BEFORE_WRITE:begin
					data_to_write <= ram_selector ? extram_data : baseram_data;
					if (wb_sel_i[3]==1'b1)
						data_to_write[31:24] <= wb_data_i[31:24];
					if (wb_sel_i[2]==1'b1)
						data_to_write[23:16] <= wb_data_i[23:16];
					if (wb_sel_i[1]==1'b1)
						data_to_write[15:8] <= wb_data_i[15:8];
					if (wb_sel_i[0]==1'b1)
						data_to_write[7:0] <= wb_data_i[7:0]; 
					ram_oe <= 1;
					state <= WRITE0;
				end

				READ_FROM_COMP:begin
					if (uart_dataready == 1) begin
						uart_rdn <= 0;
						state <= READ_FROM_COMP_FINISH;
					end
				end

				READ_FROM_COMP_FINISH:begin
					wb_data_o[31:8] <= 24'h000000;
					wb_data_o[7:0] <= baseram_data[7:0];
					uart_rdn <= 1;
					wb_ack_o <= 1'b1;
					state <= IDLE;
				end

				WRITE_TO_COMP_PRE:begin
					data_to_write[7:0] <= wb_data_i[7:0];
					uart_wrn <= 0;
					state <= WRITE_TO_COMP_SND;
				end

				WRITE_TO_COMP_SND:begin
					uart_wrn <= 1;
					state <= WRITE_TO_COMP_FINISH;
				end

				WRITE_TO_COMP_FINISH:begin
					if (uart_tbre == 1 && uart_tsre == 1) begin
						wb_ack_o <= 1'b1;
						state <= IDLE;
					end
				end
			endcase
		end
	end

endmodule