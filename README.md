# darkriscv
opensouce RISC-V implemented from scratch in one night!

developed in one single night (somewhere between 2am and 8am), the
*darkriscv* is a very, very experimental implementation of the risc-v instruction set.
the concept is based in my other early risc processors, all they usually
composed by few hundred lines of code.

although the code is really smaller, this small code have the following 
impressive features:

- implements most of the RISC-V RV32I instructions
- works at 80MHz and can peaks up to 1 instruction/clock
- uses only 2 blockrams (one for instruction, one for data)
- uses only 1118 LUTs

since the ultra-low-cost xilinx spartan-6 family of FPGAs is my target, the project 
is based in the xilinx ise 14.4 for linux. however, no explicit references for xilinx
elements are done and all logic is inferred directly in verilog, which means
that the project is easily portable to any other FPGA.

feel free to make suggestions and good hacking!
marcelo
