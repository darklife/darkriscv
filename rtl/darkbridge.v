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

module darkbridge
(
    input         CLK,      // clock
    input         RES,      // reset
    output        HLT,

`ifdef __INTERRUPT__
    input         XIRQ,
`endif

    // x-bus

    output        XXDREQ,
    output        XXWR,
    output        XXRD,
    output [3:0]  XXBE,
    output [31:0] XXADDR,
    output [31:0] XXATAO,
    input  [31:0] XXATAI,
    input         XXDACK,

`ifdef __HARVARD__
    output        YDREQ,
    output [31:0] YADDR,
    input  [31:0] YDATA,
    input         YDACK,
`endif

`ifdef SIMULATION
    input       ESIMREQ,
    output      ESIMACK,
`endif
    output [3:0] DEBUG      // osciloscope
);

    // darkriscv bus interface

    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire        IDREQ;
    wire        IDACK;
    
    wire [31:0] DADDR;
    wire [31:0] DATAO;
    wire [31:0] DATAI;
    wire [ 3:0] DBE;
    
    wire        IHLT,
                DRW,
                DWR,
                DRD,
                DDREQ;
    wire        DDACK;

`ifdef __COPROCESSOR__
    wire        CPR_REQ;
    wire [ 2:0] CPR_FCT3;
    wire [ 6:0] CPR_FCT7;
    wire [31:0] CPR_RS1;
    wire [31:0] CPR_RS2;
    wire [31:0] CPR_RDR;
    wire [31:0] CPR_RDW;
    wire        CPR_ACK;
`endif
   
    // darkriscv

    wire [3:0]  KDEBUG;
    
    darkriscv
    #(
        .CPTR(0)
    )
    core0
    (
        .CLK    (CLK),
        .RES    (RES),

`ifdef __INTERRUPT__
        .IRQ    (XIRQ),
`endif

        .IDREQ  (IDREQ),
        .IDATA  (IDATA),
        .IADDR  (IADDR),
        .IDACK  (IDACK),

        .DADDR  (DADDR),
        .DATAI  (DATAI),
        .DATAO  (DATAO),
        .DBE    (DBE),
        .DRW    (DRW),
        .DWR    (DWR),
        .DRD    (DRD),
        .DDREQ  (DDREQ),
        .DDACK  (DDACK),
        .BERR   (1'b0),

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

`ifdef __COPROCESSOR__
        .CPR_REQ    (CPR_REQ),
        .CPR_FCT3   (CPR_FCT3),
        .CPR_FCT7   (CPR_FCT7),
        .CPR_RS1    (CPR_RS1),
        .CPR_RS2    (CPR_RS2),
        .CPR_RDR    (CPR_RDR),
        .CPR_RDW    (CPR_RDW),
        .CPR_ACK    (CPR_ACK),
`endif

        .DEBUG  (KDEBUG)
    );

    // instruction cache

`ifndef __HARVARD__
    wire         YDREQ;
    wire  [31:0] YADDR;
    wire  [31:0] YDATA;
    wire         YDACK;
`endif

`ifdef __ICACHE__
  
    darkcache #(.ID(0)) l1_inst
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),
        
        .DDREQ  (IDREQ),
        .DRD    (1'b1),
        .DWR    (1'b0),
        .DBE    (4'b1111),
        .DADDR  (IADDR),    
        .DATAI  (32'd0),
        .DATAP  (IDATA),
        .DDACK  (IDACK),

        .XDREQ    (YDREQ),
        //.XRD    (XRD),
        //.XWR    (XWR),
        //.XBE    (XBE),
        .XADDR  (YADDR),    
        .XATAI  (YDATA),
        //.XATAO  (XDATO),
        .XDACK  (YDACK)
    );

`else

    assign YDREQ = IDREQ;
    assign YADDR = IADDR;
    assign IDATA = YDATA;
    assign IDACK = YDACK;

`endif

    // data cache

    wire        XDREQ;
    wire        XWR;
    wire        XRD;
    wire [3:0]  XBE;
    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire        XDACK;
    wire [31:0] XATAI;
    
`ifndef __HARVARD__
    reg [31:0] XATAI2 = 0;   
    reg        XDACK2 = 0;
`endif

`ifdef __DCACHE__
    
    darkcache #(.ID(1)) l1_data    
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),
        
        .DDREQ  (DDREQ),
        .DRD    (DRD),
        .DWR    (DWR),
        .DBE    (DBE),
        .DADDR  (DADDR),    
        .DATAI  (DATAO),
        .DATAO  (DATAI),
        .DDACK  (DDACK),

        .XDREQ  (XDREQ),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),    
        .XATAI  (XATAI),
        .XATAO  (XATAO),
        .XDACK  (XDACK)
    );

`else

    assign XDREQ = DDREQ;
    assign XRD   = DRD;
    assign XWR   = DWR;
    assign XBE   = DBE;

    assign XADDR = DADDR;
    assign XATAO = DATAO;
    assign DATAI = XATAI;

    assign DDACK = XXDACK;

`endif

`ifdef __HARVARD__

    assign XXDREQ = XDREQ;
    assign XXWR   = XWR;
    assign XXRD   = XRD;
    assign XXBE   = XBE;
    assign XXADDR = XADDR;
    assign XXATAO = XATAO;

    assign XATAI  = XXATAI;
    assign XDACK  = XXDACK;

    assign IHLT = (IDREQ && !IDACK) || (DDREQ && !DDACK);
    
    assign HLT  = IHLT; 

`else 

    reg [1:0] XSTATE = 0;
    
    always@(posedge CLK)
    begin
        XSTATE <=   RES                          ? 0 : 
                    XSTATE==0 && XDREQ           ? 2 : // idle to data
                    XSTATE==0 && YDREQ           ? 1 : // idle to instr
                    XSTATE==2 && XXDACK && YDREQ ? 1 : // data to instr
                    XSTATE==2 && XXDACK          ? 0 : // data to idle                   
                    XSTATE==1 && XXDACK          ? 0 : // instr to idle
                                                   XSTATE; // no change        
                                                   
            XATAI2 <= (XSTATE==2 && XXDACK) ? XXATAI : XATAI2;

            XDACK2 <= XDREQ && (XSTATE==2 && XXDACK) ? XXDACK : 
                      YDREQ && (XSTATE==1 && XXDACK) ? 0      : XDACK2;

    end

    assign XXDREQ = XSTATE==2 ? XDREQ : XSTATE==1 ? YDREQ : 1'b0;
    assign XXWR   = XSTATE==2 ? XWR   : XSTATE==1 ? 1'b0  : 1'b0;
    assign XXRD   = XSTATE==2 ? XRD   : XSTATE==1 ? 1'b1  : 1'b0;
    assign XXBE   = XSTATE==2 ? XBE   : XSTATE==1 ? 4'd15 : 4'd0;
    assign XXADDR = XSTATE==2 ? XADDR : XSTATE==1 ? YADDR : 32'd0;
    assign XXATAO = XSTATE==2 ? XATAO : XSTATE==1 ? 32'd0 : 32'd0;

    assign YDATA  = XXATAI;
    assign YDACK  = XSTATE==1 && XXDACK;

    assign XATAI = XSTATE==1 ? XATAI2 : XXATAI;
    assign XDACK = XSTATE==1 ? XDACK2 : XXDACK;

    assign IHLT = (IDREQ && !IDACK) || (DDREQ && !DDACK);
    
    assign HLT  = 0;

`endif

`ifdef __COPROCESSOR__

    // Coprocessors are linked here!  Althrough there are no rules about it
    // at this time, one suggestion is use FCT3 as coprocessor ID, in the
    // same way the 680x0 used, so it is possible keep up to 8 independent
    // coprocessors, with the same tipe or not.  That makes much sense in
    // the case of stateless coprocessors, but it would make full sense in
    // the case of statefull coprocessors with integrated registers and
    // multi-cycle processing, in a way that is possible run complex jobs in
    // paralell.

    `ifdef __MAC16X16__

        darkmac mac0
        (
            .CLK        (CLK),          // clock
            .RES        (RES),          // reset
            .HLT        (HLT),          // halt

            .CPR_REQ    (CPR_REQ),      // CPR instr request
            .CPR_FCT3   (CPR_FCT3),     // fct3 field
            .CPR_FCT7   (CPR_FCT7),     // fct7 field
            .CPR_RS1    (CPR_RS1),      // operand RS1
            .CPR_RS2    (CPR_RS2),      // operand RS2
            .CPR_RDR    (CPR_RDR),      // operand RD (read)
            .CPR_RDW    (CPR_RDW),      // operand RD (write)
            .CPR_ACK    (CPR_ACK)       // CPR instr ack
            //.DEBUG      (DEBUG)       // old-school osciloscope based debug! :)
        );

    `endif

`endif

    assign DEBUG = { XDREQ, HLT, XDACK, IDACK };

endmodule
