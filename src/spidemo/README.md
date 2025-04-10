# SPI Demo
This SPI demo was written for the max1000_max10 board and its builtin SPI accelerometer sensor (refer to boards/max1000_max10/README.md).

Note however that this application can be simulated without any hardware, using a custom accelerometer stub:
```shell
make clean all APPLICATION=spidemo
gtkwave rtl/lib/spi/darksocv.gtkw &
```

# Python helper
A python helper (tailored for spi/bb stuff) is provided to easily interact with the darkriscv/fpga shell serial port (`/dev/ttyUSB?`).
Following examples assume that APPLICATION=spidemo has been built/installed.
Eg: Set Bit-Banging off, Check WHOAMI then read OUT_X SPI register:
```shell
$ ./ser.py "set_bb 0" whoami read
Good HW whoami returned expected 33
main: ret=70
```
Eg: Set Bit-Banging on, Check WHOAMI then bit-bang-read OUT_X SPI register:
```shell
$ ./ser.py "set_bb 1" "bb 7 f b 9 b 9 b 9 b 8 a 9 b 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a f 7"
Good BB whoami returned expected 33
val=80
```
