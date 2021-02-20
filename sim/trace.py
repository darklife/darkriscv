#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from vcdvcd import VCDVCD

import subprocess
import sys
import getopt
import argparse

class Error(Exception):
    """addr2line exception."""

    def __init__(self, str):
        Exception.__init__(self, str)

class addr2line:
    def __init__(self, binary, addr2line):
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

class source_printer:
    def __init__(self):
        self.cache = {}

    def try_print_source(self, line, count):
        if (line, count) not in self.cache:
            self.cache[(line, count)] = self.__lookup(line, count)

        print(self.cache[(line, count)])


    def __lookup(self, line, count):
        source = ""

        try:
            file_name, line_number = filter(None, line.split(':'))
            line_number = line_number.split(' ', 1)[0]  # get rid of 'discriminator X' stuff
            #print(f'file: {file_name}, line: {line_number}')

            start_line_number = int(line_number)
            if count > 1:
                start_line_number = int(start_line_number - count/2)

            if start_line_number < 0:
                start_line_number = 0
            end_line_number = start_line_number + count

            # print(f'file_name: {file_name} => {start_line_number}:{end_line_number}')

            with open(file_name) as src_file:
                for i, line_content in enumerate(src_file):
                    if (start_line_number <= i and i < end_line_number):
                        source += f"{i}:{line_content}"

        except:
            pass
            # nothing to do here, error could be missing source file
            # or addr2line failing to find the PC

        finally:
            return source if source else "No Source"

class lst_lookuper:
    def __init__(self, filename):
        # read the whole listing file in memory
        with open(filename) as lst_file:
            self.lst_array = lst_file.readlines()

    def lst_lookup(self, pc):
        pcstr = " " + str(pc)[2:] + ":\t"

        asm = next((s for s in self.lst_array if pcstr in s), None)
        if not asm:
            asm = ""
        else:
            # .lst file format is:
            # <space[s]>address:<tab>binary<spaces><tab>assembly instructuon
            asm = asm.split("\t", 2)[-1]
            asm = asm.rstrip()
        return asm

# Execution starts here
parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("vcdfile", nargs='?', help = "VCD trace file", default="darksocv.vcd")
parser.add_argument("-of", "--objectfile", help="Object file to look up into", default="../src/darksocv.o")
parser.add_argument("-a2l", "--addr2line", help="addr2line executable to use", default="/opt/riscv32e/bin/riscv32-unknown-elf-addr2line")
parser.add_argument("-s", "--source", help="Print out source code line, if possible", action="store_true")
parser.add_argument("-sl", "--source_lines", help="Number of source code lines to print", default=1, type=int)
parser.add_argument("-a", "--assembly", help="Print out assembly instruction", action="store_true")
parser.add_argument("-lf", "--listing_file", help="listing file to read assembly from", default="../src/darksocv.lst")
args = parser.parse_args()

# Do the parsing.
vcd = VCDVCD(args.vcdfile)

# Get a signal by human readable name.
signal = vcd['darksimv.darksocv.core0.PC[31:0]']

tv = signal.tv

# A crude "PC"->"line" cache as addr2line calls can be expensive
cache = {}
a2l = addr2line(args.objectfile, args.addr2line)
source_printer = source_printer()
if args.assembly:
    lst_lookuper = lst_lookuper(args.listing_file)

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
            if args.assembly:
                line += " => " + lst_lookuper.lst_lookup(pc)
            cache[pc] = line

    print( f'{time:>12}' + ":" + f'{pc:>10}' + ":" + line)
    if line != "undef" and args.source:
        source_printer.try_print_source(line, args.source_lines)


