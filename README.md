# darkriscv
Open source RISC-V implemented from scratch in one night!

Developed in one single night (somewhere between 2am and 8am), the *darkriscv* 
is a very, very experimental implementation of the risc-v instruction set. 

The general concept is based in my other early RISC processors, composed by a 
simplified two stage pipeline where a instruction is fetch from a instruction memory
in the first clock and decoded and executed in the second clock. The pipeline is
overlaped without interlock most of time, in a way the *darkriscv* can reach the
performance of one instruction per clock most of time. As adition, the code is 
very compact, with around one hundred lines of verilog code.

Although the code is small abd crude when compared with other RISC-V implementations, 
the *darkriscv* has lots of impressive features:

- implements most of the RISC-V RV32I instruction set
- works up to 80MHz and can peaks 1 instruction/clock most of time
- uses only 2 blockRAMs (one for instruction and another one for data)
- uses only 1118 LUTs

Of course, there are lots of missing features and problems, but they will be soved in future.

Finally, since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the project 
is based in the Xilinx ISE 14.4 for Linux. However, no explicit references for Xilinx
elements are done and all logic is inferred directly from Verilog, which means
that the project is easily portable to any other FPGA families.

Feel free to make suggestions and good hacking! o/

Marcelo Samsoniuk
