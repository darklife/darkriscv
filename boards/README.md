## Add your board here! o/

Use the AVNET Microboard LX9 as template, since is the best tested board at this
moment, as long I can plug it in the computer and test it in less than five
minutes:

    cp -rp avnet_micrboard_lx9 vendor_board_fpga

In the case of Vivado, the easy way is use the QMTech Spartan-7 board as
template. In the case of Vivado, there is no automation as found in the
other FPGAs.

Current supported board/FPGAs:

    avnet_microboard_lx9
    qmtech_sdram_lx16
    qmtech spartan7 s15
    xilinx_ac701_a200
    lattice brevia2 lxp2
    piswords rs485 lx9

I am working in a way to make the directory structure better, but it is not
so easy make everything work at the same time! :)

Proposed structure:

    boards/vendor_boardname_fpga/               top level directory
    boards/vendor_boardname_fpga/darksocv.mk    top level makefile
    boards/vendor_boardname_fpga/darksocv.*     other files (board/fpga specific)

In the current directory is possible set:

    make BOARD=avnet_microboard_lx9 all         # build fpga for $BOARD
    make install                                # program fpga

Of course, the FPGA programming via JTAG depends of some configurations
which are different in different environments. Please check the README file
regarding the board!
