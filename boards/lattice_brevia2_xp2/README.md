## Lattice XP2 Brevia 2 board

The Lattice Brevia 2 board is a small development board for the Lattice XP2 
family of FPGAs. It has a Lattice LFXP2-5E-6 chip in a QFP 144-pin package and
also includes the following peripherals:
* An 1MBit SRAM - IDT71V124SA1
* 2MBit SPI flash - SST25VF020
* FT2232 for for FPGA programming/debugging and serial-to-USB on the second channel
* 8 LEDs
* 4 push-buttons and 4 microswitches
* a 50MHz oscillator 
* Pin headers for all IOs

The DarkRISCV/darksoc builds out-of-the box using Lattice Diamond command-line,
taking about ~60% of the on-chip LUTs for the SoC demo.

Notes:
* No effort has been made to optimize resource utilization
* There seems to be an issue (race condition of sorts?) with the interaction 
  UART/Timer/Threading. The sympthoms are either the simulation outputing '01'
  or nothing at all, the actual board doing the same, the actual board not 
  being able to display board information (model, clock speed, etc) or the 
  timer not working (i.e. board stalled after 'reboot'). The easiest 
  work-around seems to be to remote the two ```putchar('0'+tmp);``` calls 
  inside src/boot.c. Again, this is only a work-around and the problem could
  manifest at any point.
 
