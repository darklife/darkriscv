## RTL Directory

The RTL directory contains the DarkRISCV core and some auxiliary files, such
as the DarkSoCV (a small system-on-chip with ROM, RAM and IO), the DarkUART
(a small UART for debug) and the configuration file, where is possible
enable and disable some features that are described in the Implementation
Notes section.

Description of RTL directory:

-rw-r--r--   1 marcelo  staff   1113 26 Apr 16:25 README.md
-rw-r--r--   1 marcelo  staff  16456 26 Apr 16:05 config.vh
-rw-r--r--   1 marcelo  staff   8294  9 Feb 15:11 darkbridge.v  
-rw-r--r--   1 marcelo  staff   6914 15 Mar 18:22 darkcache.v   
-rw-r--r--   1 marcelo  staff   7535 11 Apr 20:15 darkio.v      
-rw-r--r--   1 marcelo  staff   9717  9 Feb 15:11 darkpll.v
-rw-r--r--   1 marcelo  staff   5984 26 Apr 15:27 darkram.v
-rw-r--r--   1 marcelo  staff  29717 26 Apr 15:27 darkriscv.v
-rw-r--r--   1 marcelo  staff   9917 11 Apr 20:15 darksocv.v
-rw-r--r--   1 marcelo  staff   6003 11 Apr 20:15 darkspi.v
-rw-r--r--   1 marcelo  staff  11172 14 Sep  2024 darkuart.v
drwxr-xr-x   4 marcelo  staff    128 23 Mar 18:21 lib

The real RTL hierarchy is the following:

    darksocv -|
              |- darkpll
              |
              |- darkbridge -|
              |              |- darkriscv
              |              |
              |              |- darkcache (2x instruction)
              |
              |- darkram
              |
    
              |
              |- darkio -|
              |          |- darkuart
              |          |
              |          |- darkspi (optional)                         
              |
              |- sdram (optional)

The RTL hierarchy starts in the RTL top level, the DarkSoCV, which will
interface with the device pins and interconnect the most external buses and
interfaces. The DarkSoCV contains the DarkPLL, DarkBridge, DarkRAM, DarkIO
and the SDRAM controller (optional).

The DarkPLL is supposed to include the IP from the manufacturer with the
respective PLL or clock generator.  Case there is no IP, it will just be
skiped, so the external XCLK and XRES are connected to internal CLK and RES.

The DarkBridge is a glue logic that can operate with following modes:

    - synchronous Harvard Architecture mode: it will just wire the internal
      core buses to the external buses directly, so the entire device will
      operate with Harvard Architecture, providing the best performance
      possible. that is enabled with __HARVARD__ on config.vh.

    - asynchonous von Neumann Architecture mode: it will make the core wait
      to service the buses in a sequential way, so while the core is
      waiting, it will perform read/write data access, as well read
      instructions, in an asynchronous way, accordly to a 3 cycle bus
      interface, with idle cycle, address cycle and data cycle.  between the
      address and data, the external device can insert any number of
      wait-states.

    - mixed mode: the mixed mode will support the operation in both ways,
      thanks to L1 caches! so, when there are cache hits, the core will just
      work at the maximum speed like in the synchronous Harvard Architecture
      mode. However, case there are misses, the core will wait and work at
      the speed defined by the external buses and state machines, like in
      the asynchronous von Neumann Architecture mode.

The DarkRAM provides up to two independent buses for the system and they can
operate in lots of modes, including the synchronous Harvard Architecture
mode, as well the asynchronous von Neumann Architecture mode, with support
for programmable wait-states and read/modify/write cycles.

The DarkIO provide some basic IO, including board ID, PLL frequency,
interrupt register, programmable timer, real time clock (in microseconds),
GPIO and UART. 

Although UART is typically simple, the UART in this case is provided by the
DarkUART, which include lots of features regarding simulation debug and
performance (FIFOs).

Finally, we have the 3rd party modules: the DarkSPI and SDRAM! That modules
are stored in a separate directory, so they can keep separate licenses
and/or extra files and documentation:

  - SDRAM controller: from kianRiscV 
    https://github.com/splinedrive/kianRiscV/blob/master/linux_socs/kianv_harris_mcycle_edition/sdram/mt48lc16m16a2_ctrl.v
    note: this module is licensed under ISC license.

  - SPI controller: support for STMicroelectronics LIS3DH accelerometer+thermal sensor
    note: this moduel licensed under GPL license.

