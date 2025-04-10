// Copyright 2016-2024 Bruce Hoult bruce@hoult.org
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// Program to count primes. I wanted something that could run in 16 KB but took enough
// time to measure on a modern x86 and is not susceptible to optimizer tricks.
// Code size is for just the countPrimes() function with gcc -O.
//
// Higher opt level is not allowed, but tune or align flags may be added. I've made an
// exception for Elbrus, only because the difference is so dramatic. It is generally not
// for other CPUs.
//
// Original x86 & ARM data 2016, received user contributions 2019-2024.
//
// SZ = 1000 -> 3713160 primes, all primes up to 7919^2 = 62710561
//     1.808 sec i9-14900K @ 5.9 GHz                   276 bytes  10.7 billion clocks
//     1.990 sec i9-13900HX @ 5.4 GHz                  276 bytes  10.7 billion clocks
//     2.284 sec i7 9700K @ 4.9 GHz                    243 bytes  11.2 billion clocks
//     2.735 sec i7 8650U @ 4.2 GHz                    242 bytes  11.5 billion clocks
//     2.740 sec Apple M2 Max @ 3.4 GHz                264 bytes   9.3 billion clocks
//     2.795 sec Mac Mini M1 @ 3.4 GHz                 212 bytes   9.5 billion clocks
//     2.810 sec Mac Mini M1 arm64 Ubuntu in VM        280 bytes   9.0 billion clocks
//     2.872 sec i7 6700K @ 4.2 GHz                    240 bytes  12.1 billion clocks
//     2.925 sec Mac Mini M1 @ 3.2 GHz x86_64 Rosetta  208 bytes   9.4 billion clocks
//     3.075 sec AWS c8g Graviton4 A64 @3.0 GHz        268 bytes   9.2 billion clocks
//     3.132 sec Ryzen 4900H @ 4.4 GHz                 272 bytes  13.8 billion clocks
//     3.230 sec Threadripper 2990WX @ 4.2 GHz         276 bytes  13.8 billion clocks
//     3.448 sec Ryzen 5 4500U @ 4.0 GHz WSL2          242 bytes  13.8 billion clocks
//     3.505 sec Xeon Plat 8151 @ 4.0 GHz (AWS z1d)    244 bytes  14.0 billion clocks
//     3.725 sec AWS c7g graviton3 A64 @ 2.6 GHz       256 bytes   9.7 billion clocks
//     3.836 sec i7 4700MQ @ 3.4 GHz                   258 bytes  13.0 billion clocks
//     3.972 sec i7 8650U @ 4.2 GHz webasm             277 bytes  16.7 billion clocks
//     4.868 sec i7 3770  @ 3.9 GHz                    240 bytes  19.0 billion clocks
//     5.052 sec i9-13900HX, qemu-riscv64 @ 5.1 GHz    216 bytes  25.8 billion clocks
//     5.110 sec Blackbird POWER9 Sforza @ 3.8 GHz     380 bytes  19.4 billion clocks
//     5.331 sec Snapdragon 8 gen 2 Cortex-X2 3.0 GHz  280 bytes  16.0 billion clocks
//     6.531 sec AWS c6g graviton2 A64 @ 2.5 GHz       256 bytes  16.3 billion clocks
//     6.560 sec SPARC T7-4 4.13 GHz                   348 bytes  27.1 billion clocks
//     6.757 sec M1 Mini, qemu-riscv64 in UbuntuVM     216 bytes  23.0 billion clocks
//     6.867 sec Elbrus-8SV Raiko 1.55 GHz PGO        2664 bytes  10.6 billion clocks
//     7.700 sec SPARC T5-4 3.6 GHz                    348 bytes  27.7 billion clocks
//     8.005 sec AWS Graviton 1 a1.medium 2.26 GHz     268 bytes  18.1 billion clocks
//     8.538 sec NXP LX2160A A72 @ 2 GHz               260 bytes  17.1 billion clocks
//     8.890 sec Milk-V Megrez P550 @ 1.8 GHz          210 bytes  16.0 billion clocks
//     8.964 sec SiFive HiFive Premier P550 @1.8 GHz   210 bytes  16.1 billion clocks
//     9.622 sec Milk-V Pioneer SG2042 C910 @2.0 GHz   192 bytes  19.3 billion clocks
//     9.692 sec RISC-V Fedora in qemu in VM on M1     208 bytes  31.0 billion clocks
//     9.740 sec i7 6700K qemu-riscv32                 178 bytes  40.9 billion clocks
//    10.046 sec i7 8650U @ 4.2 GHz qemu-riscv32       190 bytes  42.2 billion clocks
//    10.430 sec Sipeed LM4A TH1520 4x C910 @1.848 GHz 216 bytes  19.3 billion clocks
//    10.851 sec Sophon SG2042 64x C910 RV64 @1.8? GHz 216 bytes  19.3 billion clocks
//    11.045 sec M1 mini qemu-x86_64 in Arm ubuntu VM  276 bytes  37.6 billion clocks  
//    11.190 sec Pi4 Cortex A72 @ 1.5 GHz T32          232 bytes  16.8 billion clocks
//    11.445 sec Odroid XU4 A15 @ 2 GHz T32            204 bytes  22.9 billion clocks
//    11.540 sec SiFive HiFive Premier P550 @1.4 GHz   216 bytes  16.1 billion clocks
//    12.115 sec Pi4 Cortex A72 @ 1.5 GHz A64          300 bytes  18.2 billion clocks
//    12.605 sec Pi4 Cortex A72 @ 1.5 GHz A32          300 bytes  18.9 billion clocks
//    13.721 sec RISC-V Fedora in qemu on 2990wx       208 bytes  57.6 billion clocks
//    14.111 sec Beagle-X15 A15 @ 1.5 GHz A32          348 bytes  21.2 billion clocks
//    14.341 sec Beagle-X15 A15 @ 1.5 GHz T32          224 bytes  21.5 billion clocks
//    14.685 sec Lichee Pi 3A SpacemiT X60 @1.6 GHz    214 bytes  23.5 billion clocks
//    14.885 sec VisionFive 2 U74 _zba_zbb @ 1.5 GHz   214 bytes  22.3 billion clocks
//    15.298 sec HiFive Unmatched RISC-V U74 @ 1.5 GHz 250 bytes  22.9 billion clocks
//    19.500 sec Odroid C2 A53 @ 1.536 GHz A64         276 bytes  30.0 billion clocks
//    20.419 sec Elbrus-8SV Raiko 1.55 GHz -O3        1120 bytes  31.7 billion clocks
//    23.940 sec Odroid C2 A53 @ 1.536 GHz T32         204 bytes  36.8 billion clocks
//    24.636 sec i7 6700K qemu-arm                     204 bytes 103.5 billion clocks
//    25.060 sec i7 6700K qemu-aarch64                 276 bytes 105.3 billion clocks
//    27.196 sec Teensy 4.0 Cortex M7 @ 960 MHz        228 bytes  26.1 billion clocks
//    27.480 sec HiFive Unleashed RISCV U54 @ 1.45 GHz 228 bytes  39.8 billion clocks
//    28.110 sec Elbrus-8SV Raiko 1.55 GHz             984 bytes  43.6 billion clocks
//    30.420 sec Pi3 Cortex A53 @ 1.2 GHz T32          204 bytes  36.5 billion clocks
//    36.652 sec Allwinner D1 C906 RV64 @ 1.008 GHz    224 bytes  36.9 billion clocks
//    39.840 sec HiFive Unl RISC-V U54 @ 1.0 GHz       228 bytes  39.8 billion clocks
//    43.048 sec Milk-V Duo C906 @ 850 MHz             204 bytes  36.6 billion clocks
//    43.516 sec Teensy 4.0 Cortex M7 @ 600 MHz        228 bytes  26.1 billion clocks
//    47.910 sec Pi2 Cortex A7 @ 900 MHz T32           204 bytes  42.1 billion clocks
//    48.206 sec Zynq-7010 Cortex A9 @ 650MHz          248 bytes  31.3 billion clocks
//    50.241 sec PowerPC 750CL Wii 729 MHz             332 bytes  36.6 billion clocks
//   112.163 sec HiFive1 RISC-V E31 @ 320 MHz          178 bytes  35.9 billion clocks
//   176.2   sec Renesas RX71M RXv2 @ 240 MHz          184 bytes  42.3 billion clocks
//   178.424 sec RP2350B RISC-V Hazard3 @ 250 MHz      ??? bytes  44.6 billion clocks
//   206.142 sec RP2350B Arm M33 @ 250 MHz             ??? bytes  51.5 billion clocks
//   210.230 sec PS2 MIPS III R5900 @ 295 MHz          400 bytes  62.0 billion clocks
//   261.068 sec esp32/Arduino @ 240 MHz               ??? bytes  62.7 billion clocks
//   294.749 sec chipKIT Pro MZ pic32 @ 200 MHz        ??? bytes  58.9 billion clocks
//   306.988 sec esp8266 @ 160 MHz                     ??? bytes  49.1 billion clocks
//   309.251 sec BlackPill Cortex M4F @ 168 MHz        228 bytes  52.0 billion clocks
//   319.155 sec WCH32V307 @ 144 MHz                   202 bytes  46.0 billion clocks
//   337.962 sec VexRiscv "full" RV32IM 200 MHz        236 bytes  67.6 billion clocks
//   712     sec DarkRISCV @ 100 MHz                   ??? bytes  71.2 billion clocks
//   927.547 sec BluePill Cortex M3 @ 72 MHz           228 bytes  66.8 billion clocks
//  5414.040 sec kianvSoC (14 CPI) @ 90 MHz            ??? bytes 487.3 billion clocks
// 13449.513 sec AVR ATmega2560 @ 20 MHz               318 bytes 269.0 billion clocks

#include <stdio.h>
#include <time.h>
#include <stdint.h>

#define SZ 1000 // darkriscv: reduce to 10 in order to simulate faster!
int32_t primes[SZ], sieve[SZ];
int nSieve = 0;

int32_t countPrimes(){
  primes[0] = 2; sieve[0] = 4; ++nSieve;
  int32_t nPrimes = 1, trial = 3, sqr=2;
  while (1){
    while (sqr*sqr <= trial) ++sqr;
    --sqr;
    for (int i=0; i<nSieve; ++i){
      if (primes[i] > sqr) goto found_prime;
      while (sieve[i] < trial) sieve[i] += primes[i];
      if (sieve[i] == trial) goto try_next;
    }
    break;
  found_prime:
    if (nSieve < SZ){
      primes[nSieve] = trial;
      sieve[nSieve] = trial*trial;
      ++nSieve;
      // printf("Saved %d: %d\n", nSieve, trial);
    }
    ++nPrimes;
  try_next:
    trial+=1;
  }
  return nPrimes;
}

int main(){
  printf("Starting run\n");
  clock_t start = clock();
  int res = countPrimes();
  int ms = (clock() - start) / (CLOCKS_PER_SEC / 1000); // .0) + 0.5; darkriscv: no FP there! :O
  // Size calculation does not work if opt >1 or if compiler or linker
  // otherwise reorders functions in the binary.
  int codeSz = (char*)main - (char*)countPrimes;
  printf("%d primes found in %d ms\n", res, ms);
  printf("%d bytes of code in countPrimes()\n", codeSz);

  printf("> "); getchar(); // darkriscv: added to end and dump debug data

  return 0;
}
