## Software

This directory provides support for DarkRISCV software.

The software is 100% written in C language, is compiled by the GCC and lots
of support files (elf, assembler, maps, etc) are produced in order to help
debug and/or study the RISCV architecture.

TODO: 

- add a gdb-stub in order to support UART debug
- add a SREC decoder in order to support application upload via UART
- split the "stdio" in other files
- add more libc features and optimize the existing features

