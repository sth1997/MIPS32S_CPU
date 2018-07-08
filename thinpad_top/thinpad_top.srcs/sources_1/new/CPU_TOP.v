//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/05 16:07:11
// Design Name: 
// Module Name: CPU_TOP
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

module CPU_TOP (
    
	input wire clk,
	input wire rst,
	//output wire[31:0]             debug_led,
	
 	//input wire[7: 0] int_i,

	input wire[`RegBus] iwishbone_data_input,
	input wire iwishbone_ack_input,
	output wire[`RegBus] iwishbone_addr_output,
	output wire[`RegBus] iwishbone_data_output,
	output wire iwishbone_we_output,
	output wire[3:0] iwishbone_sel_output,
	output wire iwishbone_stb_output,
	output wire iwishbone_cyc_output, 
	
	input wire[`RegBus] dwishbone_data_input,
	input wire dwishbone_ack_input,
	output wire[`RegBus] dwishbone_addr_output,
	output wire[`RegBus] dwishbone_data_output,
	output wire dwishbone_we_output,
	output wire[3:0] dwishbone_sel_output,
	output wire dwishbone_stb_output,
	output wire dwishbone_cyc_output,

	output wire rom_ce_output,
	
	output wire ram_ce_output,
    
    output wire [13:0] debug_pc_output
    //output wire [7:0] debug_data_output

	//output wire timer_int_output

);
    wire[`InstAddrBus] pc;
    wire[`InstBus] inst_input;
    wire[`InstAddrBus] id_pc_input;
    wire[`InstBus] id_inst_input;
    
    wire[31:0] led_reg;
    
    wire[`AluOpBus] id_aluop_output;
    wire[`AluSelBus] id_alusel_output;
    wire[`RegBus] id_reg1_output;
    wire[`RegBus] id_reg2_output;
    wire id_wreg_output;
    wire[`RegAddrBus] id_waddr_output;
    wire id_is_in_delayslot_output;
    wire[`RegBus] id_link_addr_output;
    wire[`RegBus] id_inst_output;
    wire[`RegBus] id_current_inst_addr_output;
    
    wire[`AluOpBus] ex_aluop_input;
    wire[`AluSelBus] ex_alusel_input;
    wire[`RegBus] ex_reg1_input;
    wire[`RegBus] ex_reg2_input;
    wire ex_wreg_input;
    wire[`RegAddrBus] ex_waddr_input;
    wire ex_is_in_delayslot_input;    
    wire[`RegBus] ex_link_addr_input;
    wire[`RegBus] ex_inst_input;
    wire[31:0] ex_excepttype_input;    
    wire[`RegBus] ex_current_inst_addr_input;
    
    wire ex_wreg_output;
    wire[`RegAddrBus] ex_waddr_output;
    wire[`RegBus] ex_wdata_output;
    wire[`AluOpBus] ex_aluop_output;
    wire[`RegBus] ex_mem_addr_output;
    wire[`RegBus] ex_reg1_output;
    wire[`RegBus] ex_reg2_output;
    wire[`RegBus] ex_current_inst_addr_output;
    wire ex_is_in_delayslot_output;
    
    wire mem_wreg_input;
    wire[`RegAddrBus] mem_waddr_input;
    wire[`RegBus] mem_wdata_input;
    wire[`AluOpBus] mem_aluop_input;
    wire[`RegBus] mem_mem_addr_input;
    wire[`RegBus] mem_reg1_input;
    wire[`RegBus] mem_reg2_input; 
    wire mem_is_in_delayslot_input;
    wire[`RegBus] mem_current_inst_addr_input;
    
    wire mem_wreg_output;
    wire[`RegAddrBus] mem_waddr_output;
    wire[`RegBus] mem_wdata_output;
    wire mem_is_in_delayslot_output;
    wire[`RegBus] mem_current_inst_addr_output;
    wire[`RegBus] mem_unliagned_addr_output;
    
    
    wire wb_wreg_input;
    wire[`RegAddrBus] wb_waddr_input;
    wire[`RegBus] wb_wdata_input;
    wire wb_is_in_delayslot_input;
    wire[`RegBus] wb_current_inst_addr_input;
    
    
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;
    
    wire is_in_delayslot_input;
    wire is_in_delayslot_output;
    wire next_inst_in_delayslot_output;
    wire id_branch_flag_output;
    wire[`RegBus] branch_target_addr;
    
    wire[5: 0] bubble;
    wire bubblereq_from_id;    
    wire bubblereq_from_if;
    wire bubblereq_from_mem;
    
    wire flush;
    wire[`RegBus] new_pc;
    
    wire[`RegBus] latest_epc;
    
    wire rom_ce;
    
    wire[31:0] ram_addr_output;
    wire ram_we_output;
    wire[3:0] ram_sel_output;
    wire[`RegBus] ram_data_output;
    wire[`RegBus] ram_data_input;
    
    assign debug_pc_output = pc[15:2];
    //assign debug_data_output = mmu_data_addr[7:0];
    
    IF_PC_Reg if_pc_reg0(
            .clk(clk),
            .rst(rst),
            .bubble_notice(bubble),
            .branch_flag(id_branch_flag_output),
            .branch_target_address_input(branch_target_addr),
            .flush_flag(flush),
            .new_PC_address(new_pc),
            .PC_output(pc),
            .chip_enable_flag(rom_ce_output)
                
    );
    IF2ID if2id0(
            .clk(clk),
            .rst(rst),
            .bubble_notice(bubble),
            .flush_flag(flush),
            .PC_input(pc),
            .inst_input(inst_input),
            .PC_output(id_pc_input),
            .inst_output(id_inst_input)
     
        );
        
    
    ID id0(
        .rst(rst),
        .pc_input(id_pc_input),
        .inst_input(id_inst_input),

        .reg1_data_input(reg1_data),
        .reg2_data_input(reg2_data),

        .ex_wreg_input(ex_wreg_output),
        .ex_waddr_input(ex_waddr_output),
        .ex_wdata_input(ex_wdata_output),

        .mem_wreg_input(mem_wreg_output),
        .mem_waddr_input(mem_waddr_output),
        .mem_wdata_input(mem_wdata_output),

        .is_in_delayslot_input(is_in_delayslot_input),
        .ex_aluop_input(ex_aluop_output),
        
        .reg1_read_output(reg1_read),
        .reg2_read_output(reg2_read),       

        .reg1_addr_output(reg1_addr),
        .reg2_addr_output(reg2_addr), 
      
        .aluop_output(id_aluop_output),
        .alusel_output(id_alusel_output),
        .reg1_output(id_reg1_output),
        .reg2_output(id_reg2_output),
        .waddr_output(id_waddr_output),
        .wreg_output(id_wreg_output),


        .next_inst_in_delayslot_output(next_inst_in_delayslot_output),    
        .branch_flag_output(id_branch_flag_output),
        .branch_target_addr_output(branch_target_addr),       
        .link_addr_output(id_link_addr_output),
        .is_in_delayslot_output(id_is_in_delayslot_output),

        .inst_output(id_inst_output),
        .bubble_require(bubblereq_from_id),

        .current_inst_addr_output(id_current_inst_addr_output)
    );
    
        
    Reg_Dir reg_dir0(
        .clk (clk),
        .rst (rst),
        .write_enable    (wb_wreg_input),
        .waddr (wb_waddr_input),
        .wdata (wb_wdata_input),
        .read_enable_1 (reg1_read),
        .raddr1 (reg1_addr),
        .rdata1 (reg1_data),
        .read_enable_2 (reg2_read),
        .raddr2 (reg2_addr),
        .rdata2 (reg2_data)
    );

    ID_EX id_ex0(
        .clk(clk),
        .rst(rst),

        .bubble_notice(bubble),
        .flush_flag(flush),
        
        .id_aluop(id_aluop_output),
        .id_alusel(id_alusel_output),
        .id_reg1(id_reg1_output),
        .id_reg2(id_reg2_output),
        .id_wd(id_waddr_output),
        .id_wreg(id_wreg_output),
        .id_link_addr(id_link_addr_output),
        .id_is_in_delayslot(id_is_in_delayslot_output),
        .next_inst_in_delayslot_input(next_inst_in_delayslot_output),    
        .id_inst(id_inst_output),
        .id_current_inst_addr(id_current_inst_addr_output),

        .ex_aluop(ex_aluop_input),
        .ex_alusel(ex_alusel_input),
        .ex_reg1(ex_reg1_input),
        .ex_reg2(ex_reg2_input),
        .ex_wd(ex_waddr_input),
        .ex_wreg(ex_wreg_input),
        .ex_link_addr(ex_link_addr_input),
        .ex_is_in_delayslot(ex_is_in_delayslot_input),
        .is_in_delayslot_output(is_in_delayslot_input),    
        .ex_inst(ex_inst_input)

    );        
    
    EX ex0(
        .rst(rst),
    
        .aluop_input(ex_aluop_input),
        .alusel_input(ex_alusel_input),
        .reg1_input(ex_reg1_input),
        .reg2_input(ex_reg2_input),
        .waddr_input(ex_waddr_input),
        .wreg_input(ex_wreg_input),
        .inst_input(ex_inst_input),

        .link_addr_input(ex_link_addr_input),
        .is_in_delayslot_input(ex_is_in_delayslot_input),

        .current_inst_addr_input(ex_current_inst_addr_input),
              
        .waddr_output(ex_waddr_output),
        .wreg_output(ex_wreg_output),
        .wdata_output(ex_wdata_output),
        .is_in_delayslot_output(ex_is_in_delayslot_output),
        .current_inst_addr_output(ex_current_inst_addr_output),

        .aluop_output(ex_aluop_output),
        .mem_addr_output(ex_mem_addr_output),
        .reg2_output(ex_reg2_output)
        
    );

    EX2MEM ex2mem0(
        .clk(clk),
        .rst(rst),

        .bubble_notice(bubble),
        .flush_flag(flush),
          
        .ex_waddr(ex_waddr_output),
        .ex_wreg(ex_wreg_output),
        .ex_wdata(ex_wdata_output),
        .ex_aluop(ex_aluop_output),
        .ex_mem_addr(ex_mem_addr_output),
        .ex_reg2(ex_reg2_output),
        .ex_is_in_delayslot(ex_is_in_delayslot_output),
        .ex_current_inst_addr(ex_current_inst_addr_output),

        .mem_waddr(mem_waddr_input),
        .mem_wreg(mem_wreg_input),
        .mem_wdata(mem_wdata_input),
        .mem_aluop(mem_aluop_input),
        .mem_mem_addr(mem_mem_addr_input),
        .mem_reg2(mem_reg2_input),
        .mem_is_in_delayslot(mem_is_in_delayslot_input),
        .mem_current_inst_addr(mem_current_inst_addr_input)    

    );

    mem mem0(
        .rst(rst),
        .waddr_input(mem_waddr_input),
        .wreg_input(mem_wreg_input),
        .wdata_input(mem_wdata_input),
        .aluop_input(mem_aluop_input),
        .mem_addr_input(mem_mem_addr_input),
        .reg2_input(mem_reg2_input),
        
        .mem_data_input(ram_data_input),    
      
        .mem_addr_output(ram_addr_output),
        .mem_we_output(ram_we_output),
        .mem_sel_output(ram_sel_output),
        .mem_data_output(ram_data_output),
        .mem_ce_output(ram_ce_output),    

        .waddr_output(mem_waddr_output),
        .wreg_output(mem_wreg_output),
        .wdata_output(mem_wdata_output)
    );

    MEM2WB mem2wb0(
        .clk(clk),
        .rst(rst),

        .bubble_flag(bubble),
        .flush_flag(flush),

        .mem_waddr(mem_waddr_output),
        .mem_wreg(mem_wreg_output),
        .mem_wdata(mem_wdata_output),
    
        .wb_waddr(wb_waddr_input),
        .wb_wreg(wb_wreg_input),
        .wb_wdata(wb_wdata_input)  
                                               
    );




    wire[31: 0] exc_vector_addr;

    ctrl ctrl0(
        .rst(rst),

        .stallreq_from_id(bubblereq_from_id),
        .stallreq_from_if(bubblereq_from_if),
        .stallreq_from_mem(bubblereq_from_mem),

        .stall(bubble),
        .flush(flush),  

        .new_pc(new_pc)

    );

    wire cpu_ram_ce_output;
    assign cpu_ram_ce_output = ram_ce_output;
    wire[`InstAddrBus] mmu_data_addr, mmu_inst_addr;
    assign mmu_data_addr = ram_addr_output;
    assign mmu_inst_addr = pc;
    wishbone_bus dwishbone_bus( 
        .clk(clk),
        .rst(rst),
    
        .stall_input(bubble),
        .flush_input(flush),

    
        .cpu_ce_input(cpu_ram_ce_output),
        .cpu_data_input(ram_data_output),
        .cpu_addr_input(mmu_data_addr),
        .cpu_we_input(ram_we_output),
        .cpu_sel_input(ram_sel_output),
        .cpu_data_output(ram_data_input),
    
        .wishbone_data_input(dwishbone_data_input),
        .wishbone_ack_input(dwishbone_ack_input),
        .wishbone_addr_output(dwishbone_addr_output),
        .wishbone_data_output(dwishbone_data_output),
        .wishbone_we_output(dwishbone_we_output),
        .wishbone_sel_output(dwishbone_sel_output),
        .wishbone_stb_output(dwishbone_stb_output),
        .wishbone_cyc_output(dwishbone_cyc_output),

        .stallreq(bubblereq_from_mem)           
    
    );

    assign rom_ce = rom_ce_output;

    wishbone_bus iwishbone_bus( // instruction bus
        .clk(clk),
        .rst(rst),
    
        .stall_input(bubble),
        .flush_input(flush),
    
        .cpu_ce_input(rom_ce),
        .cpu_data_input(32'h00000000),
        .cpu_addr_input(mmu_inst_addr),
        .cpu_we_input(1'b0),
        .cpu_sel_input(4'b1111),
        .cpu_data_output(inst_input),
    
        .wishbone_data_input(iwishbone_data_input),
        .wishbone_ack_input(iwishbone_ack_input),
        .wishbone_addr_output(iwishbone_addr_output),
        .wishbone_data_output(iwishbone_data_output),
        .wishbone_we_output(iwishbone_we_output),
        .wishbone_sel_output(iwishbone_sel_output),
        .wishbone_stb_output(iwishbone_stb_output),
        .wishbone_cyc_output(iwishbone_cyc_output),

        .stallreq(bubblereq_from_if)           
    
    );

endmodule
