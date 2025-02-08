/*
 * Copyright (c) 2023, Marcelo Samsoniuk
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

#include <stdio.h>
//#include <unistd.h>

// rle file here!
#ifdef ENCODE
    unsigned char *rle=0;
#else
    #include "badapple.h"
#endif

int main()
{
#ifdef ENCODE
    // to generate the rle file:
    // ./badapple < badapple.txt > badapple.h
    // note:
    //
    //     the badapple.txt is a scalled down version from the file found on the application:
    //
    //          https://github.com/kisekied/BadAppleStringAnimation

    int c,l=0,s,count=0;

    printf("// rle.h file\n\n");
    printf("unsigned char rle[] = {\n");

    for(int i=0;(c=getchar())!=EOF;)
    {
        if(c!=l||count==63)
        {
            if(count)
            {
                     if(l=='.') s=3;
                else if(l=='@') s=2;
                else if(l=='!') s=1;
                else s=0;

                printf("0x%02x, ", (s<<6) + count);
                if((i%16)==15) printf("\n"); i++;
                count = 0;
                if(i==24576) break; // limit to 24KB
            }

            l = c;
        }

        count++;
    }

    printf("0x00\n};\n");
#else
    int s,count=0,f=0;

    char *t="\n!@.";

    // while((s=getchar())!=EOF) // from rle file
    unsigned char *p=rle;

    printf("\0337\n"); // save current cursor

    while((s=*p++))
    {
        count = s & 63;
        s = s>>6;

        if(s==1)
        {
            //usleep(1000000/12);
            //printf("\033[H\033[2Jframe %d\n",f++);
            printf("\0338frame %d\n",f++);
        }
        else
        while(count--)
        {
            putchar(t[s]);
        }
    }
    printf("finished w/ %d frames.\n",f);
#endif
    return 0;
}
