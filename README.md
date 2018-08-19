# DarkRISCV
Opensouce RISC-V implemented from scratch in one night!

Developed in one single night (somewhere between 2am and 8am), the
*darkriscv* is a very, very experimental implementation of the risc-v instruction set.
The concept is based in my other early RISC processors and all they usually
composed by few hundred lines of code.

However, although the code is small when compared with other RISC-V implementations, this 
small code have lots of impressive features:

- implements most of the RISC-V RV32I instructions
- works up to 80MHz and can peaks 1 instruction/clock most of time!
- uses only 2 blockRAMs (one for instruction, one for data)
- uses only 1118 LUTs (Spartan-6 LUTs)

Since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the project 
is based in the Xilinx ISE 14.4 for Linux. However, no explicit references for Xilinx
elements are done and all logic is inferred directly from Verilog, which means
that the project is easily portable to any other FPGA families.

Feel free to make suggestions and good hacking! o/

Marcelo
