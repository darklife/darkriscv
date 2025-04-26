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

#ifndef __IO__
#define __IO__

extern volatile int utimers; // microsecond timer

struct DARKIO {

    unsigned char board_id; // 00
    unsigned char board_cm; // 01
    unsigned char core_id;  // 02
    unsigned char irq;      // 03

    struct DARKUART {
        
        unsigned char  stat; // 04
        unsigned char  fifo; // 05
        unsigned short baud; // 06/07

    } uart;

    unsigned int led;        // 08
    unsigned int timer;      // 0c
    unsigned int timeus;     // 10
    unsigned int iport;      // 14
    unsigned int oport;      // 18

    struct DARKSPI {
        union {
            unsigned char  spi8;  // 1c                              r: {data}
            unsigned short spi16; // 1c/1d       w: {cmd,data}       r: {dlo,dhi}
            unsigned int   spi32; // 1c/1d/1e/1f w: {00,cmd,dlo,dhi} r: {status,00,dlo,dhi}
        };
    } spi;

};

extern volatile struct DARKIO *io;

extern char *board_name(int);

#ifdef __RISCV__
#define kmem 0
#else
extern unsigned char kmem[8192];
#endif

#define IRQ_TIMR 0x80
#define IRQ_UART 0x02

int  check4rv32i(void);

void set_stvec(void *f);
void set_mtvec(void *f);
void set_sepc(void *);
void set_mepc(void *);
void set_mie(int);
void set_mstatus(int);
void set_sp(int);
void set_pc(int);
void reboot(int,int);

void *get_mtvec(void);
void *get_stvec(void);
void *get_mepc(void);
void *get_sepc(void);

int  get_mie(void);
int  get_mcause(void);
int  get_scause(void);
int  get_mhartid(void);
int  get_mstatus(void);

long long get_mcycle(void);
long long get_minstret(void);

void banner(void);

__attribute__ ((interrupt ("machine")))    void irq_handler(void);
__attribute__ ((interrupt ("supervisor"))) void dbg_handler(void);

extern unsigned _text;
extern unsigned _data;
extern unsigned _etext; 
extern unsigned _edata; 
extern unsigned _stack;

#define EBREAK asm("ebreak")

#endif
