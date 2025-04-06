/*
 * Copyright (c) 2025, Nicolas Sauzede <nicolas.sauzede@gmail.com>
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

#ifdef SPIBB
volatile int spibb_waste_counter = 0;
static inline void spibb_waste_time(int n) {
    for (int i = 0; i < n; i++) {
        spibb_waste_counter++;
    }
}
static inline int spibb_read_do_(void) {
//    return 1 & (io->iport >> 31);
    return !!(io->iport & (1 << 4));
}
volatile unsigned short g_spibb_out_x_resp = 0;
static inline void spibb_write_oe_es_cl_di_(unsigned char oe_es_cl_di) {
//    printf("%s: g_spibb_out_x_resp=%x\n", __func__, g_spibb_out_x_resp);
    io->oport = ((unsigned int)g_spibb_out_x_resp << 16) | oe_es_cl_di;
}
unsigned int spibb_transfer_(unsigned int command_data, int nbits) {
//    printf("%s: command_data=%x nbits=%d\n", __func__, command_data, nbits);
    unsigned int ret = 0;
    spibb_write_oe_es_cl_di_(0x7);    // output disabled / tristate       0111
    spibb_write_oe_es_cl_di_(0xf);    // output enabled / SPI Idle        1111
    spibb_write_oe_es_cl_di_(0xb);    // output enabled / SPI Active      1011
    for (int i = nbits; i >= 0; i--) {
        int bit;
        bit = !!(command_data & (1 << i));
        spibb_write_oe_es_cl_di_(0x8 | bit);                      //      100?
        spibb_waste_time(3);
        spibb_write_oe_es_cl_di_(0xa | bit);                      //      101?
        bit = spibb_read_do_();
        ret = (ret << 1) | bit;
//        ret <<= 1;
//        if (bit) ret++;
    }
    spibb_write_oe_es_cl_di_(0xf);    // output enabled / SPI Idle
    spibb_write_oe_es_cl_di_(0x7);    // output disabled / tristate
//    printf("%s: returning %x\n", __func__, ret);
    return ret;
}
static inline unsigned short spibb_transfer16(unsigned short command_data) {
    return spibb_transfer_(command_data, 15);
}
static inline unsigned int spibb_transfer24(unsigned int command_data) {
    unsigned int spi16 = spibb_transfer_(command_data, 23);
    return ((spi16 & 0xff) << 8) | ((spi16 & 0xff00) >> 8);
}
void bbset_stub_out_x_resp(unsigned short exp) {
//    printf("%s: set exp=%x\n", __func__, exp);
    g_spibb_out_x_resp = exp;
}
#endif
void hwset_stub_out_x_resp(unsigned short exp) {
//    printf("%s: set exp=%x\n", __func__, exp);
    io->oport = ((unsigned int)exp << 16) | (io->oport & 0xffff);
}
unsigned short spihw_transfer16(unsigned short command_data) {
    unsigned short ret = -1;
    io->spi.spi16 = command_data;
    for (int i = 0; i < 1000000; i++) {
        int status = 0;
        status = *(volatile unsigned char *)((volatile char *)io + 0x1c + 3);
        if (status & 0x2) {
            ret = io->spi.spi8;
            break;
        }
    }
    return ret;
}

unsigned int spihw_transfer24(unsigned int command_data) {
    unsigned int ret = -1;
    io->spi.spi32 = command_data & 0xffffff;
    for (int i = 0; i < 1000000; i++) {
        int status = 0;
        status = *(volatile unsigned char *)((volatile char *)io + 0x1c + 3);
        if (status & 0x2) {
            unsigned short spi16 = io->spi.spi16;
            ret = ((spi16 & 0xff) << 8) | ((spi16 & 0xff00) >> 8);
            break;
        }
    }
    return ret;
}

void (*set_stub_out_x_resp)(unsigned short exp) = hwset_stub_out_x_resp;
unsigned short (*spi_transfer16)(unsigned short command_data) = spihw_transfer16;
unsigned int (*spi_transfer24)(unsigned int command_data) = spihw_transfer24;
#ifdef SPIBB
int bb_active = 0;
void set_bb(int active) {
    bb_active = active;
    if (active) {
        bb_active = 1;
        set_stub_out_x_resp = bbset_stub_out_x_resp;
        spi_transfer16 = spibb_transfer16;
        spi_transfer24 = spibb_transfer24;
    } else {
        bb_active = 0;
        set_stub_out_x_resp = hwset_stub_out_x_resp;
        spi_transfer16 = spihw_transfer16;
        spi_transfer24 = spihw_transfer24;
    }
}
#endif
const char *spi_type() {
#define HWTYPE "HW"
#ifdef SPIBB
#define BBTYPE "BB"
    const char *type = bb_active ? BBTYPE : HWTYPE;
#else
    const char *type = HWTYPE;
#endif
    return type;
}

int check_sensor_(int verbose) {
    unsigned short ret = 0;
    unsigned short exp;
    exp = 0x33;
    ret = spi_transfer16(0x8f00) & 0xff;
    if (ret != exp) {
        printf("Bad %s %s %x exp %x\n", spi_type(), __func__, ret, exp);
        return 1;
    } else {
        if (verbose)
            printf("Good %s %s returned expected %x\n", spi_type(), __func__, ret);
        return 0;
    }
}
static inline int check_sensor() { return check_sensor_(0); }
static inline int whoami() { return check_sensor_(1); }

int sensor_init() {
    io->led = 0xff;
    if (check_sensor()) {
        return -1;
    }
    io->led = 0xfe;
    spi_transfer16(0x2077);
    io->led = 0xfd;
    spi_transfer16(0x1fc0);
    io->led = 0xfb;
    spi_transfer16(0x2388);
    return 0;
}
unsigned short sensor_read() {
    unsigned short ret = spi_transfer24(0xe80000);
    return ret;
}
int simu() {
//    printf("init sensor..\n");
    if (sensor_init()) {
//        printf("init failed ??\n");
        return -1;
    }
    unsigned short ret = 0;
    unsigned short exp;
    exp = 0x9a00;
    for (int i = 0; i < 2; i++) {
        //printf("i=%d\n", i);
        set_stub_out_x_resp(exp);
        ret = sensor_read();
        if (ret != exp) {
            printf("Bad out_x %x expected %x\n>", ret, exp);
            return -1;
        }
        unsigned char led_out = 1 << (((ret & 0xff00) >> 8) >> 5);
        io->led = led_out;
        exp += 0x2000;
    }
    printf("%s Test OK.\n", spi_type());  // The ">" ends the simulation early
    return 0;
}
int sensor() {
    if (sensor_init()) {
        return -1;
    }
    printf("Reading OUT_X.. (press a key to stop)\n");
    unsigned char accmin = 0, accmax = 0;
    unsigned char oldval = -1;
    while (1) {
        if (io->uart.stat&2) {
            break;
        }
        unsigned short ret = 0;
        ret = sensor_read();
        unsigned char acc = ((ret & 0xff00) >> 8) + 0x20 * 4;
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
        if (oldval != val) {
            printf("out_x=%x acc=%x min=%x max=%x val=%x\n", ret, acc, accmin, accmax, val);
        }
        oldval = val;
        unsigned char led_out = 1 << val;
        io->led = led_out;
    }
    return 0;
}
int main(void)
{
    if (!io->board_id) {
//        printf("running simu..\n");
        simu();
#ifdef SPIBB
        set_bb(1);
        simu();
#endif
        printf(">");  // The ">" ends the simulation early
    }

    unsigned t=0,t0=0;
    printf("Welcome to DarkRISCV!\n\n");
    if (!check_sensor()) {
        sensor();
    }
    // main loop
    while(1)
    {
        char buffer[32];
        memset(buffer,0,sizeof(buffer));
        t = io->timeus;
        printf("%d> ",t-t0);
        gets(buffer,sizeof(buffer));
        char *argv[8] = {0, 0, 0, 0, 0, 0, 0, 0};
        int   argc;
        for(argc=0;argc<8 && (argv[argc]=strtok(argc==0?buffer:NULL," "));argc++);
        if(argv[0] && *argv[0]) {
            if (!strcmp("whoami", argv[0])) {
                whoami();
            } else if (!strcmp("led", argv[0])) {
                printf("led was %x\n", io->led);
                io->led = ~io->led;
            } else if (!strcmp("simu", argv[0])) {
                simu();
            } else if (!strcmp("sensor", argv[0])) {
                sensor();
            } else if (!strcmp("iport", argv[0])) {
                printf("iport = %x\n",io->iport);
            } else if (!strcmp("oport", argv[0])) {
                if (argv[1]) io->oport = xtoi(argv[1]);
                printf("oport = %x\n",io->oport);
            } else if (!strcmp("ioport", argv[0])) {
                if (argv[1]) {
                    io->oport = xtoi(argv[1]);
                } else {
                    printf("oport = %x\n",io->oport);
                }
                printf("iport = %x\n",io->iport);
            } else if (!strcmp("read", argv[0])) {
                unsigned short ret = sensor_read();
                printf("%s: ret=%x\n", __func__, ret);
#ifdef SPIBB
            } else if (!strcmp("set_bb", argv[0])) {
                if (argv[1]) {
                    int active = atoi(argv[1]);
                    printf("%s: set bb_active=%x\n", __func__, active);
                    set_bb(active);
                }
            } else if (!strcmp("get_bb", argv[0])) {
                printf("bb_active = %x\n", __func__, bb_active);
#endif
            } else if(!strcmp("reboot", argv[0])) {
                printf("rebooting...\n");
                break;
            } else {
                printf("Error: you entered [%s]\n", buffer);
            }
        }
        t0 = t;
    }
    return 0;
}
