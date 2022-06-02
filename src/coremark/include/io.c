/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#include <io.h>

#ifdef __RISCV__

volatile struct DARKIO io;

#else

volatile struct DARKIO io = 
{
    4, 100, 0, 0,   // ctrl = { board id, fMHz, fkHz }
    { 0, 0, 0 },    // uart = { stat, fifo, baud }
    0,              // led
    0,              // gpio
    1000000         // timer
};

unsigned char kmem[8192] = "darksocv x86 payload test";

#endif

volatile int threads = 0; // number of threads
volatile int utimers = 0; // number of microseconds

// board database

char *board_name(int id)
{
    return id==0  ? "simulation only" : 
           id==1  ? "avnet microboard lx9": 
           id==2  ? "xilinx ac701 a200" :
           id==3  ? "qmtech sdram lx16" :
           id==4  ? "qmtech spartan7 s15" :
           id==5  ? "lattice brevia2 lxp2" :
           id==6  ? "piswords rs485 lx9" :
           id==7  ? "digilent spartan3 s200" :
           id==8  ? "aliexpress hpc/40gbe k420" :
           id==9  ? "qmtech artix7 a35" :
           id==10 ? "aliexpress hpc/40gbe ku040" :
           id==11 ? "papilio duo logicstart" :
           id==12 ? "qmtech kintex-7 k325" :
           id==13 ? "scarab minispartan6-plus lx9" :
                    "unknown";
}
