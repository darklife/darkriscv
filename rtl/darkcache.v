/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`timescale 1ns / 1ps
`include "../rtl/config.vh"

module darkcache
(
    // TBD
    
    output [3:0] DEBUG      // osciloscope
);

    // darkriscv bus interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;
    wire [31:0] IDATA;
    wire [31:0] DATAO;
    wire [31:0] DATAI;
    wire        WR,RD;
    wire [3:0]  BE;

`ifdef __FLEXBUZZ__
    wire [31:0] XATAO;
    wire [31:0] XATAI;
    wire [ 2:0] DLEN;
    wire        RW;
`endif

    wire [31:0] IOMUX [0:4];

    reg  [15:0] GPIOFF = 0;
    reg  [15:0] LEDFF  = 0;

    wire HLT;

`ifdef __ICACHE__

    // instruction cache

    reg  [55:0] ICACHE [0:63]; // instruction cache
    reg  [63:0] ITAG = 0;      // instruction cache tag

    wire [5:0]  IPTR    = IADDR[7:2];
    wire [55:0] ICACHEO = ICACHE[IPTR];
    wire [31:0] ICACHED = ICACHEO[31: 0]; // data
    wire [31:8] ICACHEA = ICACHEO[55:32]; // address

    wire IHIT = ITAG[IPTR] && ICACHEA==IADDR[31:8];

    reg  IFFX = 0;
    reg IFFX2 = 0;

    reg [31:0] ROMFF;

    always@(posedge CLK)
    begin
    `ifdef __HARVARD__
        ROMFF <= ROM[IADDR[`MLEN-1:2]];
    `else
        ROMFF <= MEM[IADDR[`MLEN-1:2]];
    `endif
        if(IFFX2)
        begin
            IFFX2 <= 0;
            IFFX  <= 0;
        end
        else
        if(!IHIT)
        begin
            ICACHE[IPTR] <= { IADDR[31:8], ROMFF };
            ITAG[IPTR]    <= IFFX; // cached!
            IFFX          <= 1;
            IFFX2         <= IFFX;
        end
    end

    assign IDATA = ICACHED;

`else

    reg [31:0] ROMFF;

    wire IHIT = 1;

    reg [31:0] ROMFF2 = 0;
    reg        HLT2   = 0;

    always@(posedge CLK) // stage #0.5
    begin
        if(HLT^HLT2)
        begin
            ROMFF2 <= ROMFF;
        end

        HLT2 <= HLT;
    end

    assign IDATA = HLT2 ? ROMFF2 : ROMFF;

    always@(posedge CLK) // stage #0.5
    begin
`ifdef __HARVARD__
        ROMFF <= ROM[IADDR[`MLEN-1:2]];
`else
        ROMFF <= MEM[IADDR[`MLEN-1:2]];
`endif
    end

    //assign IDATA = ROM[IADDR[`MLEN-1:2]];

//    always@(posedge CLK)
//    begin
//        // weird bug appears to be related to the "sw ra,12(sp)" instruction.
//        if(WR&&DADDR[31]==0&&DADDR[12]==0)
//        begin
//            ROMBUG <= IADDR;
//        end
//    end

//    assign IDATA = ROMFF;

`endif

`ifdef __DCACHE__

    // data cache

    reg  [55:0] DCACHE [0:63]; // data cache
    reg  [63:0] DTAG = 0;      // data cache tag

    wire [5:0]  DPTR    = DADDR[7:2];
    wire [55:0] DCACHEO = DCACHE[DPTR];
    wire [31:0] DCACHED = DCACHEO[31: 0]; // data
    wire [31:8] DCACHEA = DCACHEO[55:32]; // address

    wire DHIT = RD&&!DADDR[31]/*&&DADDR[`MLEN-1]*/ ? DTAG[DPTR] && DCACHEA==DADDR[31:8] : 1;

    reg   FFX = 0;
    reg  FFX2 = 0;

    reg [31:0] RAMFF;

    reg        WTAG    = 0;
    reg [31:0] WCACHEA = 0;

    wire WHIT = WR&&!DADDR[31]/*&&DADDR[`MLEN-1]*/ ? WTAG&&WCACHEA==DADDR : 1;

    always@(posedge CLK)
    begin
    `ifdef __HARVARD__
        RAMFF <= RAM[DADDR[`MLEN-1:2]];
    `else
        RAMFF <= MEM[DADDR[`MLEN-1:2]];
    `endif

        if(FFX2)
        begin
            FFX2 <= 0;
            FFX  <= 0;
            WCACHEA <= 0;
            WTAG <= 0;
        end
        else
        if(!WHIT)
        begin
            //individual byte/word/long selection, thanks to HYF!
        `ifdef __HARVARD__
            if(BE[0]) RAM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(BE[1]) RAM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(BE[2]) RAM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(BE[3]) RAM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        `else
            if(BE[0]) MEM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(BE[1]) MEM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(BE[2]) MEM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(BE[3]) MEM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        `endif
            DCACHE[DPTR][0 * 8 + 7: 0 * 8] <= BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8];
            DCACHE[DPTR][1 * 8 + 7: 1 * 8] <= BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8];
            DCACHE[DPTR][2 * 8 + 7: 2 * 8] <= BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8];
            DCACHE[DPTR][3 * 8 + 7: 3 * 8] <= BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8];

            DCACHE[DPTR][55:32] <= DADDR[31:8];

            DTAG[DPTR]   <= FFX; // cached!
            WTAG         <= FFX;

            WCACHEA      <= DADDR;

            FFX          <= 1;
            FFX2         <= FFX;
        end
        else
        if(!DHIT)
        begin
            DCACHE[DPTR] <= { DADDR[31:8], RAMFF };
            DTAG[DPTR]   <= FFX; // cached!
            FFX          <= 1;
            FFX2         <= FFX;
        end
    end

    assign DATAI = DADDR[31] ? IOMUX[DADDR[4:2]==3'b100 ? 3'b100 : DADDR[3:2]] : DCACHED;

`else

    // no cache!

    `ifdef __FLEXBUZZ__

    // must work just exactly as the default interface, since we have no
    // flexbuzz devices available yet (i.e., all devices are 32-bit now)

    assign XATAI = DLEN[0] ? ( DADDR[1:0]==3 ? DATAI[31:24] :
                               DADDR[1:0]==2 ? DATAI[23:16] :
                               DADDR[1:0]==1 ? DATAI[15: 8] :
                                               DATAI[ 7: 0] ):
                   DLEN[1] ? ( DADDR[1]==1   ? DATAI[31:16] :
                                               DATAI[15: 0] ):
                                               DATAI;

    assign DATAO = DLEN[0] ? ( DADDR[1:0]==3 ? {        XATAO[ 7: 0], 24'hx } :
                               DADDR[1:0]==2 ? {  8'hx, XATAO[ 7: 0], 16'hx } :
                               DADDR[1:0]==1 ? { 16'hx, XATAO[ 7: 0],  8'hx } :
                                               { 24'hx, XATAO[ 7: 0]        } ):
                   DLEN[1] ? ( DADDR[1]==1   ? { XATAO[15: 0], 16'hx } :
                                               { 16'hx, XATAO[15: 0] } ):
                                                 XATAO;

    assign RD = DLEN&&RW==1;
    assign WR = DLEN&&RW==0;

    assign BE =    DLEN[0] ? ( DADDR[1:0]==3 ? 4'b1000 : // 8-bit
                               DADDR[1:0]==2 ? 4'b0100 :
                               DADDR[1:0]==1 ? 4'b0010 :
                                               4'b0001 ) :
                   DLEN[1] ? ( DADDR[1]==1   ? 4'b1100 : // 16-bit
                                               4'b0011 ) :
                                               4'b1111;  // 32-bit

    `endif

    reg [31:0] RAMFF;

    // for single phase clock: 1 wait state in read op always required!

    reg [1:0] DACK = 0;

    wire WHIT = 1;
    wire DHIT = !((RD
            `ifdef __RMW_CYCLE__
                    ||WR		// worst code ever! but it is 3:12am...
            `endif
                    ) && DACK!=1); // the WR operatio does not need ws. in this config.

    always@(posedge CLK) // stage #1.0
    begin
        DACK <= RES ? 0 : DACK ? DACK-1 : (RD
            `ifdef __RMW_CYCLE__
                    ||WR		// 2nd worst code ever!
            `endif
                    ) ? 1 : 0; // wait-states
    end

    always@(posedge CLK) // stage #1.5
    begin
`ifdef __HARVARD__
        RAMFF <= RAM[DADDR[`MLEN-1:2]];
`else
        RAMFF <= MEM[DADDR[`MLEN-1:2]];
`endif
    end

    //assign DATAI = DADDR[31] ? IOMUX  : RAM[DADDR[`MLEN-1:2]];

    reg [31:0] IOMUXFF = 0;
    reg [31:0] XADDR   = 0;

    //individual byte/word/long selection, thanks to HYF!

    always@(posedge CLK)
    begin

`ifdef __RMW_CYCLE__

        // read-modify-write operation w/ 1 wait-state:

        if(!HLT&&WR&&DADDR[31]==0/*&&DADDR[`MLEN-1]==1*/)
        begin
    `ifdef __HARVARD__
            RAM[DADDR[`MLEN-1:2]] <=
    `else
            MEM[DADDR[`MLEN-1:2]] <=
    `endif
                                {
                                    BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
                                    BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
                                    BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
                                    BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
                                };
        end

`else
        // write-only operation w/ 0 wait-states:
    `ifdef __HARVARD__
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[3]) RAM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[2]) RAM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[1]) RAM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[0]) RAM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
    `else
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[3]) MEM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[2]) MEM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[1]) MEM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[0]) MEM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
    `endif
`endif

        XADDR <= DADDR; // 1 clock delayed
        IOMUXFF <= IOMUX[DADDR[4:2]==3'b100 ? 3'b100 : DADDR[3:2]]; // read w/ 2 wait-states
    end

    //assign DATAI = DADDR[31] ? IOMUX[DADDR[3:2]]  : RAMFF;
    //assign DATAI = DADDR[31] ? IOMUXFF : RAMFF;
    assign DATAI = XADDR[31] ? IOMUX[XADDR[4:2]==3'b100 ? 3'b100 : XADDR[3:2]] : RAMFF;

`endif

endmodule
