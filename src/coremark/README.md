## CoreMark on DarkRISCV

### config example:
``` verilog
rtl/config.vh
    `ifdef __HARVARD__
    `define MLEN 14 // MEM[12:0] ->  8KBytes
        `else
    `define MLEN 15 // MEM[13:0] -> 16KBytes
        `endif
```

### make
``` shell
make <CROSS=riscv32-unknown-elf CCPATH=/opt/riscv32-gcc/bin ARCH=rv32i APPLICATION=coremark HARVARD=1>
```

### running
**board:scarab_minispartan6-plus_lx9 100MHz**
##### GCC -O1:
```
boot0: text@0+13236 data@16384+2532 stack@32768 (13852 bytes free)
CoreMark start in 5998 us
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 52628658
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
CoreMark finish in 52678659 us

```
##### GCC -O2
```
boot0: text@0+15304 data@16384+2500 stack@32768 (13884 bytes free)
CoreMark start in 5991 us
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 44241484
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
CoreMark finish in 44291442 us

```
coremark code from [coremark@b24e397](https://github.com/eembc/coremark/tree/b24e397f7103061b3673261d292a0667bd3bc1b8)