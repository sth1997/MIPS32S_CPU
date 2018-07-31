# LAB8 to MIPS

#### boot

boot/bootasm.S: Rewrite in MIPS

#### kern

debug/: Replace cprintf with kprintf
driver/: Completely rewrite with respect to mipsregs.h and thumips.h
fs/: Replace ROUNDDOWN macro with ROUNDDOWN\_2N, and define SHIFT together with SIZE
include/: Remove complex support.
init/: Rewrite entry.S with MIPS, simplify init.c (using tlb\_invalidate\_all())
libs/: Used MIPS library.
mm/: Use thumips\_tlb, changed memlayout.h due to hardware. 
proc/: Rewrite entry.S with MIPS, rewrite switch.S for the new trapframe, modify proc.c for trapframe.
schedule/: Fallback to naive sched.
sync/: Removed monitor and check for LAB7
syscall/: Modify registers.
trap/: Setup new vectors.S, rewrite exception.S and replace the old trapentry.S. Use new mips\_trapframe.

#### user

libs/: Add intrinsic.c & entry.S for decaf support.


