##Dhrystone 2.1

the result "maches" the expected for DarkRISCV@100MHz w/ 3-stage pipeline:

    - gcc -O3: 22652 bytes 66DMIPS 11% more mem,   0% more speed (relative to -O2)
    - gcc -O2: 20244 bytes 66DMIPS  9% more mem, 100% more speed (relative to -Os)
    - gcc -Os: 18416 bytes 33DMIPS

on DarkRISCV@66MHz 2-stage pipeline:

    - gcc -O2: 50DMIPS (aka 75DMIPS@100MHz)
