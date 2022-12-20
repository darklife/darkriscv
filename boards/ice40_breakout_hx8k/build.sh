rm -f darksocv.asc  darksocv.json darksocv.asc darksocv.bit
yosys -D __YOSYS__ -D LATTICE_ICE40_BREAKOUT_HX8K -p "synth_ice40 -json darksocv.json -top darksocv" ../../rtl/darksocv.v ../../rtl/darkriscv.v ../../rtl/darkuart.v pll.v
nextpnr-ice40 -r --hx8k --timing-allow-fail --json darksocv.json --asc darksocv.asc --package ct256 --pcf darksocv.pcf
icepack -s darksocv.asc darksocv.bit
