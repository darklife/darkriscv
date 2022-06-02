## CoreMark on DarkRISCV

### config example:
**Because coremark is relatively large, it is nearly 30KB (`src/coremark/coremark.o`) after compiling with -O2 optimization level. Therefore, the following modifications need to be made before making.**
``` verilog
// rtl/config.vh
`ifdef __HARVARD__
    `define MLEN 14 // MEM[13:0] -> 16KBytes LENGTH = 0x4000
`else
    `define MLEN 15 // MEM[14:0] -> 32KBytes LENGTH = 0x8000
`endif
```

### make
``` shell
make <install> <CROSS=riscv32-unknown-elf CCPATH=/opt/riscv32-gcc/bin ARCH=rv32e APPLICATION=coremark HARVARD=1>
```

### running
**board:scarab_minispartan6-plus_lx9 100MHz**
##### GCC -O1:
```
boot0: text@0+13512 data@16384+2732 stack@32768 (13652 bytes free)
board: scarab minispartan6-plus lx9 (id=13)             
build: Tue, 31 May 2022 10:46:38 +0800 for rv32e        
core0: darkriscv@100MHz with: rv32e 
uart0: 115200 bps (div=868)
timr0: frequency=1000000Hz (io.timer=99)


CoreMark start in 24029 us.
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 52034539
Total time (secs): 52
Iterations/Sec   : 76
Iterations       : 4000
Compiler version : GCC11.1.0
Compiler flags   : -O1 -DPERFORMANCE_RUN=1
Memory location  : STACK
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x65c5
Correct operation validated. See README.md for run and reporting rules.
CoreMark finish in 52102812 us.

```
##### GCC -O2
```
CoreMark start in 24020 us.
boot0: text@0+15848 data@16384+2700 stack@32768 (13684 bytes free)
board: scarab minispartan6-plus lx9 (id=13)
build: Mon, 30 May 2022 22:35:55 +0800 for rv32e
core0: darkriscv@100MHz with: rv32e 
uart0: 115200 bps (div=868)
timr0: frequency=1000000Hz (io.timer=99)


CoreMark start in 24020 us.
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 44265590
Total time (secs): 44
Iterations/Sec   : 90
Iterations       : 4000
Compiler version : GCC11.1.0
Compiler flags   : -O2 -DPERFORMANCE_RUN=1
Memory location  : STACK
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x65c5
Correct operation validated. See README.md for run and reporting rules.
CoreMark finish in 44333828 us.

```

### coremark/MHz
[How to calculate the coremark score i.e. coremark/MHz ?](https://github.com/eembc/coremark/issues/41)

coremark code from [coremark@b24e397](https://github.com/eembc/coremark/tree/b24e397f7103061b3673261d292a0667bd3bc1b8).