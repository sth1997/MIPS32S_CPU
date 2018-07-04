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
