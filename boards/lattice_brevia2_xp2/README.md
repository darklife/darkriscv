# Lattice XP2 Brevia 2 board

## General information
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

## Instructions
Building and running the board has been tested on Linux only. You'll need the
following software intalled on your system:
- GNU make; Icarus Verilog; gtkwave if you want to examine the simulation output
- Lattice Diamond installed and properly licensed. 

Once you have the above, edit the top-level Makefile and set
```
BOARD  = lattice_brevia2_xp2
```
While there, also make sure to correctly set the paths to your other tools, eg.
CROSS, CCPATH, ICARUS

Next check *boards/lattice_brevia2_xp2/darksocv.mk* and make sure that 
DIAMOND_PATH matches your environment.

Finally, execute "make" in the top-level directory. First the Icarus simulation
is executed and you should be greeted with the familiar logo. After that, the
Lattice-specific build commences and if everything goes well, after a few pages
of output, you should see 
```
Saving bit stream in "darksocv_impl1.jed".
Total CPU Time: 3 secs
Total REAL Time: 3 secs
Peak Memory Usage: 1010572 MB
cp lattice_brevia2_xp2/impl1/darksocv_impl1.jed ../tmp/darksocv.bit
echo build ok.
build ok.
```

Program the board with the output JEDEC file (boards/lattice_brevia2_xp2/impl1/darksocv_impl1.jed)
file, using either the GUI Lattice Programmer or the command-line prgrcmd utility
```
LD_LIBRARY_PATH="/usr/local/diamond/3.11_x64/bin/lin64/:/usr/local/diamond/3.11_x64/ispfpga/bin/lin64/"
/usr/local/diamond/3.11_x64/bin/lin64/pgrcmd -infile lattice_brevia2_xp2.xcf
```

Connect a terminal emulator to the on-boards FT2232 second channel, for example:
```
cu -l /dev/ttyUSB1 -s 115200
```
Reset the board and enjoy!


 

Notes:
* No effort has been made to optimize resource utilization
* There are quite a lot of warnings during the build. No effort has been made
  to clear (or even understand) them. There are probably bugs hiding there 
  as well.
* The default 50MHz oscillator is used as the core clock. Using a PLL, the core
  could probably go faster, but this is outside the scope of the current work.
* There seems to be an issue (race condition of sorts?) with the interaction 
  UART/Timer/Threading. The sympthoms are either the simulation outputing '01'
  or nothing at all, the actual board doing the same, the actual board not 
  being able to display board information (model, clock speed, etc) or the 
  timer not working (i.e. board stalled after 'reboot'). The easiest 
  work-around seems to be to remote the two ```putchar('0'+tmp);``` calls 
  inside src/boot.c. Again, this is only a work-around and the problem could
  manifest at any point.
 
