# SPI Demo
This SPI demo was written for the max1000_max10 board and its builtin SPI accelerometer sensor (refer to boards/max1000_max10/README.md).

Note however that this application can be simulated without any hardware, using a custom accelerometer stub:
```shell
make clean all APPLICATION=spidemo
gtkwave rtl/lib/spi/darksocv.gtkw &
```
