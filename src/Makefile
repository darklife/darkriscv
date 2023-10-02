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

# Add your application here:

APPLICATION = darkshell
#APPLICATION = coremark
#APPLICATION = badapple
#APPLICATION = mandelbrot

# un-select SMALL for coremark!
export SMALL = 1# uncomment for smaller firmware

SHELL := /bin/bash

ifndef HOST_CC
    HOST_CC = gcc
    HOST_CFLAGS = -Wall -Wno-incompatible-library-redeclaration -I../common -O2
endif

ifndef CROSS

    export ARCH = rv32e
    #ARCH = rv32i
    
    export ABI = ilp32e
    #ABI = ilp32
    
    #TODO: better way to switch little/big-endian:
    #ENDIAN = _le # gcc for little-endian
    #ENDIAN = _be # gcc for big-endian

    #export CROSS = riscv32-unknown-elf
    export CROSS = riscv32-embedded$(ENDIAN)-elf
    #CROSS = riscv-elf
    #CROSS = riscv32-unknown-elf
    #CROSS = riscv32-embedded-elf
    
    #export CCPATH = /opt/riscv/bin
    export CCPATH = /usr/local/share/gcc-$(CROSS)/bin/
    #CCPATH = /usr/local/share/toolchain-$(CROSS)/bin
    #HARVARD = 1
endif

ifndef BUILD
    BUILD = $(shell date -R)
endif

ifndef DARKLIBC
    DARKLIBC = darklibc
endif

    CC  = $(CCPATH)/$(CROSS)-gcc
    AS  = $(CCPATH)/$(CROSS)-as
    RL = $(CCPATH)/$(CROSS)-ranlib
    LD  = $(CCPATH)/$(CROSS)-ld
    OC  = $(CCPATH)/$(CROSS)-objcopy
    OD  = $(CCPATH)/$(CROSS)-objdump
    CPP = $(CCPATH)/$(CROSS)-cpp

CCFLAGS = -Wall -fcommon -ffreestanding -O2
CCFLAGS += -march=$(ARCH) -mabi=$(ABI) -I$(DARKLIBC)/include
CCFLAGS += -D__RISCV__ -DBUILD="\"$(BUILD)\"" -DARCH="\"$(ARCH)\""
ASFLAGS = -march=$(ARCH)
LDFLAGS = -T$(PROJ).ld -Map=$(PROJ).map -m elf32lriscv -static -gc-sections --entry=_start # -Ttext=0
LDLIBS  = $(LIBS)
CPFLAGS = -P 

CCFLAGS += -mcmodel=medany -mexplicit-relocs # relocable clode

ifdef HARVARD
	CPFLAGS +=  -DHARVARD=1
	export HARVARD
endif

OCFLAGS = -O binary # --reverse-bytes=4 # workaround for darkriscv big-endian blockrams
ODFLAGS = -D

PROJ = darksocv
LIBS = $(APPLICATION)/$(APPLICATION).a $(DARKLIBC)/$(DARKLIBC).a 
OBJS = boot.o
ASMS = boot.s
SRCS = 

ifdef SMALL
    CPFLAGS += -DSMALL=1
endif

# uncomment for hardware mul
#export MAC = 1

ifdef MAC
    CFLAGS += -DMAC=1
endif

DEPS = $(SRCS) $(ASMS) $(OBJS) $(PROJ).ld $(PROJ).lds $(LIBS)

ifdef HARVARD
	TARGETS = $(PROJ).rom.mem $(PROJ).ram.mem
else
	TARGETS = $(PROJ).mem
endif

.PHONY: all

all: $(TARGETS) $(DEPS)
	-echo build is ok for $(TARGETS)

$(DARKLIBC)/$(DARKLIBC).a:
	make -C $(DARKLIBC) all

$(APPLICATION)/$(APPLICATION).a:
	make -C $(APPLICATION) all

clean:
	make -C $(DARKLIBC) clean
	make -C $(APPLICATION) clean
	-rm -f $(OBJS) $(PROJ).{S,bin,lst,map,ram,rom,x86,text,data,bin,ld,o,mem,rom.mem,ram.mem} $(PROJ)_uart.bin

%.o: %.s Makefile
	$(AS) $(ASFLAGS) -c $< -o $@

%.s: %.c Makefile
	$(CC) $(CCFLAGS) -S $< -o $@

$(PROJ).ld: $(PROJ).lds Makefile
	$(CPP) $(CPFLAGS) $(PROJ).lds $(PROJ).ld
	
$(PROJ).o: $(OBJS) $(PROJ).ld $(LIBS)
	$(RL) $(LDLIBS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)
	$(OD) $(ODFLAGS) $@ > $(PROJ).S

$(PROJ).rom.mem: $(PROJ).o
	$(OC) $(OCFLAGS) $< $(PROJ).text --only-section .*text* 
	hexdump -ve '1/4 "%08x\n"' $(PROJ).text > $@
	#xxd -p -c 4 -g 4 $< > $@
	rm $(PROJ).text
	wc -l $@
	@echo rom ok.

$(PROJ).ram.mem: $(PROJ).o
	$(OC) $(OCFLAGS) $< $(PROJ).data --only-section .*data*
	hexdump -ve '1/4 "%08x\n"' $(PROJ).data > $@
	#xxd -p -c 4 -g 4 $< > $@
	rm $(PROJ).data
	wc -l $@
	@echo ram ok.

$(PROJ).mem: $(PROJ).o
	$(OC) $(OCFLAGS) $< $(PROJ).bin
	hexdump -ve '1/4 "%08x\n"' $(PROJ).bin > $@
	# uncomment for big-endian
	#xxd -p -c 4 -g 4 $< > $@
	dd if=$(PROJ).bin of=$(PROJ)_uart.bin skip=512 bs=1
	rm $(PROJ).bin
	# uncomment for MIF file
	#awk 'BEGIN { print "DEPTH = 1024;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN" } { printf("%08x : %s\n",NR-1,$1); } END { print "END;" }' < $(PROJ).mem > $(PROJ).mif
	wc -l $@
	@echo mem ok.
	
$(PROJ).x86: $(SRCS)
	$(HOST_CC) $(HOST_CFLAGS) $(SRCS) -o $(PROJ).x86 -DBUILD="\"$(BUILD)\"" -DARCH="\"x86\""
	@echo x86 ok.
