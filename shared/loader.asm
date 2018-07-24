
loader:     file format elf32-tradlittlemips


Disassembly of section .text:

bfc00000 <__start>:
bfc00000:	00000000 	nop
bfc00004:	10000001 	b	bfc0000c <load_elf>
bfc00008:	00000000 	nop

bfc0000c <load_elf>:
bfc0000c:	3c08beff 	lui	t0,0xbeff
bfc00010:	3508fff8 	ori	t0,t0,0xfff8
bfc00014:	240900ff 	li	t1,255
bfc00018:	ad090000 	sw	t1,0(t0)
bfc0001c:	3c10be00 	lui	s0,0xbe00
bfc00020:	240f0000 	li	t7,0
bfc00024:	020f7821 	addu	t7,s0,t7
bfc00028:	8de90000 	lw	t1,0(t7)
bfc0002c:	8def0004 	lw	t7,4(t7)
bfc00030:	000f7c00 	sll	t7,t7,0x10
bfc00034:	012f4825 	or	t1,t1,t7
bfc00038:	3c08464c 	lui	t0,0x464c
bfc0003c:	3508457f 	ori	t0,t0,0x457f
bfc00040:	11090003 	beq	t0,t1,bfc00050 <load_elf+0x44>
bfc00044:	00000000 	nop
bfc00048:	10000042 	b	bfc00154 <bad>
bfc0004c:	00000000 	nop
bfc00050:	240f0038 	li	t7,56
bfc00054:	020f7821 	addu	t7,s0,t7
bfc00058:	8df10000 	lw	s1,0(t7)
bfc0005c:	8def0004 	lw	t7,4(t7)
bfc00060:	000f7c00 	sll	t7,t7,0x10
bfc00064:	022f8825 	or	s1,s1,t7
bfc00068:	240f0058 	li	t7,88
bfc0006c:	020f7821 	addu	t7,s0,t7
bfc00070:	8df20000 	lw	s2,0(t7)
bfc00074:	8def0004 	lw	t7,4(t7)
bfc00078:	000f7c00 	sll	t7,t7,0x10
bfc0007c:	024f9025 	or	s2,s2,t7
bfc00080:	3252ffff 	andi	s2,s2,0xffff
bfc00084:	240f0030 	li	t7,48
bfc00088:	020f7821 	addu	t7,s0,t7
bfc0008c:	8df30000 	lw	s3,0(t7)
bfc00090:	8def0004 	lw	t7,4(t7)
bfc00094:	000f7c00 	sll	t7,t7,0x10
bfc00098:	026f9825 	or	s3,s3,t7

bfc0009c <next_sec>:
bfc0009c:	262f0008 	addiu	t7,s1,8
bfc000a0:	000f7840 	sll	t7,t7,0x1
bfc000a4:	020f7821 	addu	t7,s0,t7
bfc000a8:	8df40000 	lw	s4,0(t7)
bfc000ac:	8def0004 	lw	t7,4(t7)
bfc000b0:	000f7c00 	sll	t7,t7,0x10
bfc000b4:	028fa025 	or	s4,s4,t7
bfc000b8:	262f0010 	addiu	t7,s1,16
bfc000bc:	000f7840 	sll	t7,t7,0x1
bfc000c0:	020f7821 	addu	t7,s0,t7
bfc000c4:	8df50000 	lw	s5,0(t7)
bfc000c8:	8def0004 	lw	t7,4(t7)
bfc000cc:	000f7c00 	sll	t7,t7,0x10
bfc000d0:	02afa825 	or	s5,s5,t7
bfc000d4:	262f0004 	addiu	t7,s1,4
bfc000d8:	000f7840 	sll	t7,t7,0x1
bfc000dc:	020f7821 	addu	t7,s0,t7
bfc000e0:	8df60000 	lw	s6,0(t7)
bfc000e4:	8def0004 	lw	t7,4(t7)
bfc000e8:	000f7c00 	sll	t7,t7,0x10
bfc000ec:	02cfb025 	or	s6,s6,t7
bfc000f0:	12800010 	beqz	s4,bfc00134 <copy_sec+0x34>
bfc000f4:	00000000 	nop
bfc000f8:	12a0000e 	beqz	s5,bfc00134 <copy_sec+0x34>
bfc000fc:	00000000 	nop

bfc00100 <copy_sec>:
bfc00100:	26cf0000 	addiu	t7,s6,0
bfc00104:	000f7840 	sll	t7,t7,0x1
bfc00108:	020f7821 	addu	t7,s0,t7
bfc0010c:	8de80000 	lw	t0,0(t7)
bfc00110:	8def0004 	lw	t7,4(t7)
bfc00114:	000f7c00 	sll	t7,t7,0x10
bfc00118:	010f4025 	or	t0,t0,t7
bfc0011c:	ae880000 	sw	t0,0(s4)
bfc00120:	26d60004 	addiu	s6,s6,4
bfc00124:	26940004 	addiu	s4,s4,4
bfc00128:	26b5fffc 	addiu	s5,s5,-4
bfc0012c:	1ea0fff4 	bgtz	s5,bfc00100 <copy_sec>
bfc00130:	00000000 	nop
bfc00134:	26310020 	addiu	s1,s1,32
bfc00138:	2652ffff 	addiu	s2,s2,-1
bfc0013c:	1e40ffd7 	bgtz	s2,bfc0009c <next_sec>
bfc00140:	00000000 	nop

bfc00144 <done>:
bfc00144:	02600008 	jr	s3
bfc00148:	00000000 	nop
bfc0014c:	1000ffff 	b	bfc0014c <done+0x8>
bfc00150:	00000000 	nop

bfc00154 <bad>:
bfc00154:	1000ffff 	b	bfc00154 <bad>
bfc00158:	00000000 	nop

Disassembly of section .reginfo:

00400054 <.reginfo>:
  400054:	007f8300 	0x7f8300
	...
  400068:	bfc18150 	cache	0x1,-32432(s8)

Disassembly of section .debug_aranges:

00000000 <_fdata-0xbfc1015c>:
   0:	0000001c 	0x1c
   4:	00000002 	srl	zero,zero,0x0
   8:	00040000 	sll	zero,a0,0x0
   c:	00000000 	nop
  10:	bfc00000 	cache	0x0,0(s8)
  14:	0000015c 	0x15c
	...

Disassembly of section .debug_info:

00000000 <.debug_info>:
   0:	00000056 	0x56
   4:	00000002 	srl	zero,zero,0x0
   8:	01040000 	0x1040000
   c:	00000000 	nop
  10:	bfc00000 	cache	0x0,0(s8)
  14:	bfc0015c 	cache	0x0,348(s8)
  18:	746f6f62 	jalx	1bdbd88 <__start-0xbe024278>
  1c:	6f6f622f 	0x6f6f622f
  20:	6d736174 	0x6d736174
  24:	2f00532e 	sltiu	zero,t8,21294
  28:	656d6f68 	0x656d6f68
  2c:	636f682f 	0x636f682f
  30:	2f79656b 	sltiu	t9,k1,25963
  34:	2f746967 	sltiu	s4,k1,26983
  38:	5350494d 	beql	k0,s0,12570 <__start-0xbfbeda90>
  3c:	5f533233 	0x5f533233
  40:	2f555043 	sltiu	s5,k0,20547
  44:	3862616c 	xori	v0,v1,0x616c
  48:	554e4700 	bnel	t2,t6,11c4c <__start-0xbfbee3b4>
  4c:	20534120 	addi	s3,v0,16672
  50:	33322e32 	andi	s2,t9,0x2e32
  54:	0032352e 	0x32352e
  58:	Address 0x0000000000000058 is out of bounds.


Disassembly of section .debug_abbrev:

00000000 <.debug_abbrev>:
   0:	10001101 	b	4408 <__start-0xbfbfbbf8>
   4:	12011106 	beq	s0,at,4420 <__start-0xbfbfbbe0>
   8:	1b080301 	0x1b080301
   c:	13082508 	beq	t8,t0,9430 <__start-0xbfbf6bd0>
  10:	00000005 	0x5

Disassembly of section .debug_line:

00000000 <.debug_line>:
   0:	0000006a 	0x6a
   4:	00250002 	ror	zero,a1,0x0
   8:	01010000 	0x1010000
   c:	000d0efb 	0xd0efb
  10:	01010101 	0x1010101
  14:	01000000 	0x1000000
  18:	62010000 	0x62010000
  1c:	00746f6f 	0x746f6f
  20:	6f6f6200 	0x6f6f6200
  24:	6d736174 	0x6d736174
  28:	0100532e 	0x100532e
  2c:	00000000 	nop
  30:	00000205 	0x205
  34:	2403bfc0 	li	v1,-16448
  38:	4e4b4b01 	c3	0x4b4b01
  3c:	4c4d4b83 	0x4c4d4b83
  40:	4b837508 	c2	0x1837508
  44:	084d4b4b 	j	1352d2c <__start-0xbe8ad2d4>
  48:	4d750876 	nmadd.ps	$f1,$f11,$f1,$f21
  4c:	ae087908 	sw	t0,30984(s0)
  50:	ae08ae08 	sw	t0,-20984(s0)
  54:	4e4b4b4b 	c3	0x4b4b4b
  58:	4b4bad08 	c2	0x14bad08
  5c:	4d4b4b4b 	0x4d4b4b4b
  60:	4e4b4b4b 	c3	0x4b4b4b
  64:	4d4b4b4b 	0x4d4b4b4b
  68:	0004024b 	0x4024b
  6c:	Address 0x000000000000006c is out of bounds.

