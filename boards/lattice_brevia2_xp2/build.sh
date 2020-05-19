#!/bin/sh

# Simple script to invoke diamondc - the Lattice Diamond TCL console


DIAMOND_PATH=/usr/local/diamond/3.11_x64

export TEMP=/tmp
export LSC_INI_PATH=""
export LSC_DIAMOND=true
export TCL_LIBRARY=$DIAMOND_PATH/tcltk/lib/tcl8.5
export FOUNDRY=$DIAMOND_PATH/ispFPGA
export PATH=$FOUNDRY/bin/lin64:"$PATH"
$DIAMOND_PATH/bin/lin64/diamondc darksocv.tcl 2>&1 | tee darksocv_build.log
