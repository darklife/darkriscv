rm -f darksocv.cfg  darksocv.json
yosys -D __YOSYS__ -D LATTICE_ECP5_COLORLIGHTI5 -p "synth_ecp5 -json darksocv.json -top darksocv" ../../rtl/darksocv.v ../../rtl/darkriscv.v ../../rtl/darkuart.v pll_ref_25MHz.v
nextpnr-ecp5 --timing-allow-fail --json darksocv.json --textcfg darksocv.cfg --25k --package CABGA381 --speed 6 --lpf darksocv.lpf
ecppack --compress --input darksocv.cfg --bit darksocv.bit
