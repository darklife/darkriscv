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
#include <stdio.h>
#include <stdarg.h>

// putchar and getchar uses the "low-level" io

int getchar(void)
{
  while((io.uart.stat&2)==0); // uart empty, wait...
  
  return io.uart.fifo;
}

int putchar(int c)
{
  if(c=='\n')
  {
    while(io.uart.stat&1); // uart busy, wait...
    io.uart.fifo = '\r';  
  }
  
  while(io.uart.stat&1); // uart busy, wait...
  return io.uart.fifo = c;
}

// high-level functions uses the getchar/putchar

void gets(char *p,int s)
{
  register int c;

  while(--s)
  {
    c=getchar();
    
    if(c=='\n'||c=='\r') break;
     
    putchar((*p++ = c));
  }
  putchar('\n');
  *p=0;
}

int puts(char *p)
{
  while(*p) putchar(*p++);
  return putchar('\n');
}

void putx(unsigned i)
{
    register char *hex="0123456789abcdef";

    if(i>16777216)
    {
        putchar(hex[(i>>28)&15]);
        putchar(hex[(i>>24)&15]);
    }
    if(i>65536)
    {
        putchar(hex[(i>>20)&15]);
        putchar(hex[(i>>16)&15]);
    }    
    if(i>256)
    {
        putchar(hex[(i>>12)&15]);
        putchar(hex[(i>>8)&15]);
    }

    putchar(hex[(i>>4)&15]);
    putchar(hex[(i>>0)&15]);
}

void putd(int i)
{
    int db[10] = { 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1 };

    int j,k,t,v=0;

    if(i<0)
    {
        putchar('-');
        i=-i;
    }

    for(j=0;j!=10;j++)
    {
        t = db[j];

        for(k=1;k!=10;k++)
        {
            if((i-t)<db[j]) break;

            t = t+db[j];
        }

        if((i-t)>=0)
        {
            if(v==0 && k!=0) v=1; // remove leading zeros

            if(v||j==9) putchar(k+'0');

            i=i-t;
        }
        else
            if(v||j==9) putchar('0');
    }
}

int printf(char *fmt,...)
{
    va_list ap;

    for(va_start(ap, fmt);*fmt;fmt++)
    {
        if(*fmt=='%')
        {
            fmt++;
                 if(*fmt=='s') printf(va_arg(ap,char *));
            else if(*fmt=='x') putx(va_arg(ap,int));
            else if(*fmt=='d') putd(va_arg(ap,int));
            else putchar(*fmt);
        }
        else putchar(*fmt);
    }

    va_end(ap);

    return 0;
}

int strcmp(char *s1, char *s2)
{
    while(*s1 && *s2 && (*s1==*s2)) { s1++; s2++; }
    
    return (*s1-*s2);
}

char *memcpy(char *dptr,char *sptr,int len)
{
    char *ret = dptr;

    while(len--) *dptr++ = *sptr++;

    return ret;
}

char *memset(char *dptr, int c, int len)
{
    char *ret = dptr;
    
    while(len--) *dptr++ = c;
    
    return ret;
}
