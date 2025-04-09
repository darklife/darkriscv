# "primes" benchmark

The "primes" from Bruce Holt is a small benchmark with a huge index of
different machines and processor there.  In order to make the different
implementations comparable, the main rule is that the code must be compiled
w/ -O1, so it will not be much optimized.

In the case of DarkRISCV, we have a small problem regarding the mul/div,
since we have an RV32E without M extension and the mul/div is done via
library (darklibc). So, when all code is compiled w/ -O1, we get the value
of 728 seconds to run the benchmark, verus 715 seconds when the darklibc is
compiled with -O2, all cases running the base system at 100MHz.

In order to compile w/ mixed optimization, you need edit the config.mk,
set to -O2, compile the darklibc, edit again, set to -O1 and compile the
primes... the uppper directory will link then, regardless the setup.

Finally, testing it w/ the MAC instruction, apart from making the critical
path worse, there are no improvement on the performance: 618s.

Checking the current ranking of small processors:

```
//    50.241 sec PowerPC 750CL Wii 729 MHz             332 bytes  36.6 billion clocks
//   112.163 sec HiFive1 RISCV E31 @ 320 MHz           178 bytes  35.9 billion clocks
//   176.2   sec Renesas RX71M RXv2 @ 240 MHz          184 bytes  42.3 billion clocks
//   210.230 sec PS2 MIPS III R5900 @ 295 MHz          400 bytes  62.0 billion clocks
//   261.068 sec esp32/Arduino @ 240 MHz               ??? bytes  62.7 billion clocks
//   294.749 sec chipKIT Pro MZ pic32 @ 200 MHz        ??? bytes  58.9 billion clocks
//   306.988 sec esp8266 @ 160 MHz                     ??? bytes  49.1 billion clocks
//   309.251 sec BlackPill Cortex M4F @ 168 MHz        228 bytes  52.0 billion clocks
//   319.155 sec WCH32V307 @ 144 MHz                   202 bytes  46.0 billion clocks
//   337.962 sec VexRiscv "full" RV32IM 200 MHz        236 bytes  67.6 billion clocks
//   920.858 sec kianvSoc Artix7 FPGA @ 90 MHz         272 bytes  82.9 billion clocks
//   927.547 sec BluePill Cortex M3 @ 72 MHz           228 bytes  66.8 billion clocks
// 13449.513 sec AVR ATmega2560 @ 20 MHz               318 bytes 269.0 billion clocks
```


The DarkRISCV@100MHz w/ 712s result will be between the VexRISCV@200MHz and
kianRiscv@90MHz. Note that, when we scale down the VexRISCV to 100MHz it
will probably reach 675s, which is 9% faster than DarkRISCV, but keep in
mind we are comparing a 5-stage RV32IM vs. a 3-stage RV32E.

In the opposite side, overclocking the DarkRISCV to 400MHz on the fastest
device tested until now, the UK040, it would be 4x faster, resulting in only
178s, which may keep it by a small margin below the Renesas RX71M but ahead
of the PS2 processor, the MIPS R5900.

With the MAC instruction, the DarkRISCV can outperform the VexRISCV when
running at the same clock and, running with 400MHz overclock, it would
outperform the Renesas RX71M.
