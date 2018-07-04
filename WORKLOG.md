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

If undefined reference to *thumips_flash_init*, add *thumips_flash.o* to Makefile.objs, line 244:

    hw-obj-$(CONFIG_PIIX4) += piix4.o thumips_flash.o

AND THIS ISSUE IS NOT SOLVED. FINDING SOLUTIONS...

If *error: field ‘info’ has incomplete type*, replace *struct siginfo* with *siginfo_t* in linux-user/signal.c, line 3247, 3466, 3468.
