# Worklog

Write everything that blocked or delayed your work here to prevent others (teammates, followers, etc.) from stucking on the same place.

#### QEMU-THUMIPS Setup

    git clone git@github.com:chyh1990/qemu-thumips.git
    cd qemu-thumips
    ./configure --python=python2
    make

If docs are not able to be built, add *--disable-docs* to configure.
    
PROBLEM: *timer_gettime()* LINK ERROR (UNDEFINED REFERENCE).
