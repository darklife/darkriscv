tcSPCmin=100ns 10MHz
tsuCSmin=5 thCSmin=20
tsuSImin=5 thSImin=15
tvSOmax=50 thSOmin=5 

IPORT= out_x_resp, 11'b0, MISO, spibb_ena, CSN, SCK, MOSI
OPORT= out_x_resp, miso, ena, csn, sck, mosi

WHOAMI:
                OCCD            out_x_resp, 11'b0, MISO, spibb_ena, CSN, SCK, MOSI
                ESLI
7 f b 9 b 8 a 8 a 8 a 9 b 9 b 9 b 9 b  9 b 9 b 9 b 9 b 9 b 9 b 9 b 9 b f 7
0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1  0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 1 0
ioport 7    0   0111            tristate
ioport f    1   1111            SPI Idle
ioport b    1   1011            SPI Active
ioport 9    1   1001            DI0 1           CMD/REG
ioport b    1   1011            .
ioport 8    1   1000            DI1 0
ioport a    1   1010            .
ioport 8    1   1000            DI2 0
ioport a    1   1010            .
ioport 8    1   1000            DI3 0
ioport a    1   1010            .
ioport 9    1   1001            DI4 1
ioport b    1   1011            .
ioport 9    1   1001            DI5 1
ioport b    1   1011            .
ioport 9    1   1001            DI6 1
ioport b    1   1011            .
ioport 9    1   1001            DI7 1
ioport b    1   1011            .
ioport 9    0   1001            DI0 0?          SLAVE RESPONSE
ioport b    0   1011            .
ioport 9    0   1001            DI1 0?
ioport b    0   1011            .
ioport 9    1   1001            DI2 1?
ioport b    1   1011            .
ioport 9    1   1001            DI3
ioport b    1   1011            .
ioport 9    0   1001            DI4
ioport b    0   1011            .
ioport 9    0   1001            DI5
ioport b    0   1011            .
ioport 9    1   1001            DI6
ioport b    1   1011            .
ioport 9    1   1001            DI7
ioport b    1   1011            .
ioport f    1   1111            SPI Idle
ioport 7    0   0111            tristate

READ: (OUT_X)
                OCCD            out_x_resp, 11'b0, MISO, spibb_ena, CSN, SCK, MOSI
                ESLI
7 f b 9 b 9 b 9 b 8 a 9 b 8 a 8 a 8 a  8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a 8 a f 7
0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1  1 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 0 ret=0a30 (3fffe1e000198)
