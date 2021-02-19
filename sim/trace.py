#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from vcdvcd import VCDVCD

import subprocess
import sys
import getopt

class Error(Exception):
    """addr2line exception."""

    def __init__(self, str):
        Exception.__init__(self, str)

class addr2line:
    def __init__(self, binary, addr2line = "/opt/riscv32e/bin/riscv32-unknown-elf-addr2line"):
        self.process = subprocess.Popen(
            [addr2line, "-e", binary],
            stdin = subprocess.PIPE,
            stdout = subprocess.PIPE)

    def lookup(self, addr):
        dbg_info = None
        try:
            self.process.stdin.write((addr + "\n").encode('utf-8'))
            self.process.stdin.flush()
            dbg_info = self.process.stdout.readline().decode("utf-8") 
            dbg_info = dbg_info.rstrip("\n")
        except IOError:
            raise Error(
                "Communication error with addr2line.")
        finally:
            ret = self.process.poll();
            if ret != None:
                raise Error(
                    "addr2line terminated unexpectedly (%i)." % (ret))
            
        return dbg_info

# Do the parsing.
vcd = VCDVCD('darksocv.vcd')

# Get a signal by human readable name.
signal = vcd['darksimv.darksocv.core0.PC[31:0]']

tv = signal.tv

cache = {}
a2l = addr2line("../src/darksocv.o")

for x in tv:
    time = x[0]
    if 'x' in x[1]:
        pc = x[1]
        line = "undef"
    else:
        pc = hex(int(str(x[1]), 2))     # get a hex string out of pc
        if pc in cache:
            line = cache[pc]
        else:
            line = a2l.lookup(pc)
            cache[pc] = line

    print( f'{time:>12}' + ":" + f'{pc:>10}' + ":" + line)


