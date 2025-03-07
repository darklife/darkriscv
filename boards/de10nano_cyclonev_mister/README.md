# DE10-Nano board (Terasic) / MiSTer

## General information
The DE10-Nano board is a robust development board based on Intel/Altera Cyclone V family of FPGAs.\
It has an Intel Cyclone® V SE 5CSEBA6U23I7 device (110K LEs) and also includes the following peripherals:
* 64Mbit Flash Memory (EPCS64)
* 800MHz Dual-core ARM Cortex-A9 processor (HPS)
* 1GB DDR3 SDRAM (32-bit data bus, HPS)
* 1 Gigabit Ethernet PHY with RJ45 connector (HPS)
* USB-Blaster II onboard for programming; JTAG Mode
* HDMI TX, compatible with DVI 1.0 and HDCP v1.4
* 8 LEDs + 2 push-buttons
* Three 50 MHz clock sources
* Many headers: 40pins, Arduino R3, JTAG..
* And more..

NOTE: This Darkriscv port targets/integrates the MiSTer framework around the DE10-Nano.
Some of their files are licensed under GPL v2+ (See LICENSE).

For more detailed information, see here:\
https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=1046

https://github.com/MiSTer-devel/Wiki_MiSTer/wiki

The DarkRISCV/darksoc builds out-of-the box using Quartus command-line,
taking about ~10% of the on-chip logic for the SoC demo (including Mister resources).
- It uses an altera pll QIP to transform 50MHz into several freqs for MiSTer (TODO: maybe integrate it into darkpll),
- and a simplified darkram based on altsyncram to properly infer BRAM (TODO: maybe integrate it into darkram).

## Instructions
Install Quartus with Cyclone V support, `srecord`, `awk`, `xxd`.\
Read/apply the Terasic docs to enable the cyclone V support (eg: udev rules, ftdi driver etc..)\
Ensure that `QUARTUS` macro defined in `boards/de10nano_cyclonev_mister/darksocv.mk` points to your Quartus install, then, from darkriscv root directory:\
Build the bitstream:
```
make all BOARD=de10nano_cyclonev_mister
```
To program the device, you must transfer the resulting `boards/de10nano_cyclonev_mister/output_files/darkriscv_de10nano.rbf` to your device
and program it using the MiSTer menu.
One way to do this is to copy the RBF to your MiSTer via Ethernet, or using an USB stick.

Finally to connect to the serial port, first ensure that the VT52 core SerialPort=ConsolePort;
then you can use `screen` on the MiSTer via ssh:
```
TERM=linux ssh -t root@<MiSTer_IP_Address> screen /dev/ttyS1 115200
```
and you should see DarkRISCV booting up:
```
...
board: de10nano cyclonev mister (id=20)
...
36253> led aa55
led = aa55
1>
```
You should see DEBUG on upper 4 leds, and LED on the lower ones.

To clean the board-related objects:
```
make clean BOARD=de10nano_cyclonev_mister
```
