`include "CONST.v"

module ctrl(

	input wire                rst,
	input wire                stallreq_from_id,
	input wire                stallreq_from_if,
	input wire                stallreq_from_mem,
	
	input wire[31: 0] excepttype_i,
	input wire[`RegBus] cp0_epc_i,
	input wire[`RegBus] exc_vec_addr_i, // exception vector address
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
		else if(excepttype_i != `ZeroWord) begin
				flush <= 1'b1;
				stall <= 6'b000000;
				case (excepttype_i)
					32'h00000001: begin  // interruption
						new_pc <= exc_vec_addr_i + 32'h180;
					end
					32'h00000008: begin  // syscall
						new_pc <= exc_vec_addr_i + 32'h180;
					end
					32'h0000000a: begin  // RI
						new_pc <= exc_vec_addr_i + 32'h180;
					end
					32'h0000000b: begin  // ADES
						new_pc <= exc_vec_addr_i + 32'h180;
					end
					32'h0000000c: begin  // ADEL
						new_pc <= exc_vec_addr_i + 32'h180;
					end
					32'h0000000e: begin  // eret
						new_pc <= cp0_epc_i;
					end
					/*
					32'h0000000f, 32'h00000010, 32'h00000011, 32'h00000012: begin  
					// TLBL, inst; TLB Mod;      TLBL_Data;    TLBS
						new_pc <= exc_vec_addr_i;
					end
					*/
					default : begin 
					end
				endcase
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
