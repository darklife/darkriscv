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
           id==14 ? "lattice ecp5-45F colorlighti9" :
           id==15 ? "lattice ecp5-25F colorlighti5" :
           id==16 ? "lattice ecp5-85F ulx3s" :
                    "unknown";
}

#ifndef SMALL

__attribute__ ((interrupt ("machine")))
void irq_handler(void)
{
    if(io.irq == IRQ_TIMR)
    {
        if(!utimers--)
        {
            io.led++;
            utimers=999999;
        }
        io.irq = IRQ_TIMR;
    }

    return;
}

#endif

#ifdef BANNER

#define RLE 1

#include <stdio.h>

void banner(void)
{
#ifndef RLE

  // https://github.com/riscv/riscv-pk/blob/master/bbl/riscv_logo.txt
  // https://github.com/riscv/riscv-pk/blob/master/LICENSE.riscv_logo.txt
  // Copyright (C) 2015 Andrew Waterman

  char *logo =

    "              vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n"
    "                  vvvvvvvvvvvvvvvvvvvvvvvvvvvv\n"
    "rrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvvvvvv\n"
    "rrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvvvv\n"
    "rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\n"
    "rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\n"
    "rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\n"
    "rrrrrrrrrrrrrrrr      vvvvvvvvvvvvvvvvvvvvvv  \n"
    "rrrrrrrrrrrrr       vvvvvvvvvvvvvvvvvvvvvv    \n"
    "rr                vvvvvvvvvvvvvvvvvvvvvv      \n"
    "rr            vvvvvvvvvvvvvvvvvvvvvvvv      rr\n"
    "rrrr      vvvvvvvvvvvvvvvvvvvvvvvvvv      rrrr\n"
    "rrrrrr      vvvvvvvvvvvvvvvvvvvvvv      rrrrrr\n"
    "rrrrrrrr      vvvvvvvvvvvvvvvvvv      rrrrrrrr\n"
    "rrrrrrrrrr      vvvvvvvvvvvvvv      rrrrrrrrrr\n"
    "rrrrrrrrrrrr      vvvvvvvvvv      rrrrrrrrrrrr\n"
    "rrrrrrrrrrrrrr      vvvvvv      rrrrrrrrrrrrrr\n"
    "rrrrrrrrrrrrrrrr      vv      rrrrrrrrrrrrrrrr\n"
    "rrrrrrrrrrrrrrrrrr          rrrrrrrrrrrrrrrrrr\n"
    "rrrrrrrrrrrrrrrrrrrr      rrrrrrrrrrrrrrrrrrrr\n"
    "rrrrrrrrrrrrrrrrrrrrrr  rrrrrrrrrrrrrrrrrrrrrr\n"
    "\n"
    "       INSTRUCTION SETS WANT TO BE FREE\n\n";

  // rle compressor: 1030 to 269 bytes! +_+

  register int xc=0,xs=0,xp,dp;

  char *dict = " rv\n";

  printf("  char rle_logo[] = {\n");

  for(xp=0;;xp++)
  {
      if(xc!=logo[xp])
      {
          if(xc)
          {
              // printf("0x%x, 0x%x, ",xc,xs);
              for(dp=0;dict[dp];dp++)
              {
                  if(dict[dp]==xc)
                  {
                      printf("0x%x, ",(dp<<6)+xs); // hope xs dont overflow!
                      break;
                  }
              }
          }
          xs=1;
          if(!(xc=logo[xp])) break;
      }
      else xs++;
  }

  printf("0x00 };\n");

#else
/*
  char rle_logo[] = {
      0x20, 0x0e, 0x76, 0x20, 0x0a, 0x01, 0x20, 0x12, 0x76, 0x1c, 0x0a,
      0x01, 0x72, 0x0d, 0x20, 0x07, 0x76, 0x1a, 0x0a, 0x01, 0x72, 0x10,
      0x20, 0x06, 0x76, 0x18, 0x0a, 0x01, 0x72, 0x12, 0x20, 0x04, 0x76,
      0x18, 0x0a, 0x01, 0x72, 0x12, 0x20, 0x04, 0x76, 0x18, 0x0a, 0x01,
      0x72, 0x12, 0x20, 0x04, 0x76, 0x18, 0x0a, 0x01, 0x72, 0x10, 0x20,
      0x06, 0x76, 0x16, 0x20, 0x02, 0x0a, 0x01, 0x72, 0x0d, 0x20, 0x07,
      0x76, 0x16, 0x20, 0x04, 0x0a, 0x01, 0x72, 0x02, 0x20, 0x10, 0x76,
      0x16, 0x20, 0x06, 0x0a, 0x01, 0x72, 0x02, 0x20, 0x0c, 0x76, 0x18,
      0x20, 0x06, 0x72, 0x02, 0x0a, 0x01, 0x72, 0x04, 0x20, 0x06, 0x76,
      0x1a, 0x20, 0x06, 0x72, 0x04, 0x0a, 0x01, 0x72, 0x06, 0x20, 0x06,
      0x76, 0x16, 0x20, 0x06, 0x72, 0x06, 0x0a, 0x01, 0x72, 0x08, 0x20,
      0x06, 0x76, 0x12, 0x20, 0x06, 0x72, 0x08, 0x0a, 0x01, 0x72, 0x0a,
      0x20, 0x06, 0x76, 0x0e, 0x20, 0x06, 0x72, 0x0a, 0x0a, 0x01, 0x72,
      0x0c, 0x20, 0x06, 0x76, 0x0a, 0x20, 0x06, 0x72, 0x0c, 0x0a, 0x01,
      0x72, 0x0e, 0x20, 0x06, 0x76, 0x06, 0x20, 0x06, 0x72, 0x0e, 0x0a,
      0x01, 0x72, 0x10, 0x20, 0x06, 0x76, 0x02, 0x20, 0x06, 0x72, 0x10,
      0x0a, 0x01, 0x72, 0x12, 0x20, 0x0a, 0x72, 0x12, 0x0a, 0x01, 0x72,
      0x14, 0x20, 0x06, 0x72, 0x14, 0x0a, 0x01, 0x72, 0x16, 0x20, 0x02,
      0x72, 0x16, 0x0a, 0x02, 0x20, 0x07, 0x49, 0x01, 0x4e, 0x01, 0x53,
      0x01, 0x54, 0x01, 0x52, 0x01, 0x55, 0x01, 0x43, 0x01, 0x54, 0x01,
      0x49, 0x01, 0x4f, 0x01, 0x4e, 0x01, 0x20, 0x01, 0x53, 0x01, 0x45,
      0x01, 0x54, 0x01, 0x53, 0x01, 0x20, 0x01, 0x57, 0x01, 0x41, 0x01,
      0x4e, 0x01, 0x54, 0x01, 0x20, 0x01, 0x54, 0x01, 0x4f, 0x01, 0x20,
      0x01, 0x42, 0x01, 0x45, 0x01, 0x20, 0x01, 0x46, 0x01, 0x52, 0x01,
      0x45, 0x02, 0x0a, 0x02, 0x00 };
*/
  char rle_logo[] = {
      0x0e, 0xa0, 0xc1, 0x12, 0x9c, 0xc1, 0x4d, 0x07, 0x9a, 0xc1, 0x50, 
      0x06, 0x98, 0xc1, 0x52, 0x04, 0x98, 0xc1, 0x52, 0x04, 0x98, 0xc1, 
      0x52, 0x04, 0x98, 0xc1, 0x50, 0x06, 0x96, 0x02, 0xc1, 0x4d, 0x07, 
      0x96, 0x04, 0xc1, 0x42, 0x10, 0x96, 0x06, 0xc1, 0x42, 0x0c, 0x98, 
      0x06, 0x42, 0xc1, 0x44, 0x06, 0x9a, 0x06, 0x44, 0xc1, 0x46, 0x06, 
      0x96, 0x06, 0x46, 0xc1, 0x48, 0x06, 0x92, 0x06, 0x48, 0xc1, 0x4a, 
      0x06, 0x8e, 0x06, 0x4a, 0xc1, 0x4c, 0x06, 0x8a, 0x06, 0x4c, 0xc1, 
      0x4e, 0x06, 0x86, 0x06, 0x4e, 0xc1, 0x50, 0x06, 0x82, 0x06, 0x50, 
      0xc1, 0x52, 0x0a, 0x52, 0xc1, 0x54, 0x06, 0x54, 0xc1, 0x56, 0x02, 
      0x56, 0xc2, 0x07, 0x00 };
      
  char dict[] = " rv\n";

  //printf("\33[H\33[2J");
  putchar('\n');

  register int c,s;
  register char *p;

  for(p=rle_logo;*p;p++)
  {
      c = dict[(*p)>>6];
      s = (*p)&63;

      while(s--) putchar(c);
  }

#endif
}

#endif
