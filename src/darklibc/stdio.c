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

#ifdef __RISCV__

// putchar and getchar uses the "low-level" io

int getchar(void)
{
  while((io->uart.stat&2)==0); // uart empty, wait...
  return io->uart.fifo;
}

int putchar(int c)
{
  if(c=='\n')
  {
    while(io->uart.stat&1); // uart busy, wait...
    io->uart.fifo = '\r';  
  }
  
  while(io->uart.stat&1); // uart busy, wait...
  return io->uart.fifo = c;
}

#endif

// high-level functions use the getchar/putchar

char *gets(char *p,int s)
{
  char *ret = p;
  int c;

  while(--s)
  {
    c=getchar();
    
    if(c=='\n'||c=='\r') break;
#ifdef __RISCV__     
    putchar(c);
#endif
    if(c=='\b') // backspace!
    {
        if(p!=ret) 
        {
            *--p = 0;
            s++;
        }
    }
    else
        *p++ = c;
  }
#ifdef __RISCV__
  putchar('\n');
#endif
  *p=0;
  
  return p==ret ? NULL : ret;
}

void putstr(char *p)
{
    if(p) while(*p) putchar(*p++);
    else putstr("(NULL)");
}

int puts(char *p)
{
    putstr(p);
    return putchar('\n');
}

void putnum(unsigned i, int base)
{
    char ascii[]="0123456789abcdef";
    char stack[32];
    int  ptr = 0;

    if(base==10)
    {
        int j = i;
        
        if(j<0)
        {
            putchar('-');
            i = -j;
        }
    }

    do
    {
        stack[ptr++] = ascii[(i%base)];
        i/=base;
        
        if(base!=10)
        {
            stack[ptr++] = ascii[(i%base)];
            i/=base;
        }        
    } 
    while(i);

    while(ptr) putchar(stack[--ptr]);
}

int printf(char *fmt,...)
{
    va_list ap;

    for(va_start(ap, fmt);*fmt;fmt++)
    {
        if(*fmt=='%')
        {
            fmt++;
                 if(*fmt=='s') putstr(va_arg(ap,char *));
            else if(*fmt=='x') putnum(va_arg(ap,int),16);
            else if(*fmt=='d') putnum(va_arg(ap,int),10);
            else putchar(*fmt);
        }
        else putchar(*fmt);
    }

    va_end(ap);

    return 0;
}

// type conversion

int atoi(char *s1)
{
    int ret,sig;
    
    for(sig=ret=0;s1&&*s1;s1++) 
    {
        if(*s1=='-') 
            sig=1;
        else 
            ret = *s1-'0'+(ret<<3)+(ret<<1); // val = val*10+int(*s1)
    }
    
    return sig ? -ret : ret;
}

int xtoi(char *s1)
{
    int ret;
    
    for(ret=0;s1&&*s1;s1++) 
    {
        if(*s1<='9')
            ret = *s1-'0'+(ret<<4); // val = val*16+int(*s1)
        else
            ret = 10+(*s1&0x5f)-'A'+(ret<<4); // val = val*16+int(toupper(*s1))
    }
    
    return ret;
}
