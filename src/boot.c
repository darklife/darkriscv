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

extern int banner(void);
extern int main  (void);

void boot(void)
{
    int tmp = 1&threads++;

    //volatile int timer_value;

    putchar('0'+tmp); // print thread number

    // thread 0

    if(tmp==0)
    {
        //the timer is initialized with 1kHz by default (usleep function)
        //timer_value = 49; // 1MHz GPIO
        //timer_value = (io.board_cm*1000000+io.board_ck*1000)/20-1; // 10Hz blink!
        //io.timer = 1; // start timer w/ shortest time to force the thread 1 start

        while(1)
        {

            banner();

            printf("boot0: text@%d data@%d stack@%d\n",
                (unsigned int)boot,
                (unsigned int)&threads,
                (unsigned int)&tmp);
        
                main();
        }
    }
    
    // thread 1, case exist
        
    //io.timer = timer_value;

    while(1)
    {
        io.led  ^= 1; // change led
        io.gpio ^= 1; // change gpio

        io.irq  = 0;  // clear interrupts and switch context
    }
}
