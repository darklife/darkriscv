## SCARAB miniSpartan6-plus LX9

[miniSpartan6-plus on github](https://github.com/scarabhardware/miniSpartan6-plus)
* The Spartan6 LX9 FPGA from Xilinx , one of the best FPGAs on the market.
* An on-board USB JTAG Programmer to power and program your FPGA with any open source programmer, like the one inside our own Scarab IDE .  
* An on board USB interface that powers the board and allows communication with the PC at speeds up to 480Mbps . (That's fast enough to make a logic analyzer. * Check our website for updates on projects and tutorials).
* An on-board HDMI port . Instead of using VGA output on your projects, now you can go HDMI.
* An 8-channel analog to digital converter running at 1 MSPS with 8 bit resolution. So you can start connecting real world sensors to your FPGA kit.
* Memory: 32MB of SDRAM, 64Mbit of SPI Flash and a microSD card interface .
* A stereo audio output jack using 1-bit sigma-delta DAC to start playing your music.
* 24 Digital I/O pins .
* 8 LEDs.
-------

## Pins Config:
The UART is connected to Port2 of FT2232.
Generally, It is recognized as **ttyUSB1** in Linux.
You can directly use USB to complete the test of UART and other function without a separate hardware module.

## Build && Install:
### Check and Config your Toolchain Path:
``` Makefile
# src/Makefile
CROSS = riscv32-unknown-elf
CCPATH = /opt/riscv32-gcc/bin
```

### Add ISE to your PATH:
``` shell
source <Your ISE Installation Directory>/settings64.sh
```

### Top Makefile:
 	ICARUS and ISE may conflict in $PATH, So when generating bitstream file, compile src without Icarus.
``` Makefile
install:
	make -C src all #Add This Line
	make -C boards install
```

### Build:
``` shell
make install BOARD=scarab_minispartan6-plus_lx9 <CROSS=riscv32-unknown-elf CCPATH=/opt/riscv/bin/ ARCH=rv32i/e HARVARD=1>
```

### Download Bitstream:
You can use [xc3slog](http://xc3sprog.sourceforge.net/) to load and run or download bitstream files to FLASH.

You can also use the graphical tool [miniSProg](https://github.com/vgegok/miniSProg) to easily download bitstream files.

## Test
```
              vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
                  vvvvvvvvvvvvvvvvvvvvvvvvvvvv
rrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvvvvvv
rrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvvvv
rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv
rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv
rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv
rrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvv  
rrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvv    
rr                vvvvvvvvvvvvvvvvvvvvvv      
rr            vvvvvvvvvvvvvvvvvvvvvvvv      rr
rrrr      vvvvvvvvvvvvvvvvvvvvvvvvvv      rrrr
rrrrrr      vvvvvvvvvvvvvvvvvvvvvv      rrrrrr
rrrrrrrr      vvvvvvvvvvvvvvvvvv      rrrrrrrr
rrrrrrrrrr      vvvvvvvvvvvvvv      rrrrrrrrrr
rrrrrrrrrrrr      vvvvvvvvvv      rrrrrrrrrrrr
rrrrrrrrrrrrrr      vvvvvv      rrrrrrrrrrrrrr
rrrrrrrrrrrrrrrr      vv      rrrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrr          rrrrrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrr      rrrrrrrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrr  rrrrrrrrrrrrrrrrrrrrrr

       INSTRUCTION SETS WANT TO BE FREE

boot0: text@0 data@7500 stack@8192 (692 bytes free)
board: scarab minispartan6-plus lx9 (id=13)
build: Fri, 22 Apr 2022 18:20:35 +0800 for rv32i
core0/thread0: darkriscv@100.0MHz rv32i+MAC
uart0: 115200 bps (div=868)
timr0: frequency=1000000Hz (io.timer=99)
mtvec: handler@240, enabling interrupts...
mtvec: interrupts enabled!

Welcome to DarkRISCV!
> ?
command: [?] not found.
valid commands: clear, dump [hex], led [hex], timer [dec], oport [hex]
                mul [dec] [dec], div [dec] [dec], mac [dec] [dec] [dec]
                reboot, wr[m][bwl] [hex] [hex] [[hex] when m],
                rd[m][bwl] [hex] [[hex] when m]
> 
```