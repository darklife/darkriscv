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

SRCS += 	../../rtl/darksocv.v \
		../../rtl/darkpll.v \
		../../rtl/darkram.v \
		../../rtl/darkbridge.v \
		../../rtl/darkriscv.v \
		../../rtl/darkio.v \
		../../rtl/darkuart.v \
		pll_ref_25MHz.v


all: darksocv.bit
	echo darksocv.bit done, type \"make install\" to upload to the FPGA... 

darksocv.json: $(SRCS)
	echo building darksocv.json with yosys...
	yosys -D __YOSYS__ -D LATTICE_ECP5_ULX3S -p "synth_ecp5 -json darksocv.json -top darksocv" $(SRCS)

darksocv.bit: darksocv.json
	echo routing with nextpnr...
	nextpnr-ecp5 --lpf-allow-unconstrained --timing-allow-fail --json darksocv.json --textcfg darksocv.cfg --85k --package CABGA381 --speed 6 --lpf darksocv.lpf
	ecppack --compress --input darksocv.cfg --bit darksocv.bit

upload:
	echo uploading darksocv.bit to FPGA...
	openFPGALoader --board=ulx3s darksocv.bit

clean:
	rm -f darksocv.cfg  darksocv.json
