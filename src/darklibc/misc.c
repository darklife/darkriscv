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

// mul/div

unsigned __umulsi3(unsigned x,unsigned y)
{
    unsigned acc;

#ifdef MAC

    unsigned short xh,xl,yh,yl;

    xh = x>>16;
    yh = y>>16;
    xl = x&0xffff;
    yl = y&0xffff;

    acc = mac(0,xl,yl) + 
          (mac(0,xh,yl)<<16) + 
          (mac(0,xl,yh)<<16);

#else
    if(x<y) { unsigned z = x; x = y; y = z; }
    
    for(acc=0;y;x<<=1,y>>=1) if (y & 1) acc += x;
#endif
    return acc;
}

int __mulsi3(int x, int y)
{
    unsigned acc,xs,ys;
    
    if(x<0) { xs=1; x=-x; } else xs=0;
    if(y<0) { ys=1; y=-y; } else ys=0;

    acc = __umulsi3(x,y);
    
    return xs^ys ? -acc : acc;
}

unsigned __udiv_umod_si3(unsigned x,unsigned y,int opt)
{
    unsigned acc,aux;

    if(!y) return 0;

    for(aux=1;y<x&&!(y&(1<<31));aux<<=1,y<<=1);
    for(acc=0;x&&aux;aux>>=1,y>>=1) if(y<=x) x-=y,acc+=aux;

    return opt ? acc : x;
}

int __udivsi3(int x, int y)
{
    return __udiv_umod_si3(x,y,1);
}

int __umodsi3(int x,int y)
{
    return __udiv_umod_si3(x,y,0);
}

int __div_mod_si3(int x,int y,int opt)
{
    unsigned acc,xs,ys;

    if(!y) return 0;

    if(x<0) { xs=1; x=-x; } else xs=0;
    if(y<0) { ys=1; y=-y; } else ys=0;

    acc = __udiv_umod_si3(x,y,opt);

    if(opt) return xs^ys ? -acc : acc;
    else    return xs    ? -acc : acc;
}

int __divsi3(int x, int y)
{
    return __div_mod_si3(x,y,1);
}

int __modsi3(int x,int y)
{
    return __div_mod_si3(x,y,0);
}
