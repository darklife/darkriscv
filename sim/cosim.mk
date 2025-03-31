# Copyright (c) 2025, Nicolas Sauzede <nicolas.sauzede@gmail.com>
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

VLATOR:=verilator
ifneq (0, $(shell command -v $(VALGRIND) > /dev/null 2>&1 ; echo $$?))
VLATOR:=
endif

ifdef VLATOR
DUT?=dut
VDUT=V$(DUT)
V_SRC=$(COSIM_SRC)
GUI_C_SRC:=$(VDUT)_gui.cpp
GUI_VCD_FILE:=$(VDUT)_gui.vcd
GUI_CFLAGS:=-I/usr/include/imgui `sdl2-config --cflags`
GUI_LDFLAGS:=`sdl2-config --libs` -lGLEW -lGL -limgui -O3
VOPT+=--trace
#VOPT+=--timing
#VOPT+=--timing
VOPT+=-Wno-PINMISSING
VOPT+=-Wno-WIDTHTRUNC
VOPT+=-Wno-WIDTHEXPAND
VOPT+=-Wno-CASEX
VOPT+=-Wno-CASEINCOMPLETE
VOPT+=-Wno-REALCVT
VOPT+=-O3 -CFLAGS "-O3" --x-assign fast --x-initial fast --noassert --Wno-MULTIDRIVEN
CC_OPT := -O3
TOP_MODULE=--top-module $(DUT)
GUI_DIR=tmp_gui
VOUT:=./$(GUI_DIR)/$(VDUT).cpp

%.cosim: ./$(GUI_DIR)/$(VDUT)
#	echo "COSIM!!!! STEM=$* TGT=$^"
	./$^

$(GUI_DIR)/%: $(COSIM_RTLS)
#	echo "VLATOR!!!! STEM=$* TGT=$@"
	$(VLATOR) -cc $(VOPT) -LDFLAGS "$(GUI_LDFLAGS) " --Mdir $(@D) -exe $(TOP_MODULE) -CFLAGS $(GUI_CFLAGS) $(V_SRC) $(GUI_C_SRC) -O3

#./$(GUI_DIR)/$(VDUT):  $(GUI_C_SRC)
./$(GUI_DIR)/$(VDUT): $(VOUT) $(GUI_DIR)/$(GUI_C_SRC)
#	echo "MAKE!!!! STEM=$* TGT=$@"
	(cd $(GUI_DIR); make -f $(VDUT).mk CFLAGS=-O3 LDFLAGS=-O3 CXXFLAGS="-O3 -DVCD_FILE='\"$(GUI_VCD_FILE)\"'")
endif
