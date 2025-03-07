#!/bin/bash

SRC=memory_init.mem;DST=memory_init.bin
awk '{print substr($0, 7, 2) substr($0, 5, 2) substr($0, 3, 2) substr($0, 1, 2)}' $SRC | xxd -r -p > $DST
