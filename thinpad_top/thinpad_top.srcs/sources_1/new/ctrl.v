`include "CONST.v"

module ctrl(

	input wire                rst,
	input wire                stallreq_from_id,
	input wire                stallreq_from_if,
	input wire                stallreq_from_mem,

	output reg[`RegBus] new_pc,
	output reg flush,

	output reg[5: 0]           stall       
	
);

	always @ (*) begin
		if(rst == `RstEnable) begin
			stall <= 6'b000000;
			flush <= 1'b0;
			new_pc <= `ZeroWord;
		end 
		else if(stallreq_from_mem == `Stop) begin
			stall <= 6'b011111;		
			flush <= 1'b0;	
		end 
		else if(stallreq_from_id == `Stop) begin
			stall <= 6'b000111;		
			flush <= 1'b0;	
		end 
		else if(stallreq_from_if == `Stop) begin
			stall <= 6'b000111;	// stall the id_stage in order to keep the order of branch_inst and inst_in_delayslot
			flush <= 1'b0;	
		end 
		else begin
			stall <= 6'b000000;
			flush <= 1'b0;
			new_pc <= `ZeroWord;
		end    
	end     		

endmodule