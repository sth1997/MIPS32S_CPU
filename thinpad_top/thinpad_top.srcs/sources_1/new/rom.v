`include "CONST.v"
module rom_top(

	input              clk_input,
    input              rst_input,
   
    input              wb_stb_input,
    input              wb_cyc_input,
    output reg         wb_ack_output,
    input      [31: 0] wb_addr_input,
    input      [ 3: 0] wb_sel_input,
    input              wb_we_input,
    input      [31: 0] wb_data_input,
    output reg [31: 0] wb_data_output
);
	
	reg[`InstBus]  inst_mem[0: `InstMemNum-1]; 		//inst_mem['InstMemNum - 1][32]

	initial $readmemh ( "boot.data", inst_mem );

    // wb read/write accesses
    wire wb_acc = wb_cyc_input & wb_stb_input;    // wb access
    wire wb_wr  = wb_acc & wb_we_input;       // wb write access
    wire wb_rd  = wb_acc & ~wb_we_input;      // wb read access


	always @ (*) begin
		if (rst_input == `RstEnable) begin
			wb_ack_output <= 1'b0;
			wb_data_output <= 32'h00000000;
	  	end else if (wb_acc == 1'b0) begin
	  		wb_ack_output <= 1'b0;
	  		wb_data_output <= 32'h00000000;
	  	end else begin
	  		wb_ack_output <= 1'b1;
	  		wb_data_output <= inst_mem[wb_addr_input[`InstMemNumLog2 + 1: 2]];
	  	end
	end

endmodule
