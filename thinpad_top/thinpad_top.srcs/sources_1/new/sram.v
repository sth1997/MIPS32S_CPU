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
	reg ram_oe = 1, ram_we = 1;//低有效，0-enable

    //低有效，0-enable
	assign baseram_ce = ~(wb_acc & ~ram_selector);
	assign extram_ce = ~(wb_acc & ram_selector);
	assign baseram_oe = ram_selector | ram_oe;
	assign extram_oe = (~ram_selector) | ram_oe;
	assign baseram_we = ~(wb_wr & ~ram_selector & ~ram_we);
	assign extram_we = ~(wb_wr & ram_selector & ~ram_we);

	//assign wb_data_o = ram_selector ? extram_data : baseram_data;

	reg [31:0] data_to_write;
	assign baseram_data = baseram_oe ? data_to_write : {32{1'bz}};
	assign extram_data = extram_oe ? data_to_write : {32{1'bz}};
	assign baseram_addr = wb_addr_i[21:2];
	assign extram_addr = wb_addr_i[21:2];
	assign baseram_be = 4'b0000;
	assign extram_be = 4'b0000;

	reg [2:0] state;
	localparam IDLE = 3'b000;
	localparam READ = 3'b001;
	localparam WRITE0 = 3'b100;
	localparam WRITE1 = 3'b101;
	localparam READ_BEFORE_WRITE = 3'b110;

	//all select
	wire all_select = wb_sel_i[3] & wb_sel_i[2] & wb_sel_i[1] & wb_sel_i[0];

	always @(posedge clk_i) begin
		if (rst_i == 1'b1) begin
			// reset
			state <= IDLE;
			wb_ack_o <= 1'b0;
			ram_oe <= 1;
			ram_we <= 1;
		end 
		else if (wb_acc == 1'b0) begin
			state <= IDLE;
			wb_ack_o <= 1'b0;
			wb_data_o <= 32'h00000000;
			ram_oe <= 1;
			ram_we <= 1;
		end
		else begin
			case(state)
				IDLE:begin
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
					state <= IDLE;
				end

				WRITE0:begin
					ram_we <= 0;
					state <= WRITE1;
				end

				WRITE1:begin
					ram_we <= 1;
					wb_ack_o <= 1'b1;
					state <=IDLE;
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
			endcase
		end
	end

endmodule