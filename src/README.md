## Software

This directory provides support for DarkRISCV software.

The software is 100% written in C language, is compiled by the GCC and lots
of support files (elf, assembler, maps, etc) are produced in order to help
debug and/or study the RISCV architecture.

# Tips and Tricks

As long the FPGA has few BRAMs available, we need write the software
thinking about preserve memory space. However, sometimes the code does not
help us... anyway, is possible check the memory space used by each function
in the firmware with the following script:

    awk '{ 
            if($0~/>:/) PTR=$2
            else 
            if($0~/:/) DB[PTR]++ 
          } END { 
            for(i in DB) print DB[i],i 
          }' src/darksocv.lst | sort -nr

The script will calculate how many instructions each funcion needs and will
print and sort it, producing something like this:

    456 <main>:
    149 <putdx>:
    95 <printf>:
    62 <strtok>:
    62 <gets>:
    59 <banner>:
    47 <board_name>:
    42 <irq_handler>:
    ...

So, with those information, is possible try optimize better the large
funcions.

TODO: 

- add a gdb-stub in order to support UART debug
- add a SREC decoder in order to support application upload via UART
- split the "stdio" in other files
- add more libc features and optimize the existing features

