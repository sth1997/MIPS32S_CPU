# Worklog

Write everything that blocked or delayed your work here to prevent others (teammates, followers, etc.) from stucking on the same place.

#### QEMU-THUMIPS Setup

    git clone git@github.com:chyh1990/qemu-thumips.git
    cd qemu-thumips
    ./configure --python=python2
    make

If docs are not able to be built, add *--disable-docs* to configure.
    
If *timer_gettime()* link errror, add *-lz -lrt* to Makefile.target, line 37:

    LIBS+=-lz -lrt -lm

If *error: field ‘info’ has incomplete type*, replace *struct siginfo* with *siginfo_t* in linux-user/signal.c, line 3247, 3466, 3468.

After the make FAILED, execute the following command:

    cd mipsel-softmmu
    make

And you will get *qemu-system-mipsel* here. (I don't know whether it is runnable.)

#### UCORE-THUMIPS Setup

Better to keep the git repo next to the *qemu-thumips* repo.

Here I finally give up compiling gcc, and turned to auto-install.

    sudo apt-get install linux-libc-dev-mips-cross libc6-mips-cross libc6-dev-mips-cross binutils-mips-linux-gnu gcc-mips-linux-gnu g++-mips-linux-gnu

After that, we use mips-linux-gnu-XXX, while the origin author of ucore-thumips used mips-sde-elf-XXX, so we replace the following lines:

thumips-cc, line 4:

    GCC_PREFIX="mips-linux-gnu-"

disasm.py, line 9:

    OBJDUMP='mips-linux-gnu-objdump'

Makefile.gcc, line 8:

    GCCPREFIX:=mips-linux-gnu-
    # And make sure to remove the next line

check-delay-slot.py, line 12:
    
    OBJDUMP='mips-linux-gnu-objdump'

Makefile, line 9:

    GCCPREFIX := mips-linux-gnu-

And if you want to use other versions of mips gcc/as/objdump/etc, replace the previous lines with the prefix of your library.

Finally, change *run* with the correct location of *qemu-system-mipsel*, as for mine, it's

    ../qemu-thumips/mipsel-softmmu/qemu-system-mipsel -M mipssim -m 32M -serial stdio -bios boot/loader.bin

Then the ucore will be able to compile. However, several ops are not supported in our default thumips-insn.txt, so we add them:

    MULT 000000sssssttttt0000000000011000

Apply this patch will remove a warning:

    https://git.qemu.org/?p=qemu.git;a=commitdiff;h=98cf48f60aa4999f5b2808569a193a401a390e6a
