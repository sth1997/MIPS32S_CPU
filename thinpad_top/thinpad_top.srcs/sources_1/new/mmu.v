`include "CONST.v"

module mmu (
    input wire clk,
    input wire rst,

    input wire[`RegBus] inst_addr_i, // virtual address
    output wire[`RegBus] inst_addr_o, // physical address, send to IF
    input wire[`RegBus] data_addr_i, // virtual addrress
    output wire[`RegBus] data_addr_o, // physical address, send to MEM

    input wire[`TLB_WRITE_STRUCT_WIDTH - 1: 0] tlb_write_struct, // items to be written in TLB
    input wire is_write_mem,
    output wire is_tlb_modify,
    output wire is_tlbl_inst,//inst read miss
    output wire is_tlbl_data,//data read miss
    output wire is_tlbs,//data write miss(inst won't be written)
    output wire[31: 0] badvaddr,
    
    input wire tlb_read_switch,
    input wire [`TLB_INDEX_WIDTH - 1: 0] tlb_read_index,
    input wire [`RegBus] tlb_read_addr,
    output wire[`TLB_WRITE_STRUCT_WIDTH - 1: 0] tlb_read_struct
);

    reg [`TLB_ENTRY_WIDTH-1: 0] tlb_entry[0: `TLB_NR_ENTRY - 1];

    wire inst_miss;
    wire data_miss;
    wire read_tlb_miss;
    wire inst_V;
    wire inst_D;
    wire data_V;
    wire data_D;
    wire inst_is_kseg0_kseg1;
    wire data_is_kseg0_kseg1;
    wire read_tlb_is_kseg0_kseg1;
    
    wire tlb_write_enable;
    wire [`TLB_INDEX_WIDTH - 1: 0] tlb_write_index;
    wire [`TLB_ENTRY_WIDTH - 1: 0] tlb_write_entry;
    
    
    wire [`TLB_INDEX_WIDTH - 1: 0] hit_index;
    
    assign is_tlb_modify = (!data_is_kseg0_kseg1) && (data_addr_i != `ZeroWord) && is_write_mem && !data_D;
    assign is_tlbs = (!data_is_kseg0_kseg1) && (data_addr_i != `ZeroWord) && is_write_mem && (data_miss || !data_V);
    assign is_tlbl_inst = (!inst_is_kseg0_kseg1) && (inst_addr_i != `ZeroWord) && !is_write_mem && (inst_miss || !inst_V);
    assign is_tlbl_data = (!data_is_kseg0_kseg1) && (data_addr_i != `ZeroWord) && !is_write_mem && (data_miss || !data_V);
    assign badvaddr = is_tlbl_inst? inst_addr_i: data_addr_i;

    assign {tlb_write_enable, tlb_write_index, tlb_write_entry} = tlb_write_struct;
    
    assign tlb_read_struct = (tlb_read_switch == `TLB_READ_R)?{tlb_read_switch, tlb_read_index, tlb_entry[tlb_read_index]}
        :{tlb_read_switch, (read_tlb_miss)?{4'b1111, {`TLB_ENTRY_WIDTH{1'b1}} }:{hit_index, {`TLB_ENTRY_WIDTH{1'b0}} }};

    always @(posedge clk) begin
        if (rst == `RstEnable) begin : your_name 
            integer i; 
            for(i = 0; i < `TLB_NR_ENTRY; i = i + 1)
                tlb_entry[i] <= {63{1'b0}};
        end 
        else if (tlb_write_enable) begin
            tlb_entry[tlb_write_index] <= tlb_write_entry;
        end

    end
    
    vir2phy read_vir2phy(
        .tlb_entry_0(tlb_entry[0]),
        .tlb_entry_1(tlb_entry[1]),
        .tlb_entry_2(tlb_entry[2]),
        .tlb_entry_3(tlb_entry[3]),
        .tlb_entry_4(tlb_entry[4]),
        .tlb_entry_5(tlb_entry[5]),
        .tlb_entry_6(tlb_entry[6]),
        .tlb_entry_7(tlb_entry[7]),
        .tlb_entry_8(tlb_entry[8]),
        .tlb_entry_9(tlb_entry[9]),
        .tlb_entry_10(tlb_entry[10]),
        .tlb_entry_11(tlb_entry[11]),
        .tlb_entry_12(tlb_entry[12]),
        .tlb_entry_13(tlb_entry[13]),
        .tlb_entry_14(tlb_entry[14]),
        .tlb_entry_15(tlb_entry[15]),
        
        .virtual_addr(tlb_read_addr),
        .tlb_miss(read_tlb_miss),
        .is_kseg0_kseg1(read_tlb_is_kseg0_kseg1),
        .hit_number(hit_index)
        
    );


    vir2phy inst_vir2phy(
        .tlb_entry_0(tlb_entry[0]),
        .tlb_entry_1(tlb_entry[1]),
        .tlb_entry_2(tlb_entry[2]),
        .tlb_entry_3(tlb_entry[3]),
        .tlb_entry_4(tlb_entry[4]),
        .tlb_entry_5(tlb_entry[5]),
        .tlb_entry_6(tlb_entry[6]),
        .tlb_entry_7(tlb_entry[7]),
        .tlb_entry_8(tlb_entry[8]),
        .tlb_entry_9(tlb_entry[9]),
        .tlb_entry_10(tlb_entry[10]),
        .tlb_entry_11(tlb_entry[11]),
        .tlb_entry_12(tlb_entry[12]),
        .tlb_entry_13(tlb_entry[13]),
        .tlb_entry_14(tlb_entry[14]),
        .tlb_entry_15(tlb_entry[15]),

        .physical_addr(inst_addr_o),
        .virtual_addr(inst_addr_i),
        .tlb_miss(inst_miss),
        .V(inst_V),
        .D(inst_D),

        .is_kseg0_kseg1(inst_is_kseg0_kseg1)

    );

    vir2phy data_vir2phy(
        .tlb_entry_0(tlb_entry[0]),
        .tlb_entry_1(tlb_entry[1]),
        .tlb_entry_2(tlb_entry[2]),
        .tlb_entry_3(tlb_entry[3]),
        .tlb_entry_4(tlb_entry[4]),
        .tlb_entry_5(tlb_entry[5]),
        .tlb_entry_6(tlb_entry[6]),
        .tlb_entry_7(tlb_entry[7]),
        .tlb_entry_8(tlb_entry[8]),
        .tlb_entry_9(tlb_entry[9]),
        .tlb_entry_10(tlb_entry[10]),
        .tlb_entry_11(tlb_entry[11]),
        .tlb_entry_12(tlb_entry[12]),
        .tlb_entry_13(tlb_entry[13]),
        .tlb_entry_14(tlb_entry[14]),
        .tlb_entry_15(tlb_entry[15]),

        .physical_addr(data_addr_o),
        .virtual_addr(data_addr_i),
        .tlb_miss(data_miss),
        .V(data_V),
        .D(data_D),

        .is_kseg0_kseg1(data_is_kseg0_kseg1)

    );
        
endmodule