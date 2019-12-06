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
# The general concept is based in the article:
# 
# 	https://www.fpgarelated.com/showarticle/786.php
#
# However, since the ISE GUI itself creates a "darksocv.cmd_log" file with
# all commands executed and the respective options, it is possible change
# some options in the ISE and check the file in order to understand how
# enable/disable the different options.
# 

# board Avnet Microboard LX9
#BOARD  = avnet_microboard_lx9
#DEVICE = xc6slx9-csg324-2

# board Xilinx AC701 A200
#BOARD  = xilinx_ac701_a200
#DEVICE = xc7a200t-fbg676-2

# board QMTech SDRAM LX16
#BOARD  = qmtech_sdram_lx16
#DEVICE = xc6slx16-ftg256-2

# board Olimex iCE40HX8k-EVB
BOARD = olimex_ice40hx8k
PNR = nextpnr-ice40
#PNR = arachne-pnr

ISE = ../boards/$(BOARD)
RTL = ../rtl
SRC = ../src
TMP = ../tmp

BLIF = $(TMP)/darksocv.blif
JSON = $(TMP)/darksocv.json
PCF = $(ISE)/darksocv.pcf
ASC = $(TMP)/darksocv.asc
BIT = $(TMP)/darksocv.bit

PRJS = $(ISE)/darksocv.prj
RTLS = $(RTL)/darksocv.v $(RTL)/darkriscv.v $(RTL)/darkuart.v $(RTL)/config.vh

ifdef HARVARD
	BOOT = $(SRC)/darksocv.rom.mem $(SRC)/darksocv.ram.mem
else
	BOOT = $(SRC)/darksocv.mem
endif

ifeq ($(PNR),nextpnr-ice40)
PNR_NEXT = 1
else
PNR_NEXT = 0
endif

default: all

$(BLIF): $(RTLS)
	yosys -q -p "read_verilog -noautowire -DOLIMEX_ICE40HX8K=1 $(RTLS); synth_ice40 -top darksocv -blif $@"

$(JSON): $(RTLS)
	yosys -q -p "read_verilog -noautowire -DOLIMEX_ICE40HX8K=1 $(RTLS); synth_ice40 -top darksocv -json $@"

$(ASC): $(if $(PNR_NEXT),$(JSON),$(BLIF))
ifeq ($(PNR_NEXT),1)
	$(PNR) --hx8k --package ct256 --pcf $(PCF) $(PNRFLAGS) --asc $@ --json $<
else
	$(PNR) -d 8k -P ct256 -p $(PCF) $(PNRFLAGS) -o $@ $<
endif

$(BIT): $(ASC)
	icepack $< $@

.PHONY: all
all: $(BIT) $(BOOT) $(RTLS)

install: $(BIT)
	iceprog $<

clean:
	-rm -v $(TMP)/*
