#!/bin/bash

WORD=4
#SRC=four.bin;DST=four.mif
SRC=memory_init.bin;DST=memory_init.mif
srec_cat $SRC -binary -byte-swap 4 -o $DST -mif $WORD
