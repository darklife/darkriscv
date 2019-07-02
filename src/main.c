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

extern void banner(void);

int main(void)
{
    char  buffer[32];
    char *tmp;

    banner();

    // startup

    printf("board: %s (id=%d)\n",board_name[io.board_id],io.board_id);
    printf("core0: darkriscv at %d.%dMHz\n",io.board_cm,io.board_ck);
    printf("uart0: baudrate counter=%d\n",io.uart.baud);
    printf("timr0: periodic timer=%d\n\n",io.timer);

    printf("Welcome to DarkRISCV!\n");

    // main loop

    while(1)
    {
      printf("> ");
      memset(buffer,0,sizeof(buffer));
      gets(buffer,sizeof(buffer));

      if((tmp = strtok(buffer," ")))
      {
          if(!strcmp(tmp,"clear"))
          {
              printf("\33[H\33[2J");
          }
          else
          if(!strcmp(tmp,"atros"))
          {
              banner();
              printf("wow! hello atros! o/\n");
          }
          else
          if(!strcmp(tmp,"dump"))
          {
              tmp=strtok(NULL," ");
              
              char *p=(char *)(kmem+(tmp?atoi(tmp):0));

              int i,j;
              
              for(i=0;i!=16;i++)
              {
                  printf("%d: ",(unsigned) p);
              
                  for(j=0;j!=32;j++) printf("%x ",p[j]);
                  for(j=0;j!=32;j++) putchar((p[j]>=32&&p[j]<127)?p[j]:'.');
                  putchar('\n');
                  p+=32;
              }
          }
          else
          if(!strcmp(tmp,"led"))
          {
              if((tmp=strtok(NULL," ")))
              {
                  io.led = atoi(tmp);
              }
              printf("led = %d\n",io.led);
          }
          else
          if(!strcmp(tmp,"timer"))
          {
              if((tmp=strtok(NULL," ")))
              {
                  io.timer = atoi(tmp);
              }
              printf("timer = %d\n",io.timer);
          }
          else
          if(!strcmp(tmp,"gpio"))
          {
              if((tmp=strtok(NULL," ")))
              {
                  io.gpio = atoi(tmp);
              }
              printf("gpio = %d\n",io.gpio);
          }
          else
          if(!strcmp(tmp,"mul"))
          {
              int x=0,y=0;
          
              if((tmp=strtok(NULL," ")))
              {
                  x = atoi(tmp);
              }
              if((tmp=strtok(NULL," ")))
              {
                  y = atoi(tmp);
              }
              printf("mul = %d\n",x*y);
          }
          else
          if(!strcmp(tmp,"div"))
          {
              int x=0,y=0;
          
              if((tmp=strtok(NULL," ")))
              {
                  x = atoi(tmp);
              }
              if((tmp=strtok(NULL," ")))
              {
                  y = atoi(tmp);
              }
              printf("div = %d, mod = %d\n",x/y,x%y);
          }
          else
          if(!strcmp(tmp,"mac"))
          {
              int acc=0,x=0,y=0;
              
              if((tmp=strtok(NULL," ")))
              {
                  acc = atoi(tmp);
              }
              if((tmp=strtok(NULL," ")))
              {
                  x = atoi(tmp);
              }
              if((tmp=strtok(NULL," ")))
              {
                  y = atoi(tmp);
              }
              printf("mac = %d\n",mac(acc,x,y));
          }
          else
          if(tmp[0])
          {
              printf("command: [%s] not found.\n",tmp);
              printf("valid commands: clear, dump <val>, led <val>, timer <val>, gpio <val>\n");
              printf("                mul <val1> <val2>, div <val1> <val2>\n");
              printf("                mac <acc> <val1> <val2>\n");
          }
       }
    }

    return 0;
}
