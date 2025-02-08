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

include ../config.mk

CFLAGS += -Iinclude

PROJ = darklibc
OBJS = stdio.o io.o string.o misc.o unistd.o util.o #small.o # start.o
ASMS = stdio.s io.s string.s misc.s unistd.s
SRCS = stdio.c io.c string.c misc.c unistd.c util.s #small.s # start.s

DEPS = $(SRCS) $(ASMS) $(OBJS)

TARGETS = $(PROJ).a

.PHONY: all

all: $(DEPS) $(TARGETS)
	@echo sources ok for $(TARGETS).

clean:
	-rm -f $(ASMS) $(OBJS) $(PROJ).{S,bin,lst,map,ram,rom,x86,text,data,bin,ld,o,mem,rom.mem,ram.mem,a}

%.o: %.s Makefile
	$(AS) $(ASFLAGS) -c $< -o $@

%.s: %.c Makefile
	$(CC) $(CFLAGS) -S $< -o $@

%.a: $(OBJS) Makefile
	$(AR) $(ARFLAGS) $@ $(OBJS)
	$(RL) $@
