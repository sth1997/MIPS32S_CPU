`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 14:49:41
// Design Name: 
// Module Name: 
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

// global macro defines
`define RstEnable 			1'b1
`define RstDisable 			1'b0
`define ZeroWord 			32'h00000000
`define WriteEnable 		1'b1
`define WriteDisable 		1'b0
`define ReadEnable 			1'b1
`define ReadDisable			1'b0
`define AluOpBus 			7:0
`define AluSelBus 			2:0
`define InstValid 			1'b0 // it's confusing to set zero as instruction valid
`define InstInvalid 		1'b1
`define Stop 				1'b1
`define NoStop 				1'b0
`define InDelaySlot 		1'b1
`define NotInDelaySlot 		1'b0
`define Branch 				1'b1
`define NotBranch 			1'b0
`define InterruptAssert 	1'b1
`define InterruptNotAssert 	1'b0
`define TrapAssert 			1'b1
`define TrapNotAssert 		1'b0
`define True_v 				1'b1
`define False_v 			1'b0
`define ChipEnable 			1'b1
`define ChipDisable 		1'b0


// macro defines associated with instuctions
`define EXE_AND 		6'b100100
`define EXE_OR 			6'b100101
`define EXE_XOR			6'b100110
`define EXE_NOR			6'b100111

`define EXE_ANDI		6'b001100
`define EXE_ORI			6'b001101
`define EXE_XORI		6'b001110
`define EXE_LUI			6'b001111

`define EXE_SLL			6'b000000
`define EXE_SLLV		6'b000100
`define EXE_SRL			6'b000010
`define EXE_SRLV		6'b000110
`define EXE_SRA			6'b000011
`define EXE_SRAV		6'b000111

`define EXE_MFHI        6'b010000
`define EXE_MTHI        6'b010001
`define EXE_MFLO        6'b010010
`define EXE_MTLO        6'b010011

`define EXE_SLT  6'b101010
`define EXE_SLTU  6'b101011
`define EXE_SLTI  6'b001010
`define EXE_SLTIU  6'b001011   
`define EXE_SUBU  6'b100011
`define EXE_ADDU  6'b100001
`define EXE_ADDIU  6'b001001
`define EXE_MULT  6'b011000

`define EXE_J  6'b000010
`define EXE_JAL  6'b000011
`define EXE_JALR  6'b001001
`define EXE_JR  6'b001000
`define EXE_BEQ  6'b000100
`define EXE_BGEZ  5'b00001
`define EXE_BGTZ  6'b000111
`define EXE_BLEZ  6'b000110
`define EXE_BLTZ  5'b00000
`define EXE_BNE  6'b000101

`define EXE_LB  6'b100000
`define EXE_LBU 6'b100100
`define EXE_LHU 6'b100101
`define EXE_LW  6'b100011
`define EXE_SB  6'b101000
`define EXE_SW  6'b101011

`define EXE_SYSCALL 6'b001100
`define EXE_ERET 32'b01000010000000000000000000011000

`define EXE_TLBWI 32'b01000010000000000000000000000010
`define EXE_TLBWR 32'b01000010000000000000000000000110
`define EXE_TLBR  32'b01000010000000000000000000000001
`define EXE_TLBP  32'b01000010000000000000000000001000

`define EXE_CACHE 6'b101111
`define EXE_NOP 6'b000000	// nop = sll $0 $0 0

`define EXE_SPECIAL_INST 6'b000000
`define EXE_REGIMM_INST 6'b000001
`define EXE_SPECIAL2_INST 6'b011100

///AluOp
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100	// avoid EXE_NOP_OP 8'b00000000
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDU_OP  8'b00100001
`define EXE_ADDIU_OP  8'b01010110
`define EXE_MULT_OP  8'b00011000

`define EXE_J_OP 8'b01001111
`define EXE_JAL_OP 8'b01010000
`define EXE_JALR_OP 8'b00001001
`define EXE_JR_OP 8'b00001000
`define EXE_BEQ_OP 8'b01010001
`define EXE_BGEZ_OP 8'b01000001
`define EXE_BGTZ_OP 8'b01010100
`define EXE_BLEZ_OP 8'b01010011
`define EXE_BLTZ_OP 8'b01000000
`define EXE_BNE_OP 8'b01010010

`define EXE_LB_OP 8'b11100000
`define EXE_LBU_OP 8'b11100100
`define EXE_LHU_OP 8'b11100101
`define EXE_LW_OP 8'b11100011
`define EXE_SB_OP 8'b11101000
`define EXE_SW_OP 8'b11101011

`define EXE_MFC0_OP 8'b01011101
`define EXE_MTC0_OP 8'b01100000

`define EXE_NOP_OP 8'b00000000
`define EXE_SYSCALL_OP 8'b00001100
`define EXE_ERET_OP 8'b01101011

`define EXE_TLBWI_OP 8'b01000010
`define EXE_TLBWR_OP 8'b01000011
`define EXE_TLBR_OP  8'b01000100
`define EXE_TLBP_OP  8'b01000101

`define EXE_NOP_OP 8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_MOVE  3'b011
`define EXE_RES_ARITHMETIC 3'b100   
`define EXE_RES_MUL 3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111   

`define EXE_RES_NOP 3'b000

// macro defines associated with RAM
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNumLog2 10
`define DataMemNum (1 << `DataMemNumLog2)
`define ByteWidth 7:0

// macro defines associated with ROM
`define InstAddrBus 		31:0
`define InstBus 			31:0
`define InstMemNumLog2 	10
`define InstMemNum 		(1 << `InstMemNumLog2)	//131071


// macro defines associated with general registers
`define RegAddrBus 			4:0
`define RegBus 				31:0
`define RegWidth 			32
`define DoubleRegWidth 		64
`define DoubleRegBus 		63:0
`define RegNum 				32
`define RegNumLog2 			5
`define NOPRegAddr 			5'b00000

`define SERIAL_CLK_FREQUENCE     50000000
`define BAUD_RATE                9600

// cp0
`define CP0_REG_INDEX    5'b00000
`define CP0_REG_ENTRYLO0 5'b00010
`define CP0_REG_ENTRYLO1 5'b00011
`define CP0_REG_BADVADDR 5'b01000
`define CP0_REG_COUNT    5'b01001
`define CP0_REG_ENTRYHI  5'b01010        
`define CP0_REG_COMPARE  5'b01011      
`define CP0_REG_STATUS   5'b01100       
`define CP0_REG_CAUSE    5'b01101       
`define CP0_REG_EPC      5'b01110
`define CP0_REG_EBASE    5'b01111
`define CP0_TLBR         5'b10000
`define CP0_TLBP         5'b10001

//TLB
`define TLB_WRITE_STRUCT_WIDTH 68 // 1 + 4 + 63 
`define TLB_ENTRY_WIDTH 63
`define TLB_INDEX_WIDTH 4
`define TLB_NR_ENTRY    (1 << `TLB_INDEX_WIDTH)      
`define TLB_READ_R       1'b1
`define TLB_READ_P       1'b0
