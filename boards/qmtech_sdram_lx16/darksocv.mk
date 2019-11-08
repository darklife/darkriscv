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
BOARD  = qmtech_sdram_lx16
DEVICE = xc6slx16-ftg256-2

ISE = ../boards/$(BOARD)
RTL = ../rtl
SRC = ../src
TMP = ../tmp

XST = $(ISE)/darksocv.xst
SYR = $(TMP)/darksocv.syr
UCF = $(ISE)/darksocv.ucf
IMP = $(ISE)/darksocv.imp
NGC = $(TMP)/darksocv.ngc
NGD = $(TMP)/darksocv.ngd
PCF = $(TMP)/darksocv.pcf
NCD = $(TMP)/darksocv.ncd
TWX = $(TMP)/darksocv.twx
TWR = $(TMP)/darksocv.twr
BIT = $(TMP)/darksocv.bit
MAP = $(TMP)/darksocv_map.ncd
UT  = $(ISE)/darksocv.ut

PRJS = $(ISE)/darksocv.prj
RTLS = $(RTL)/darksocv.v $(RTL)/darkriscv.v $(RTL)/darkuart.v

ifdef HARVARD
        BOOT = $(SRC)/darksocv.rom.mem $(SRC)/darksocv.ram.mem
else
        BOOT = $(SRC)/darksocv.mem
endif

IMP  = $(ISE)/darksocv.imp

default: all

$(NGC): $(PRJS) $(BOOT) $(RTLS)
	cd $(TMP) && xst -intstyle ise -ifn $(XST) -ofn $(SYR)

$(NGD): $(NGC) $(UCF) $(BOOT) $(RTLS)
	cd $(TMP) && ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc $(UCF) -p $(DEVICE) $(NGC) $(NGD)

$(PCF): $(NGD) $(BOOT) $(UCF) $(RTLS)
	cd $(TMP) && map -intstyle ise -p $(DEVICE) -w -logic_opt on -ol high -t 1 -xt 0 -register_duplication on -r 4 -global_opt off -mt 2 -detail -ir off -ignore_keep_hierarchy -pr off -lc auto -power off -o $(MAP) $(NGD) $(PCF)

$(NCD): $(PCF) $(BOOT) $(UCF) $(RTLS)
	cd $(TMP) && par -w -intstyle ise -ol high -mt 2 $(MAP) $(NCD) $(PCF)
	cd $(TMP) && trce -intstyle ise -v 3 -s 2 -n 3 -fastpaths -xml $(TWX) $(NCD) -o $(TWR) $(PCF)

$(BIT): $(UT) $(NCD) $(BOOT) $(UCF) $(RTLS)
	cd $(TMP) && bitgen -intstyle ise -f $(UT) $(NCD)

all: $(BIT) $(BOOT) $(UCF) $(RTLS)

install: $(BIT) $(BOOT) $(UCF) $(RTLS)
	cd $(TMP) && impact -batch $(IMP)

clean:
	-rm -v $(TMP)/*
