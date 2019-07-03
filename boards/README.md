## Add your board here! o/

Use the AVNET Microboard LX9 as template, since is the best tested board at this
moment, as long I can plug it in the computer and test it in less than five
minutes:

    cp -rp avnet_micrboard_lx9 vendor_board_fpga

In the case of Vivado, the easy way is use an ISE board AC701 w/ Artix-7 as
template, convert it to Vivado and then change it for the desired target
(for example, an Spartan-7).

Current board status:

    avnet_microboard_lx9    fully tested
    qmtech_sdram_lx16       build ok
    xilinx_ac701_a200       build ok

I am working in a way to make the directory structure better, but it is not
so easy make everything work at the same time!  :)

Proposed structure:

    boards/vendor_boardname_fpga/               top level directory
    boards/vendor_boardname_fpga/darksocv.mk    top level makefile
    boards/vendor_boardname_fpga/darksocv.*     other configuration files

In this directory is possible:

    make BOARD=avnet_microboard_lx9 all         # build fpga for $BOARD
    make install                                # program fpga

Of course, the FPGA programming via JTAG depends of some configurations
which are different in different environments.
