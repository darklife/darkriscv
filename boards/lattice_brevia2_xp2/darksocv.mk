#
# Copyright (c) 2020, Ivan Vasilev <ivan@zmeiresearch.com>
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

# board LatticeXP2 Brevia 2
BOARD  = lattice_brevia2_xp2
DEVICE = LFXP2-5E-6TN144C
DIAMOND_PATH=/usr/local/diamond/3.11_x64
IMPL = impl1
TMP = ../tmp


# Expected by Lattice Diamond
export TEMP=../tmp
export LSC_INI_PATH=""
export LSC_DIAMOND=true
export TCL_LIBRARY=$(DIAMOND_PATH)/tcltk/lib/tcl8.5
export FOUNDRY=$(DIAMOND_PATH)/ispFPGA
export PATH:=$(FOUNDRY)/bin/lin64:${PATH}


RTL = ../rtl
SRC = ../src
BIT = $(TMP)/darksocv.bit

RTLS = $(RTL)/darksocv.v $(RTL)/darkriscv.v $(RTL)/darkuart.v $(RTL)/config.vh

ifdef HARVARD
	BOOT = $(SRC)/darksocv.rom.mem $(SRC)/darksocv.ram.mem
else
	BOOT = $(SRC)/darksocv.mem
endif

default: build

$(BIT): $(BOOT) $(RTLS)
	echo PATH: $$PATH
	cd $(BOARD) && $(DIAMOND_PATH)/bin/lin64/diamondc darksocv.tcl 2>&1 | tee darksocv_build.log
	cp $(BOARD)/$(IMPL)/darksocv_impl1.jed $(BIT)

clean:
	-rm -v $(TMP)/*
	rm -rf $(BOARD)/$(IMPL)
