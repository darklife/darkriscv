# Copyright (c) 2018, Marcelo Samsoniuk
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

SHELL := /bin/bash

ifndef HOST_CC
    HOST_CC = gcc
    HOST_CFLAGS = -Wall -Wno-incompatible-library-redeclaration -I./include -O2
endif

ifndef CROSS

    ARCH = rv32e
    # ARCH = rv32i

    ABI = ilp32e
    #ABI = ilp32
    
    #TODO: better way to switch little/big-endian:
    #ENDIAN = _le # gcc for little-endian
    #ENDIAN = _be # gcc for big-endian

    CROSS = riscv32-embedded$(ENDIAN)-elf
    #CROSS = riscv-elf
    #CROSS = riscv32-unknown-elf
    #CROSS = riscv32-embedded-elf
    
    CCPATH = /usr/local/share/gcc-$(CROSS)/bin/
    #CCPATH = /opt/riscv32-gcc/bin/
    #CCPATH = /usr/local/share/toolchain-$(CROSS)/bin
    #HARVARD = 1
endif

ifndef BUILD
    BUILD = $(shell date -R)
endif

ifndef DARKLIBC
    DARKLIBC = ../darklibc
endif

    CC = $(CCPATH)/$(CROSS)-gcc
    AS = $(CCPATH)/$(CROSS)-as
    LD = $(CCPATH)/$(CROSS)-ld
    AR = $(CCPATH)/$(CROSS)-ar
    RL = $(CCPATH)/$(CROSS)-ranlib
    OC = $(CCPATH)/$(CROSS)-objcopy
    OD = $(CCPATH)/$(CROSS)-objdump
   CPP = $(CCPATH)/$(CROSS)-cpp

DFLAGS_STR = -DFLAGS_STR=\""-O2 -DPERFORMANCE_RUN=1"\"

CCFLAGS = -Wall -fcommon -ffreestanding -O2 
CCFLAGS += -I. -I./src -I$(DARKLIBC)/include $(DFLAGS_STR) -DITERATIONS=4000 -DPERFORMANCE_RUN=1 
CCFLAGS += -march=$(ARCH) -mabi=$(ABI) -D__RISCV__ -DBUILD="\"$(BUILD)\"" -DARCH="\"$(ARCH)\""
ASFLAGS = -march=$(ARCH)
LDFLAGS = -Map=$(PROJ).map -m elf32lriscv # -Ttext=0 -T$(PROJ).ld
CPFLAGS = -P 

CCFLAGS += -mcmodel=medany -mexplicit-relocs # relocable clode

ifdef HARVARD
	CPFLAGS +=  -DHARVARD=1
endif

OCFLAGS = -O binary # --reverse-bytes=4 # workaround for darkriscv big-endian blockrams
ODFLAGS = -D

PROJ = coremark
OBJS = ./src/core_main.o ./src/core_matrix.o ./src/core_list_join.o ./src/core_state.o ./src/core_util.o core_portme.o ee_printf.o 
ASMS = ./src/core_main.s ./src/core_matrix.s ./src/core_list_join.s ./src/core_state.s ./src/core_util.s core_portme.s ee_printf.s 
SRCS = ./src/core_main.c ./src/core_matrix.c ./src/core_list_join.c ./src/core_state.c ./src/core_util.c core_portme.c ee_printf.c 

DEPS = $(SRCS) $(ASMS) $(OBJS) Makefile

TARGETS = $(PROJ).a

.PHONY: all

all: $(TARGETS) $(DEPS)
	@echo sources ok.

clean:
	-rm -f $(ASMS) $(OBJS) $(PROJ).{a,S,bin,lst,map,ram,rom,x86,text,data,bin,ld,o,mem,ram.mem,rom.mem}

%.o: %.s Makefile
	$(AS) $(ASFLAGS) -c $< -o $@

%.s: %.c Makefile
	$(CC) $(CCFLAGS) -S $< -o $@

$(PROJ).a: $(OBJS) Makefile
	$(AR) $(ARFLAGS) $@ $(OBJS)
	#$(RL) $@
	
$(PROJ).x86: $(SRCS)
	$(HOST_CC) $(HOST_CFLAGS) $(SRCS) -o $(PROJ).x86 -DBUILD="\"$(BUILD)\"" -DARCH="\"x86\""
	@echo x86 ok.
