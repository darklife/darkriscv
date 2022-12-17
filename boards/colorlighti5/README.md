Just use yosys/nextpnr-ecp5
---------------------------

download toolchain from https://github.com/YosysHQ/oss-cad-suite-build/releases
You can change the frequency with the pll_ref_25MHz.v (accepted fmax hardwired).
Use config.vh to adjust fmax via BOARD_CK.
