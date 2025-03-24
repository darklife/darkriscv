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
#include <string.h>
#include <math.h>

unsigned csr_test(unsigned,unsigned,unsigned);

unsigned short spi_transfer16(unsigned short command_data) {
    unsigned short ret = -1;
    io->spi.spi16 = command_data;
    for (int i = 0; i < 1000000; i++) {
        int status = 0;
        status = *(volatile unsigned char *)((volatile char *)io + 0x14 + 3);
//        if (status & 0x2000000) {
        if (status & 0x2) {
            ret = io->spi.spi8;
//            ret = io->spi.spi16;
//            ret = status & 0xffff;
            break;
        }
//        printf("%s: status=%x\n", __func__, status);
    }
    return ret;
}

unsigned int spi_transfer24(unsigned int command_data) {
    unsigned int ret = -1;
//    io->spi.spi32 = command_data & 0xffffff;
    io->spi.spi24 = command_data & 0xffffff;
    for (int i = 0; i < 1000000; i++) {
        int status = 0;
//        status = io->spi.spi32;
        status = *(volatile unsigned char *)((volatile char *)io + 0x14 + 3);
//        if (status & 0x2000000) {
        if (status & 0x2) {
//            ret = status & 0xffffff;
//            ret = io->spi.spi16;
            unsigned short spi16 = io->spi.spi16;
            ret = ((spi16 & 0xff) << 8) | ((spi16 & 0xff00) >> 8);
            break;
        }
    }
    return ret;
}

int simu() {
    io->led = 0xff;
    unsigned short ret = 0;
    unsigned short exp;
    exp = 0x33;
    ret = spi_transfer16(0x8f00);
    io->led = ret;
    if ((ret & 0xff) != exp) {
        printf("Bad Whoami %x expected %x\n>", ret, exp);
        return -1;
    }
    io->led = 0xfe;
    spi_transfer16(0x2077);
    io->led = 0xfd;
    spi_transfer16(0x1fc0);
    io->led = 0xfb;
    spi_transfer16(0x2388);
    exp = 0x9a00;
    for (int i = 0; i < 1000000; i++) {
        printf("i=%d\n", i);
        io->spi.out_x_l_response = exp;
        ret = spi_transfer24(0xe80000);
        if (ret != exp) {
            printf("Bad out_x %x expected %x\n>", ret, exp);
            return -1;
        }
        unsigned char led_out = 1 << (((ret & 0xff00) >> 8) >> 5);
        io->led = led_out;
        exp += 0x2000;
        if (i == 16)
            printf("Test passed.\n>");
    }
    return 0;
}
int sensor() {
    io->led = 0xff;
    unsigned short ret = 0;
    unsigned short exp;
    exp = 0x33;
    ret = spi_transfer16(0x8f00);
    io->led = ret;
    if ((ret & 0xff) != exp) {
        printf("Bad Whoami %x expected %x\n>", ret, exp);
        return -1;
    }
    io->led = 0xfe;
    spi_transfer16(0x2077);
    io->led = 0xfd;
    spi_transfer16(0x1fc0);
    io->led = 0xfb;
    spi_transfer16(0x2388);
    printf("Reading OUT_X.. (press a key to stop)\n");
    while (1) {
        if (io->uart.stat&2) {
            break;
        }
        ret = spi_transfer24(0xe80000);
        unsigned char acc = ((ret & 0xff00) >> 8) + 0x20 * 4;
        static unsigned char accmin = 0, accmax = 0;
        if (!accmin && !accmax) {
            accmin = acc;
            accmax = acc;
        } else {
            if (acc < accmin) {
                accmin = acc;
            }
            if (acc > accmax) {
                accmax = acc;
            }
        }
        int range = accmax - accmin;
        if (!range) range++;
        unsigned char val = (int)(acc - accmin) * 8 / range;
        if (val > 7) val = 7;
        static unsigned char oldval = -1;
        if (oldval != val) {
            printf("out_x=%x acc=%x min=%x max=%x val=%x\n", ret, acc, accmin, accmax, val);
        }
        oldval = val;
        unsigned char led_out = 1 << val;
        io->led = led_out;
    }
    return 0;
}
int whoami() {
    io->led = 0x55;
    unsigned short ret = 0;
    unsigned short exp;
    exp = 0x33;
    ret = spi_transfer16(0x8f00);
    io->led = ret;
    if ((ret & 0xff) != exp) {
        printf("Bad Whoami %x expected %x\n", ret, exp);
        return 1;
    } else {
        printf("Whoami returned %x\n", ret);
        return 0;
    }
}
int main(void)
{
    if (!io->board_id) {
        return simu();
    }

    unsigned t=0,t0=0;
    printf("Welcome to DarkRISCV!\n\n");
    if (!whoami()) {
        sensor();
    }
    // main loop
    while(1)
    {
        char  buffer[32];
        memset(buffer,0,sizeof(buffer));
        t = io->timeus;
        printf("%d> ",t-t0);
        gets(buffer,sizeof(buffer));
        printf("You entered [%s]\n", buffer);
        if (!strncmp("whoami", buffer, 6)) {
            whoami();
        } else if (!strncmp("led", buffer, 3)) {
            printf("led was %x\n", io->led);
            io->led = ~io->led;
        } else if (!strncmp("sensor", buffer, 6)) {
            sensor();
        } else if(!strcmp(buffer,"reboot")) {
            printf("rebooting...\n");
            break;
        }
        t0 = t;
    }
    return 0;
}
