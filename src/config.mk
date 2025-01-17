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
    export HOST_CC = gcc
    export HOST_CFLAGS = -Wall -Wno-incompatible-library-redeclaration -I../common -O2
endif

ifndef CROSS
    export ARCH = rv32e_zicsr
    #export ARCH = rv32i
    #export ARCH = rv32e
    
    export ABI = ilp32e
    #export ABI = ilp32
    
    export ENDIAN = little
    #export ENDIAN = big

    export CROSS = riscv64-unknown-elf-
    #export CROSS = riscv32-unknown-elf-
    #export CROSS = riscv32-embedded$(ENDIAN)-elf-
    #export CROSS = riscv-elf-
    #export CROSS = riscv32-unknown-elf-
    #export CROSS = riscv32-embedded-elf-
    
    export CCPATH = /usr/local/bin
    #export CCPATH = /opt/riscv/bin
    #export CCPATH = /usr/local/share/gcc-$(CROSS)/bin/
    #export CCPATH = /usr/local/share/toolchain-$(CROSS)/bin
endif

ifndef BUILD
    export BUILD = $(shell date -R)
endif

ifndef DARKLIBC
    export DARKLIBC = darklibc
endif

    export CC  = $(CCPATH)/$(CROSS)gcc
    export AS  = $(CCPATH)/$(CROSS)as
    export RL  = $(CCPATH)/$(CROSS)ranlib
    export LD  = $(CCPATH)/$(CROSS)ld
    export OC  = $(CCPATH)/$(CROSS)objcopy
    export OD  = $(CCPATH)/$(CROSS)objdump
    export CPP = $(CCPATH)/$(CROSS)cpp

       CCFLAGS  = -Wall -fcommon -ffreestanding -Os -fno-delete-null-pointer-checks -m$(ENDIAN)-endian
       CCFLAGS += -march=$(ARCH) -mabi=$(ABI) -I$(DARKLIBC)/include
       CCFLAGS += -D__RISCV__ -DBUILD="\"$(BUILD)\"" -DARCH="\"$(ARCH)\""
export CCFLAGS += -mcmodel=medany -mexplicit-relocs # relocable clode
export ASFLAGS = -march=$(ARCH)

ifdef ENDIAN==big
    export LDFLAGS = -T$(PROJ).ld -Map=$(PROJ).map -m elf32briscv -static -gc-sections --entry=_start # -Ttext=0
else
    export LDFLAGS = -T$(PROJ).ld -Map=$(PROJ).map -m elf32lriscv -static -gc-sections --entry=_start # -Ttext=0
endif

export LDLIBS  = $(LIBS)
export CPFLAGS = -P 
export OCFLAGS = -O binary # --reverse-bytes=4 # workaround for darkriscv big-endian blockrams
export ODFLAGS = -D
export ARFLAGS = -rcs

# uncomment for hardware mul
#export MAC = 1

ifdef MAC
    CFLAGS += -DMAC=1
endif
