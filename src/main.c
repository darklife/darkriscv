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

int main(void)
{
    char  buffer[32];

    // startup

    printf("Welcome to DarkRISCV!\n");

    // main loop

    while(1)
    {
      printf("> ");
      
      gets(buffer,sizeof(buffer));

      if(!strcmp(buffer,"clear"))
      {
          printf("\33[H\33[2J");
      }
      else
      if(!strcmp(buffer,"led"))
      {
          printf("led = %x\n",++io.led);
      }
      else
      if(!strcmp(buffer,"bug"))
      {
          printf("bug = %x\n",io.bug);
      }
      else
      if(!strcmp(buffer,"heap"))
      {
          char *p=(char *)0x1000;
          int i,j;
          
          for(i=0;i!=16;i++)
          {
              for(j=0;j!=32;j++) printf("%x ",p[j]);
              for(j=0;j!=32;j++) putchar((p[j]>=32&&p[j]<127)?p[j]:'.');
              putchar('\n');
              p+=32;
          }
      }
      else
      if(!strcmp(buffer,"stack"))
      {
          char *p=(char *)(0x2000-(32*16));
          int i,j;
          
          for(i=0;i!=16;i++)
          {
              for(j=0;j!=32;j++) printf("%x ",p[j]);
              for(j=0;j!=32;j++) putchar((p[j]>=32&&p[j]<127)?p[j]:'.');
              putchar('\n');
              p+=32;
          }
      }
      else
      if(!strcmp(buffer,"hello"))
      {
          printf("hello atros! o/\n");
      }
      else
      if(buffer[0])
      {
          printf("command: [%s] not found.\n",buffer);
      }
    }

    return 0;
}
