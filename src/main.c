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

unsigned int   test = 0x12345678;
unsigned int   ip   = 0xAC100001; // 172.16.0.1
unsigned short port = 0x0c38;     // 3128
unsigned short opts = 0xABCD;

int main(void)
{
    banner();

    // startup

    printf("board: %s (id=%d)\n",board_name[io.board_id],io.board_id);
    printf("build: darkriscv fw build %s\n",BUILD);

    printf("core0: darkriscv@%d.%dMHz with %s%s%s\n",
        io.board_cm,                        // board clock MHz
        io.board_ck,                        // board clock kHz
        ARCH,                               // architecture
        threads>1?"+MT":"",                 //  MT support
        mac(1000,16,16)==1256?"+MAC":"");   // MAC support

    threads = 0; // prepare for the next restart

    printf("uart0: 115200 bps (div=%d)\n",io.uart.baud);
    printf("timr0: periodic timer=%dHz (io.timer=%d)\n",(io.board_cm*1000000u+io.board_ck*1000u)/(io.timer+1),io.timer);
    printf("\n");

#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    printf("endian-test (big-endian):\n");
#else
    printf("endian-test (little-endian):\n");
#endif


    struct
    {
        unsigned int   ref;
        unsigned int   ip;
        unsigned short port;
        unsigned char  opt_a;
        unsigned char  opt_b;
    } 
    data;

    data.ref  = 0x12345678;
    data.ip   = ip;
    data.port = port;
    data.opt_a = 0xA;
    data.opt_b = 0xB;

    unsigned char *p = (unsigned char *)&data;

    printf("ip:port=%d.%d.%d.%d:%d\n",p[4],p[5],p[6],p[7],data.port);

    printf("data.ref  = %x %x %x %x = %x\n",p[0],p[1],p[2],p[3],data.ref);
    printf("data.ip   = %x %x %x %x = %x\n",p[4],p[5],p[6],p[7],data.ip);
    printf("data.port = %x %x = %x/%d\n",p[8],p[9], data.port, data.port);
    printf("data.opts = %x %x = %x %x\n",p[10],p[11],data.opt_a,data.opt_b);

    printf("\n");

    printf("Welcome to DarkRISCV!\n");

    // main loop

    while(1)
    {
        char  buffer[64];

        printf("> ");
        memset(buffer,0,sizeof(buffer));
        gets(buffer,sizeof(buffer));
        
        char *argv[8];
        int   argc;

        for(argc=0;argc<8 && (argv[argc]=strtok(argc==0?buffer:NULL," "));argc++)
            //printf("argv[%d] = [%s]\n",argc,argv[argc]);
            ;

        if(argv[0])
        {
          if(!strcmp(argv[0],"clear"))
          {
              printf("\33[H\33[2J");
          }
          else
          if(!strcmp(argv[0],"atros"))
          {
              banner();
              printf("wow! hello atros! o/\n");
          }
          else
          if(!strcmp(argv[0],"dump"))
          {
              char *p=(char *)(kmem+(argv[1]?xtoi(argv[1]):0));

              int i,j;
              
              for(i=0;i!=16;i++)
              {
                  printf("%x: ",(unsigned) p);
              
                  for(j=0;j!=16;j++) printf("%x ",p[j]);
                  for(j=0;j!=16;j++) putchar((p[j]>=32&&p[j]<127)?p[j]:'.');

                  putchar('\n');
                  p+=16;
              }
          }
          else
          if(!strncmp(argv[0],"rd",2)||!strncmp(argv[0],"wr",2))
          {
              int kp = 2,
                  i = 1,j,k,w,
                  vp = 1;
              
              if(argv[0][kp]=='m')
              {
                  i=xtoi(argv[vp++]);
                  kp++;
              }
          
              printf("%x: ",k=xtoi(argv[vp++]));
              
              for(j=0;i--;j++)
              {
                  if(argv[0][0]=='r')
                  {
                      if(argv[0][kp]=='b') printf("%x ",j[(char  *)k]);
                      if(argv[0][kp]=='w') printf("%x ",j[(short *)k]);
                      if(argv[0][kp]=='l') printf("%x ",j[(int   *)k]);
                  }
                  else
                  {
                      w = xtoi(argv[vp++]);
                      if(argv[0][kp]=='b') printf("%x ",j[(char  *)k]=w);
                      if(argv[0][kp]=='w') printf("%x ",j[(short *)k]=w);
                      if(argv[0][kp]=='l') printf("%x ",j[(int   *)k]=w);
                  }
              }
              printf("\n");
          }
          else
          if(!strcmp(argv[0],"led"))
          {
              if(argv[1]) io.led = xtoi(argv[1]);
              
              printf("led = %x\n",io.led);
          }
          else
          if(!strcmp(argv[0],"timer"))
          {
              if(argv[1]) io.timer = atoi(argv[1]);
              
              printf("timer = %d\n",io.timer);
          }
          else
          if(!strcmp(argv[0],"gpio"))
          {
              if(argv[1]) io.gpio = xtoi(argv[1]);

              printf("gpio = %x\n",io.gpio);
          }
          else
          if(!strcmp(argv[0],"mul"))
          {
              int x = atoi(argv[1]);
              int y = atoi(argv[2]);
              
              printf("mul = %d\n",x*y);
          }
          else
          if(!strcmp(argv[0],"div"))
          {
              int x = atoi(argv[1]);
              int y = atoi(argv[2]);

              printf("div = %d, mod = %d\n",x/y,x%y);
          }
          else
          if(!strcmp(argv[0],"mac"))
          {
              int acc = atoi(argv[1]);
              int x = atoi(argv[2]);
              int y = atoi(argv[3]);

              printf("mac = %d\n",mac(acc,x,y));
          }
          else
          if(argv[0][0])
          {
              printf("command: [%s] not found.\n"
                     "valid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n"
                     "                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n"
                     "                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n",
                     argv[0]);
          }
       }
    }
}
