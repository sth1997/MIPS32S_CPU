 `include "CONST.v"

module vir2phy(
  input wire[62: 0] tlb_entry_0,
  input wire[62: 0] tlb_entry_1,
  input wire[62: 0] tlb_entry_2,
  input wire[62: 0] tlb_entry_3,
  input wire[62: 0] tlb_entry_4,
  input wire[62: 0] tlb_entry_5,
  input wire[62: 0] tlb_entry_6,
  input wire[62: 0] tlb_entry_7,
  input wire[62: 0] tlb_entry_8,
  input wire[62: 0] tlb_entry_9,
  input wire[62: 0] tlb_entry_10,
  input wire[62: 0] tlb_entry_11,
  input wire[62: 0] tlb_entry_12,
  input wire[62: 0] tlb_entry_13,
  input wire[62: 0] tlb_entry_14,
  input wire[62: 0] tlb_entry_15,
  input wire[31: 0] virtual_addr,
  
  output wire[31: 0] physical_addr,
  output wire tlb_miss,
  output wire V,
  output wire D,
  output wire is_kseg0_kseg1

);


reg[`RegBus] physical_addr_sm;
wire[`RegBus] physical_addr_tlb;
reg mmu_is_kseg0_kseg1;

assign is_kseg0_kseg1 = mmu_is_kseg0_kseg1;
assign physical_addr = mmu_is_kseg0_kseg1? physical_addr_sm: physical_addr_tlb;

// kseg0/kseg1: Static Mapping
always @(*) begin
    mmu_is_kseg0_kseg1 <= 1'b1;
    physical_addr_sm <= 32'b0;
    casez(virtual_addr[31:29])
        3'b110, 3'b111,                         //kseg2
        3'b000, 3'b001, 3'b010, 3'b011: begin   //kuseg
            mmu_is_kseg0_kseg1 <= 1'b0;
        end
        3'b100,         //kseg0
        3'b101: begin   //kseg1
            physical_addr_sm <= {3'b0, virtual_addr[28:0]};
        end
    endcase
end


// ***************** TLB *********************//
wire[19: 0] PFN;
reg[3: 0] hit_index;
reg[15: 0] hit;
wire[62: 0] tlb_entry[0: 15];

assign tlb_entry[0] = tlb_entry_0;
assign tlb_entry[1] = tlb_entry_1;
assign tlb_entry[2] = tlb_entry_2;
assign tlb_entry[3] = tlb_entry_3;
assign tlb_entry[4] = tlb_entry_4;
assign tlb_entry[5] = tlb_entry_5;
assign tlb_entry[6] = tlb_entry_6;
assign tlb_entry[7] = tlb_entry_7;
assign tlb_entry[8] = tlb_entry_8;
assign tlb_entry[9] = tlb_entry_9;
assign tlb_entry[10] = tlb_entry_10;
assign tlb_entry[11] = tlb_entry_11;
assign tlb_entry[12] = tlb_entry_12;
assign tlb_entry[13] = tlb_entry_13;
assign tlb_entry[14] = tlb_entry_14;
assign tlb_entry[15] = tlb_entry_15;

always @ (*) begin: name   
	integer i;
	for (i = 0; i < `TLB_NR_ENTRY; i = i + 1)  begin: gen_block
		      hit[i] <= (tlb_entry[i][62: 44] == virtual_addr[31: 13]);
    end
end

always @ (*) begin
    if(hit[0]) begin
        hit_index <= 4'd0;
    end 
    else if(hit[1]) begin
        hit_index <= 4'd1;
    end 
    else if(hit[2]) begin
        hit_index <= 4'd2;
    end 
    else if(hit[3]) begin
        hit_index <= 4'd3;
    end 
    else if(hit[4]) begin
        hit_index <= 4'd4;
    end 
    else if(hit[5]) begin
        hit_index <= 4'd5;
    end 
    else if(hit[6]) begin
        hit_index <= 4'd6;
    end 
    else if(hit[7]) begin
        hit_index <= 4'd7;
    end 
    else if(hit[8]) begin
        hit_index <= 4'd8;
    end 
    else if(hit[9]) begin
        hit_index <= 4'd9;
    end 
    else if(hit[10]) begin
        hit_index <= 4'd10;
    end 
    else if(hit[11]) begin
        hit_index <= 4'd11;
    end 
    else if(hit[12]) begin
        hit_index <= 4'd12;
    end 
    else if(hit[13]) begin
        hit_index <= 4'd13;
    end 
    else if(hit[14]) begin
        hit_index <= 4'd14;
    end 
    else if(hit[15]) begin
        hit_index <= 4'd15;
    end 
end

assign PFN = (virtual_addr[12]? tlb_entry[hit_index][43: 24]: tlb_entry[hit_index][21: 2]);
assign D = (virtual_addr[12]? tlb_entry[hit_index][23]: tlb_entry[hit_index][1]);
assign V = (virtual_addr[12]? tlb_entry[hit_index][22]: tlb_entry[hit_index][0]);
assign tlb_miss = (~|hit);
assign physical_addr_tlb = {PFN, virtual_addr[11: 0]};

endmodule
