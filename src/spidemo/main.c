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

#ifdef SPI3WIRE
static int spi3w = 0;
#endif
#ifdef SPIBB
static int bb_active = 0;
#endif

#ifdef SPIBB
volatile int spibb_waste_counter = 0;
static inline void spibb_waste_time(int n) {
    for (int i = 0; i < n; i++) {
        spibb_waste_counter++;
    }
}
static int verbose = 0; // WR_RD WR_ WR RD
static inline int spibb_read_do_(void) {
//    return 1 & (io->iport >> 31);
    int val = io->iport;
#ifdef SPI3WIRE
    int ret = !!(val & (1 << (spi3w ? 0 : 6)));
#else
    int ret = !!(val & (1 << 6));
#endif
    if (verbose & 1) { printf("%s: read %x from iport (returning %d)\n", __func__, val, ret); }
    return ret;
}
volatile unsigned short g_spibb_out_x_resp = 0;
static inline void spibb_write_rd_tr_oe_es_cl_di_(unsigned char rd_tr_oe_es_cl_di) {
//    printf("%s: g_spibb_out_x_resp=%x\n", __func__, g_spibb_out_x_resp);
    unsigned int val = ((unsigned int)g_spibb_out_x_resp << 16) | rd_tr_oe_es_cl_di;
    if (verbose & 2) { printf("%s: write %x to oport\n", __func__, val); }
    if (verbose & 4) { printf(" %x", val); }
    if (verbose & 8) { printf(" %x:%x", val, io->iport); }
    io->oport = val;
}
unsigned int spibb_transfer_(unsigned int command_data, int nbits) {
    unsigned int ret = 0;
    int rd = !!(command_data & (1 << nbits));
    int mosi_tri = 0;
#ifdef SPI3WIRE
#ifdef SPIBB
//    if (spi3w && bb_active)printf("%s: command_data=%x nbits=%d rd=%d\n", __func__, command_data, nbits, rd);
#endif
#endif
    spibb_write_rd_tr_oe_es_cl_di_((rd << 5) | (mosi_tri << 4) | 0x7);    // output disabled / tristate       0111
    spibb_write_rd_tr_oe_es_cl_di_((rd << 5) | (mosi_tri << 4) | 0xf);    // output enabled / SPI Idle        1111
    spibb_write_rd_tr_oe_es_cl_di_((rd << 5) | (mosi_tri << 4) | 0xb);    // output enabled / SPI Active      1011
    for (int i = nbits; i >= 0; i--) {
        int bit;
#ifdef SPI3WIRE
        mosi_tri = spi3w && (i <= nbits - 8);
#endif
        bit = !!(command_data & (1 << i));
        spibb_write_rd_tr_oe_es_cl_di_(0x8 | (rd << 5) | (mosi_tri << 4) | bit);    //      100?
        spibb_waste_time(3);
        spibb_write_rd_tr_oe_es_cl_di_(0xa | (rd << 5) | (mosi_tri << 4) | bit);    //      101?
        bit = spibb_read_do_();
        ret = (ret << 1) | bit;
//        ret <<= 1;
//        if (bit) ret++;
    }
    spibb_write_rd_tr_oe_es_cl_di_((rd << 5) | (mosi_tri << 4) | 0xf);    // output enabled / SPI Idle
    rd = 0;
    mosi_tri = 0;
    spibb_write_rd_tr_oe_es_cl_di_((rd << 5) | (mosi_tri << 4) | 0x7);    // output disabled / tristate
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

void set_divcoef(unsigned short divcoef) {
    io->spi.spi32 = 0x80800000 | divcoef;     // spi_master configure: `set divider coefficient`
}

void (*set_stub_out_x_resp)(unsigned short exp) = hwset_stub_out_x_resp;
unsigned short (*spi_transfer16)(unsigned short command_data) = spihw_transfer16;
unsigned int (*spi_transfer24)(unsigned int command_data) = spihw_transfer24;
#ifdef SPIBB
int get_bb() {
    return bb_active;
}
void set_bb(int active) {
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
#ifdef SPI3WIRE
int get_spi3w() {
    return spi3w;
}
void set_spi3w(int val) {
    spi3w = val;
    if (spi3w) {
        spi_transfer16(0x2301);         // spi slave LIS3DH: CTRL_REG4, SIM=1: set 3-wire interface
#ifdef SPIBB
        if (get_bb()) {
        // nothing to do for BB
        }
        else
#endif
        io->spi.spi32 = 0x81010000;     // spi_master configure: `set 3-wire on`
    } else {
        io->spi.spi32 = 0x81000000;     // spi_master configure: `set 3-wire off (default 4-wire)`
#ifdef SPIBB
        if (get_bb()) {
        // nothing to do for BB
        }
        else
#endif
        spi_transfer16(0x2300);         // spi slave LIS3DH: CTRL_REG4, SIM=0: set 4-wire interface
    }
}
#endif

void print_spi_type() {
#define HWTYPE "HW"
#ifdef SPIBB
#define BBTYPE "BB"
#endif
#ifdef SPI3WIRE
#define SPI3WTYPE "3W"
#endif
#ifdef SPIBB
    printf("%s", get_bb() ? BBTYPE : HWTYPE);
#else
    printf("%s", HWTYPE);
#endif
#ifdef SPI3WIRE
#define BBTYPE "BB"
    if (get_spi3w()) printf(" %s", SPI3WTYPE);
#endif
    printf(" ");
}

int check_sensor_(int verbose) {
    unsigned short ret = 0;
    unsigned short exp;
    exp = 0x33;
    ret = spi_transfer16(0x8f00) & 0xff;        // Read WHO_AM_I register (Addr 0x0F)
    if (ret != exp) {
        print_spi_type();
        printf("Bad whoami %x exp %x\n", ret, exp);
        return 1;
    } else {
        if (verbose) {
            print_spi_type();
            printf("Good whoami returned expected %x\n", ret);
        }
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
    spi_transfer16(0x2077);                     // Write ODR in CTRL_REG1 (Addr 0x20)
    io->led = 0xfd;
    spi_transfer16(0x1fc0);                     // Enable temperature sensor (Addr 0x1F)
    io->led = 0xfb;
    unsigned short ctrl_reg4 = 0x2388;          // Enable BDU, High resolution (Addr 0x23)
#ifdef SPI3WIRE
    if (get_spi3w()) {
        ctrl_reg4 |= 1;          // preserve SIM=1
    }
#endif
    spi_transfer16(ctrl_reg4);
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
    print_spi_type();
    printf("Test OK.\n");  // The ">" ends the simulation early
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
        set_divcoef(0); // set maximal speed for simulation
#ifdef SPI3WIRE
        for (int i = 0; i < 2; i++) {
        set_spi3w(i);
#endif
        simu();
#ifdef SPIBB
        set_bb(1);
        simu();
        set_bb(0);
#endif
#ifdef SPI3WIRE
        }
#endif
        printf(">");  // The ">" ends the simulation early
    }

    unsigned t=0,t0=0;
    printf("Welcome to DarkRISCV!\n\n");
    if (!check_sensor()) {
        sensor();
    }
    // main loop
    while(1) {
        char buffer[128];
        memset(buffer,0,sizeof(buffer));
        t = io->timeus;
        printf("%d> ",t-t0);
        gets(buffer,sizeof(buffer));
#define NARGS 64
        char *argv[NARGS];
        memset((void*)argv,0,sizeof(argv));
        int argc;
        for(argc=0;argc<NARGS && (argv[argc]=strtok(argc==0?buffer:NULL," "));argc++);
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
                    int val = xtoi(argv[1]);
                    io->oport = val;
                    int ret = io->iport;
                    printf("oport = %x => ", val);
                    printf("iport = %x\n", ret);
                }
            } else if (!strcmp("read", argv[0])) {
                unsigned short ret = sensor_read();
                printf("%s: ret=%x\n", __func__, ret);
#ifdef SPIBB
            } else if (!strcmp("bb", argv[0])) {
#define BBMAX NARGS
#define READ_BIT 0
                unsigned char bbs[BBMAX];
                int nbb = 0;
                while (argv[nbb + 1]) {
                    if (nbb >= BBMAX) break;
                    bbs[nbb] = xtoi(argv[nbb + 1]);
                    nbb++;
                }
                unsigned int ret = 0;
                unsigned char last = -1;
                for (int i = 0; i < nbb; i++) {
                    if (READ_BIT == bbs[i]) {
                        spibb_waste_time(3);
                    } else {
                        spibb_write_rd_tr_oe_es_cl_di_(bbs[i]);
                    }
                    if ((READ_BIT == last) || (!(last & 2) && (bbs[i] & 2))) {
                        ret = (ret << 1) | spibb_read_do_();
                    }
                    last = bbs[i];
                }
                unsigned short ret_ = ((ret >> 8) & 0xff) | ((ret & 0xff) << 8);
                printf("%x\n", ret_);
            } else if (!strcmp("spi16", argv[0])) {
                if (argv[1]) {
                    int val = xtoi(argv[1]);
                    int ret = spi_transfer16(val) & 0xff;
                    printf("spi16 %x returned %x\n", val, ret);
                }
            } else if (!strcmp("set_bb", argv[0])) {
                if (argv[1]) {
                    int active = atoi(argv[1]);
                    //printf("set bb_active=%x\n", active);
                    set_bb(active);
                }
            } else if (!strcmp("get_bb", argv[0])) {
                printf("bb_active = %x\n", get_bb());
            } else if (!strcmp("get_verbose", argv[0])) {
                printf("verbose = %x\n", verbose);
            } else if (!strcmp("set_verbose", argv[0])) {
                if (argv[1]) {
                    int val = atoi(argv[1]);
                    verbose = val;
                }
#endif
#ifdef SPI3WIRE
            } else if (!strcmp("set_spi3w", argv[0])) {
                if (argv[1]) {
                    int active = atoi(argv[1]);
                    set_spi3w(active);
                }
            } else if (!strcmp("get_spi3w", argv[0])) {
                printf("spi3w = %x\n", get_spi3w());
#endif
            } else if (!strcmp("set_divcoef", argv[0])) {
                if (argv[1]) {
                    int divcoef = atoi(argv[1]);
                    set_divcoef(divcoef);
                }
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
