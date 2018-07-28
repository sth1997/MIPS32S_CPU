.globl  _Alloc, _ReadLine, _ReadInteger, _PrintInt, _PrintString, _PrintBool, _Halt, _LIB_Div, _LIB_Rem

_Alloc:
lw $a0, 4($sp)
j myAlloc

_ReadLine:
j myReadLine

_ReadInteger:
j myReadInteger

_PrintInt:
lw $a0, 4($sp)
j myPrintInt

_PrintString:
lw $a0, 4($sp)
j myPrintString

_PrintBool:
lw $a0, 4($sp)
j myPrintBool

_Halt:
j myHalt

_LIB_Div:
lw $a0, 4($sp)
lw $a1, 8($sp)
j myDiv

_LIB_Rem:
lw $a0, 4($sp)
lw $a1, 8($sp)
j myRem
