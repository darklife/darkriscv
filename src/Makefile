# Copyright (c) 2018, Marcelo Samsoniuk
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
## Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
## Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
## Neither the name of the copyright holder nor the names of its
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

#CROSS = riscv-elf
#CCPATH = /usr/local/share/toolchain-$(CROSS)/bin

CROSS = riscv32-unknown-elf
CCPATH = /usr/local/share/gcc-$(CROSS)/bin/

    CC = $(CCPATH)/$(CROSS)-gcc
    AS = $(CCPATH)/$(CROSS)-as
    LD = $(CCPATH)/$(CROSS)-ld
    OC = $(CCPATH)/$(CROSS)-objcopy
    OD = $(CCPATH)/$(CROSS)-objdump

CFLAGS = -Wall # -O3 -fomit-frame-pointer -march=rv32i
AFLAGS = 
LFLAGS = -Ttext=0 -Map=$(PROJ).map
OFLAGS = -O binary
DFLAGS = -d

PROJ = darksocv
OBJS = boot.o hello.o

all:
	make $(PROJ).hex

clean:
	-rm *.s *.o $(PROJ).{bin,hex,lst,map}

%.o: %.c
	$(CC) $(CFLAGS) -S $< # -o $@.s
	$(CC) $(CFLAGS) -c $< # -o $@

$(PROJ).o: $(OBJS)
	$(LD) $(LFLAGS) $(OBJS) -o $@

$(PROJ).bin: $(PROJ).o
	$(OC) $(OFLAGS) $< $@
	$(OD) $(DFLAGS) $< > $(PROJ).lst

$(PROJ).hex: $(PROJ).bin
	hexdump -ve '1/4 "%08x\n"' $< > $@
