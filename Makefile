#
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
#
# ===8<--------------------------------------------------------- cut here!
#
# This the root makefile and the function of this file is call other
# makefiles. Of course, you need first set the GCC compiler path/name, the
# simulator path/name and the board model:
#
   ARCH = rv32e
#  ARCH = rv32i
#ENDIAN = _le
#ENDIAN = _be
#HARVARD = 1
# CROSS = riscv-elf
# CROSS = riscv32-unknown-elf
# CROSS = riscv32-embedded-elf
  CROSS = riscv32-embedded$(ENDIAN)-elf
#CCPATH = /usr/local/share/toolchain-$(CROSS)/bin
 CCPATH = /usr/local/share/gcc-$(CROSS)/bin/
 ICARUS = /usr/local/bin/iverilog
#BOARD  = avnet_microboard_lx9
#BOARD  = xilinx_ac701_a200
#BOARD  = qmtech_sdram_lx16
#BOARD  = lattice_brevia2_xp2 
#BOARD = piswords_rs485_lx9
#BOARD = digilent_spartan3_s200
BOARD = aliexpress_hpc40gbe_k420

# now you can just type 'make'

ifdef HARVARD
	MTYPE = HARVARD=1
	ROM = src/darksocv.rom.mem                  # requires gcc for riscv
	RAM = src/darksocv.ram.mem                  # requires gcc for riscv
else	
	MEM = src/darksocv.mem
endif
	
SIM = sim/darksocv.vcd                      # requires icarus verilog 
BIT = tmp/darksocv.bit                      # requires FPGA build tool

default: all

all:
	make -C src all             CROSS=$(CROSS) CCPATH=$(CCPATH) ARCH=$(ARCH) $(MTYPE)
	make -C sim all             ICARUS=$(ICARUS) $(MTYPE)
	make -C boards all          BOARD=$(BOARD) $(MTYPE)

install:
	make -C boards install      BOARD=$(BOARD)

clean:
	make -C src clean
	make -C sim clean
	make -C boards clean        BOARD=$(BOARD)
