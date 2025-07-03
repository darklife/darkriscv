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

// implemented opcodes:

`define LUI     7'b01101_11      // lui   rd,imm[31:12]
`define AUIPC   7'b00101_11      // auipc rd,imm[31:12]
`define JAL     7'b11011_11      // jal   rd,imm[xxxxx]
`define JALR    7'b11001_11      // jalr  rd,rs1,imm[11:0]
`define BCC     7'b11000_11      // bcc   rs1,rs2,imm[12:1]
`define LCC     7'b00000_11      // lxx   rd,rs1,imm[11:0]
`define SCC     7'b01000_11      // sxx   rs1,rs2,imm[11:0]
`define MCC     7'b00100_11      // xxxi  rd,rs1,imm[11:0]
`define RCC     7'b01100_11      // xxx   rd,rs1,rs2
`define SYS     7'b11100_11      // exx, csrxx, mret

// proprietary extension (custom-0)
`define CUS     7'b00010_11      // cus   rd,rs1,rs2,fc3,fct5

// not implemented opcodes:
//`define FCC     7'b00011_11      // fencex


// configuration file

`include "../rtl/config.vh"

module darkriscv
#(
    parameter CPTR = 0
)
(
    input             CLK,   // clock
    input             RES,   // reset
    input             HLT,   // halt

`ifdef __INTERRUPT__
    input             IRQ,   // interrupt request
`endif

    input      [31:0] IDATA, // instruction data bus
    output     [31:0] IADDR, // instruction addr bus

    input      [31:0] DATAI, // data bus (input)
    output     [31:0] DATAO, // data bus (output)
    output     [31:0] DADDR, // addr bus

    output     [ 2:0] DLEN, // data length
    output     [ 3:0] DBE,  // data byte enable
    output            DRW,  // data read/write
    output            DRD,  // data read
    output            DWR,  // data write
    output            DAS,  // address strobe

    input             BERR, // bus error
    
`ifdef SIMULATION
    input             ESIMREQ,  // end simulation req
    output reg        ESIMACK = 0,  // end simulation ack
`endif

`ifdef __COPROCESSOR__
    output            CPR_REQ,
    output     [ 2:0] CPR_FCT3,
    output     [ 6:0] CPR_FCT7,
    output     [31:0] CPR_RS1,
    output     [31:0] CPR_RS2,
    output     [31:0] CPR_RDR,
    input      [31:0] CPR_RDW,
`endif

    output [3:0]  DEBUG       // old-school osciloscope based debug! :)
);

    // dummy 32-bit words w/ all-0s and all-1s:

    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;

    reg XRES = 1;

`ifdef __THREADS__
    reg [`__THREADS__-1:0] TPTR = 0;     // thread ptr
`endif

    // switch IDATA according to the endian

`ifdef __BIG__
    wire [31:0] IDATA1 = {IDATA[7:0],IDATA[15:8],IDATA[23:16],IDATA[31:24]};
`else
    wire [31:0] IDATA1 = IDATA;
`endif

    // pipeline flow control when halted (HLT=1)

    // only for halt control
    reg        HLT2   = 0;
    reg [31:0] IDATA2 = 0;

    always@(posedge CLK)
    begin
        HLT2 <= HLT;
        
        // clock in IDATA2 when HLT transitions
        if(HLT2^HLT) IDATA2 <= IDATA1;
    end

    // HLT-aware instruction data for decode stage
    wire[31:0] IDATAX = XRES ? 0 :
                        HLT2 ? IDATA2 :
                               IDATA1;

    // decode: IDATA is break apart as described in the RV32I specification

`ifdef __3STAGE__

    // eXecute stage instruction data (next pipeline stage)
    reg [31:0] XIDATA;

    reg XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XCUS, XSYS; //, XFCC;

    reg [31:0] XSIMM;
    reg [31:0] XUIMM;

    always@(posedge CLK)
    begin
        XIDATA <= HLT ? XIDATA : IDATAX;

        XLUI   <= HLT ? XLUI   : IDATAX[6:0]==`LUI;
        XAUIPC <= HLT ? XAUIPC : IDATAX[6:0]==`AUIPC;
        XJAL   <= HLT ? XJAL   : IDATAX[6:0]==`JAL;
        XJALR  <= HLT ? XJALR  : IDATAX[6:0]==`JALR;

        XBCC   <= HLT ? XBCC   : IDATAX[6:0]==`BCC;
        XLCC   <= HLT ? XLCC   : IDATAX[6:0]==`LCC;
        XSCC   <= HLT ? XSCC   : IDATAX[6:0]==`SCC;
        XMCC   <= HLT ? XMCC   : IDATAX[6:0]==`MCC;

        XRCC   <= HLT ? XRCC   : IDATAX[6:0]==`RCC;
        XCUS   <= HLT ? XCUS   : IDATAX[6:0]==`CUS;
        //XFCC   <= HLT ? XFCC   : IDATAX[6:0]==`FCC;
        XSYS   <= HLT ? XSYS   : IDATAX[6:0]==`SYS;

        // sign extended immediate, according to the instruction type:

        XSIMM  <= HLT ? XSIMM :
                 IDATAX[6:0]==`SCC ? { IDATAX[31] ? ALL1[31:12]:ALL0[31:12], IDATAX[31:25],IDATAX[11:7] } : // s-type
                 IDATAX[6:0]==`BCC ? { IDATAX[31] ? ALL1[31:13]:ALL0[31:13], IDATAX[31],IDATAX[7],IDATAX[30:25],IDATAX[11:8],ALL0[0] } : // b-type
                 IDATAX[6:0]==`JAL ? { IDATAX[31] ? ALL1[31:21]:ALL0[31:21], IDATAX[31], IDATAX[19:12], IDATAX[20], IDATAX[30:21], ALL0[0] } : // j-type
                 IDATAX[6:0]==`LUI||
                 IDATAX[6:0]==`AUIPC ? { IDATAX[31:12], ALL0[11:0] } : // u-type
                                      { IDATAX[31] ? ALL1[31:12]:ALL0[31:12], IDATAX[31:20] }; // i-type

        // zero-extended (unsigned) immediate, according to the instruction type:

        XUIMM  <= HLT ? XUIMM :
                 IDATAX[6:0]==`SCC ? { ALL0[31:12], IDATAX[31:25],IDATAX[11:7] } : // s-type
                 IDATAX[6:0]==`BCC ? { ALL0[31:13], IDATAX[31],IDATAX[7],IDATAX[30:25],IDATAX[11:8],ALL0[0] } : // b-type
                 IDATAX[6:0]==`JAL ? { ALL0[31:21], IDATAX[31], IDATAX[19:12], IDATAX[20], IDATAX[30:21], ALL0[0] } : // j-type
                 IDATAX[6:0]==`LUI||
                 IDATAX[6:0]==`AUIPC ? { IDATAX[31:12], ALL0[11:0] } : // u-type
                                      { ALL0[31:12], IDATAX[31:20] }; // i-type
    end

    // how many cycles left to start instruction execution
    reg [1:0] FLUSH = -1;  // flush instruction pipeline

`else

    wire [31:0] XIDATA;

    wire XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XCUS, XSYS; //, XFCC, XSYS;

    wire [31:0] XSIMM;
    wire [31:0] XUIMM;

    assign XIDATA = IDATAX;

    assign XLUI   = IDATAX[6:0]==`LUI;
    assign XAUIPC = IDATAX[6:0]==`AUIPC;
    assign XJAL   = IDATAX[6:0]==`JAL;
    assign XJALR  = IDATAX[6:0]==`JALR;

    assign XBCC   = IDATAX[6:0]==`BCC;
    assign XLCC   = IDATAX[6:0]==`LCC;
    assign XSCC   = IDATAX[6:0]==`SCC;
    assign XMCC   = IDATAX[6:0]==`MCC;

    assign XRCC   = IDATAX[6:0]==`RCC;
    assign XCUS   = IDATAX[6:0]==`CUS;
    //assign XFCC   <= IDATAX[6:0]==`FCC;
    assign XSYS   = IDATAX[6:0]==`SYS;

    // sign extended immediate, according to the instruction type:

    assign XSIMM  = 
                     IDATAX[6:0]==`SCC ? { IDATAX[31] ? ALL1[31:12]:ALL0[31:12], IDATAX[31:25],IDATAX[11:7] } : // s-type
                     IDATAX[6:0]==`BCC ? { IDATAX[31] ? ALL1[31:13]:ALL0[31:13], IDATAX[31],IDATAX[7],IDATAX[30:25],IDATAX[11:8],ALL0[0] } : // b-type
                     IDATAX[6:0]==`JAL ? { IDATAX[31] ? ALL1[31:21]:ALL0[31:21], IDATAX[31], IDATAX[19:12], IDATAX[20], IDATAX[30:21], ALL0[0] } : // j-type
                     IDATAX[6:0]==`LUI||
                     IDATAX[6:0]==`AUIPC ? { IDATAX[31:12], ALL0[11:0] } : // u-type
                                          { IDATAX[31] ? ALL1[31:12]:ALL0[31:12], IDATAX[31:20] }; // i-type

    // zero-extended (unsigned) immediate, according to the instruction type:

    assign XUIMM  = 
                     IDATAX[6:0]==`SCC ? { ALL0[31:12], IDATAX[31:25],IDATAX[11:7] } : // s-type
                     IDATAX[6:0]==`BCC ? { ALL0[31:13], IDATAX[31],IDATAX[7],IDATAX[30:25],IDATAX[11:8],ALL0[0] } : // b-type
                     IDATAX[6:0]==`JAL ? { ALL0[31:21], IDATAX[31], IDATAX[19:12], IDATAX[20], IDATAX[30:21], ALL0[0] } : // j-type
                     IDATAX[6:0]==`LUI||
                     IDATAX[6:0]==`AUIPC ? { IDATAX[31:12], ALL0[11:0] } : // u-type
                                          { ALL0[31:12], IDATAX[31:20] }; // i-type

    reg FLUSH = -1;  // flush instruction pipeline

`endif

`ifdef __THREADS__
    `ifdef __RV32E__

        reg [`__THREADS__-1:0] RESMODE = -1;

        wire [`__THREADS__+3:0] DPTR   = XRES ? { RESMODE, 4'd0 } : { TPTR, XIDATA[10: 7] }; // set SP_RESET when RES==1
        wire [`__THREADS__+3:0] S1PTR  = { TPTR, XIDATA[18:15] };
        wire [`__THREADS__+3:0] S2PTR  = { TPTR, XIDATA[23:20] };
    `else
        reg [`__THREADS__-1:0] RESMODE = -1;

        wire [`__THREADS__+4:0] DPTR   = XRES ? { RESMODE, 5'd0 } : { TPTR, XIDATA[11: 7] }; // set SP_RESET when RES==1
        wire [`__THREADS__+4:0] S1PTR  = { TPTR, XIDATA[19:15] };
        wire [`__THREADS__+4:0] S2PTR  = { TPTR, XIDATA[24:20] };
    `endif
`else
    `ifdef __RV32E__
        wire [3:0] DPTR   = XIDATA[10: 7]; // set SP_RESET when RES==1
        wire [3:0] S1PTR  = XIDATA[18:15];
        wire [3:0] S2PTR  = XIDATA[23:20];
    `else
        wire [4:0] DPTR   = XIDATA[11: 7]; // set SP_RESET when RES==1
        wire [4:0] S1PTR  = XIDATA[19:15];
        wire [4:0] S2PTR  = XIDATA[24:20];
    `endif
`endif

    wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0]; // unused
    wire [2:0] FCT3   = XIDATA[14:12];
    wire [6:0] FCT7   = XIDATA[31:25];

    wire [31:0] SIMM  = XSIMM;
    wire [31:0] UIMM  = XUIMM;

    // main opcode decoder:

    wire    LUI = FLUSH ? 0 : XLUI;   // OPCODE==7'b0110111;
    wire  AUIPC = FLUSH ? 0 : XAUIPC; // OPCODE==7'b0010111;
    wire    JAL = FLUSH ? 0 : XJAL;   // OPCODE==7'b1101111;
    wire   JALR = FLUSH ? 0 : XJALR;  // OPCODE==7'b1100111;

    wire    BCC = FLUSH ? 0 : XBCC; // OPCODE==7'b1100011; //FCT3
    wire    LCC = FLUSH ? 0 : XLCC; // OPCODE==7'b0000011; //FCT3
    wire    SCC = FLUSH ? 0 : XSCC; // OPCODE==7'b0100011; //FCT3
    wire    MCC = FLUSH ? 0 : XMCC; // OPCODE==7'b0010011; //FCT3

    wire    RCC = FLUSH ? 0 : XRCC; // OPCODE==7'b0110011; //FCT3
    wire    CUS = FLUSH ? 0 : XCUS; // OPCODE==7'b0110011; //FCT3
    //wire    FCC = FLUSH ? 0 : XFCC; // OPCODE==7'b0001111; //FCT3
    wire    SYS = FLUSH ? 0 : XSYS; // OPCODE==7'b1110011; //FCT3

`ifdef __THREADS__
    `ifdef __3STAGE__
        reg [31:0] NXPC2 [0:(2**`__THREADS__)-1];       // 32-bit program counter t+2
    `endif
`else
    `ifdef __3STAGE__
        reg [31:0] NXPC2;       // 32-bit program counter t+2
    `endif
`endif

    reg [31:0] REGS [0:`RLEN-1];	// synthesis attribute ram_style of REGS is "distributed";

    reg [31:0] NXPC;        // 32-bit program counter t+1
    reg [31:0] PC;		    // 32-bit program counter t+0

`ifdef SIMULATION
    integer i;
    
    initial for(i=0;i!=`RLEN;i=i+1) REGS[i] = 0;
`endif

    // source-1 and source-2 register selection

    wire          [31:0] U1REG = REGS[S1PTR];
    wire          [31:0] U2REG = REGS[S2PTR];
    wire          [31:0] DREG  = REGS[DPTR];

    wire signed   [31:0] S1REG = U1REG;
    wire signed   [31:0] S2REG = U2REG;


    // SL-group of instructions (OPCODE==7'b0100011 for S, OPCODE==7'b0000011 for L)

`ifdef __FLEXBUZZ__

    wire [31:0] LDATA = FCT3[1:0]==0 ? { FCT3[2]==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } :
                        FCT3[1:0]==1 ? { FCT3[2]==0&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } :
                                        DATAI;

    wire [31:0] SDATA = U2REG;

`else
    `ifdef __BIG__

        wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==0 ? { FCT3==0&&DATAI[31] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[31:24] } :
                                                 DADDR[1:0]==1 ? { FCT3==0&&DATAI[23] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[23:16] } :
                                                 DADDR[1:0]==2 ? { FCT3==0&&DATAI[15] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[15: 8] } :
                                                                 { FCT3==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } ):
                            FCT3==1||FCT3==5 ? ( DADDR[1]==0   ? { FCT3==1&&DATAI[31] ? ALL1[31:16]:ALL0[31:16] , DATAI[31:16] } :
                                                                 { FCT3==1&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } ) :
                                                 DATAI;

        wire [31:0] SDATA = FCT3==0 ? ( DADDR[1:0]==0 ? { U2REG[ 7: 0], ALL0 [23:0] } :
                                        DADDR[1:0]==1 ? { ALL0 [31:24], U2REG[ 7:0], ALL0[15:0] } :
                                        DADDR[1:0]==2 ? { ALL0 [31:16], U2REG[ 7:0], ALL0[7:0] } :
                                                        { ALL0 [31: 8], U2REG[ 7:0] } ) :
                            FCT3==1 ? ( DADDR[1]==0   ? { U2REG[15: 0], ALL0 [15:0] } :
                                                        { ALL0 [31:16], U2REG[15:0] } ) :
                                        U2REG;

    `else

        wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? { FCT3==0&&DATAI[31] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[31:24] } :
                                                 DADDR[1:0]==2 ? { FCT3==0&&DATAI[23] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[23:16] } :
                                                 DADDR[1:0]==1 ? { FCT3==0&&DATAI[15] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[15: 8] } :
                                                                 { FCT3==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } ):
                            FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? { FCT3==1&&DATAI[31] ? ALL1[31:16]:ALL0[31:16] , DATAI[31:16] } :
                                                                 { FCT3==1&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } ) :
                                                 DATAI;

        wire [31:0] SDATA = FCT3==0 ? ( DADDR[1:0]==3 ? { U2REG[ 7: 0], ALL0 [23:0] } :
                                        DADDR[1:0]==2 ? { ALL0 [31:24], U2REG[ 7:0], ALL0[15:0] } :
                                        DADDR[1:0]==1 ? { ALL0 [31:16], U2REG[ 7:0], ALL0[7:0] } :
                                                        { ALL0 [31: 8], U2REG[ 7:0] } ) :
                            FCT3==1 ? ( DADDR[1]==1   ? { U2REG[15: 0], ALL0 [15:0] } :
                                                        { ALL0 [31:16], U2REG[15:0] } ) :
                                        U2REG;
    `endif
`endif

    // C-group: CSRRW

    wire EBRK = SYS && FCT3==0 && XIDATA[31:20]==12'b000000000001; // ebreak always decodable, for simulation

    // exceptions

    wire IERR = FLUSH ? 0 : !(XLUI||XAUIPC||XJAL||XJALR||XBCC||XLCC||XSCC||XMCC||XRCC||XCUS||XSYS);

    wire DBER = BERR&&(DRD||DWR);
    wire IBER = BERR&&!(DRD||DWR);
    wire DAER = DLEN==2 ? DADDR[0]!=0 : DLEN==4 ? DADDR[1:0]!=0 : 0;
    wire IAER = IADDR[1:0]!=0;

`ifdef __CSR__

    wire CSRX  = SYS && FCT3[1:0];

    `ifdef __INTERRUPT__
        reg [31:0] MSTATUS  = 0;
        reg [31:0] MSCRATCH = 0;
        reg [31:0] MCAUSE   = 0;
        reg [31:0] MEPC     = 0;
        reg [31:0] MTVEC    = 0;
        reg [31:0] MIE      = 0;
        reg [31:0] MIP      = 0;

        wire MRET = SYS && FCT3==0 && XIDATA[31:20]==12'b001100000010;
    `endif

    `ifdef __EBREAK__
        reg [31:0] SSTATUS  = 0;
        reg [31:0] SSCRATCH = 0;
        reg [31:0] SCAUSE   = 0;
        reg [31:0] SEPC     = 0;
        reg [31:0] STVEC    = 0;
        reg [31:0] SIE      = 0;
        reg [31:0] SIP      = 0;

        wire SRET = SYS && FCT3==0 && XIDATA[31:20]==12'b000100000010;
    `endif

    `ifdef __CSR_ESSENTIAL__
		reg [63:0] CSRCLK = 0;
		reg [63:0] CSRINS = 0;
		always@(posedge CLK)
		begin
			if(!XRES)
			begin
				CSRCLK = CSRCLK+1;
				if(!HLT & !(|FLUSH))
					CSRINS = CSRINS+1;
			end
		end
    `endif

    wire [31:0] CRDATA = 
    `ifdef __THREADS__    
                        XIDATA[31:20]==12'hf14 ? { CPTR, TPTR } : // core/thread number
    `else
                        XIDATA[31:20]==12'hf14 ? CPTR  : // core number
    `endif    
    `ifdef __INTERRUPT__
                        XIDATA[31:20]==12'h344 ? MIP      : // machine interrupt pending
                        XIDATA[31:20]==12'h304 ? MIE      : // machine interrupt enable
                        XIDATA[31:20]==12'h341 ? MEPC     : // machine exception PC
                        XIDATA[31:20]==12'h342 ? MCAUSE   : // machine expection cause
                        XIDATA[31:20]==12'h305 ? MTVEC    : // machine vector table
                        XIDATA[31:20]==12'h300 ? MSTATUS  : // machine status
                        XIDATA[31:20]==12'h340 ? MSCRATCH : // machine status
    `endif
    `ifdef __EBREAK__
                        XIDATA[31:20]==12'h144 ? SIP      : // machine interrupt pending
                        XIDATA[31:20]==12'h104 ? SIE      : // machine interrupt enable
                        XIDATA[31:20]==12'h141 ? SEPC     : // machine exception PC
                        XIDATA[31:20]==12'h142 ? SCAUSE   : // machine expection cause
                        XIDATA[31:20]==12'h105 ? STVEC    : // machine vector table
                        XIDATA[31:20]==12'h100 ? SSTATUS  : // machine status
                        XIDATA[31:20]==12'h140 ? SSCRATCH : // machine status
    `endif
    `ifdef __CSR_ESSENTIAL__
						XIDATA[31:20]==12'hC00 ? CSRCLK[31:0]  :
						XIDATA[31:20]==12'hC02 ? CSRINS[31:0]  :
						XIDATA[31:20]==12'hC80 ? CSRCLK[63:32] :
						XIDATA[31:20]==12'hC82 ? CSRINS[63:32] :
    `endif
                                                 0;	 // unknown

    wire [31:0] WRDATA = FCT3[1:0]==3 ? (CRDATA & ~CRMASK) : FCT3[1:0]==2 ? (CRDATA | CRMASK) : CRMASK;
    wire [31:0] CRMASK = FCT3[2] ? XIDATA[19:15] : U1REG;
   
`endif


    // RM-group of instructions (OPCODEs==7'b0010011/7'b0110011), merged! src=immediate(M)/register(R)

    wire signed [31:0] S2REGX = XMCC ? SIMM : S2REG;
    wire        [31:0] U2REGX = XMCC ? UIMM : U2REG;

    wire [31:0] RMDATA = FCT3==7 ? U1REG&S2REGX :
                         FCT3==6 ? U1REG|S2REGX :
                         FCT3==4 ? U1REG^S2REGX :
                         FCT3==3 ? U1REG<U2REGX : // unsigned
                         FCT3==2 ? S1REG<S2REGX : // signed
                         FCT3==0 ? (XRCC&&FCT7[5] ? U1REG-S2REGX : U1REG+S2REGX) :
                         FCT3==1 ? S1REG<<U2REGX[4:0] :
                         //FCT3==5 ?
                         !FCT7[5] ? S1REG>>U2REGX[4:0] :
`ifdef MODEL_TECH
                                   -((-S1REG)>>U2REGX[4:0]); // workaround for modelsim
`else
                                   $signed(S1REG>>>U2REGX[4:0]);  // (FCT7[5] ? U1REG>>>U2REG[4:0] :
`endif

`ifdef __COPROCESSOR__
    assign CPR_REQ = CUS;
    assign CPR_FCT3 = FCT3;
    assign CPR_FCT7 = FCT7;
    assign CPR_RS1 = U1REG;
    assign CPR_RS2 = U2REG;
    assign CPR_RDR = DREG;
`endif

    // J/B-group of instructions (OPCODE==7'b1100011)

    wire BMUX       = FCT3==7 && U1REG>=U2REG  || // bgeu
                      FCT3==6 && U1REG< U2REGX || // bltu
                      FCT3==5 && S1REG>=S2REG  || // bge
                      FCT3==4 && S1REG< S2REGX || // blt
                      FCT3==1 && U1REG!=U2REGX || // bne
                      FCT3==0 && U1REG==U2REGX; // beq

    wire [31:0] PCSIMM = PC+SIMM;
    wire        JREQ = JAL||JALR||(BCC && BMUX);
    wire [31:0] JVAL = JALR ? DADDR : PCSIMM; // SIMM + (JALR ? U1REG : PC);

    always@(posedge CLK)
    begin
`ifdef __THREADS__
        RESMODE <= RES ? -1 : RESMODE ? RESMODE-1 : 0;
        XRES <= |RESMODE;
`else
        XRES <= RES;
`endif

`ifdef __3STAGE__
        FLUSH <= XRES ? 2 :         // on reset wait 2 cycles (fill the pipeline)
                  HLT ? FLUSH :     // on halt do nothing
                FLUSH ? FLUSH-1 :   // if-nonzero -> decrement
    `ifdef __EBREAK__
          IERR||DBER||IBER||IAER||DAER ? 2 : // misc errors
                                  EBRK ? 2 : // ebreak jmps to system level, i.e. sepc = PC; PC = stvec
                                  SRET ? 2 : // sret returns from system level, i.e. PC = sepc
    `endif
    `ifdef __INTERRUPT__
                 MRET ? 2 :         // mret returns from interrupt, i.e. PC = mepc
    `endif
                 JREQ ? 2 : 0;      // flush the pipeline! (when jump requested)
`else
        FLUSH <= XRES ? 1 :         // on reset wait 1 cycle
                  HLT ? FLUSH :     // on halt do nothing
                  JREQ;             // flush the pipeline! (or not! when no jump)
`endif

`ifdef __INTERRUPT__

    `ifdef __EBREAK__
        MIP[11] <= IRQ&&MSTATUS[3]&&MIE[11]&&!SIP[1];
    `else
        MIP[11] <= IRQ&&MSTATUS[3]&&MIE[11];
    `endif
    
        if(XRES)
        begin
            MTVEC    <= 0;
            MEPC     <= 0;
            MIE      <= 0;
            MCAUSE   <= 0;
            MSTATUS  <= 0;
            MSCRATCH <= 0;
        end
        else
        if(!HLT && !FLUSH)
        begin
            if(CSRX)
            begin
                case(XIDATA[31:20])
                    12'h300: MSTATUS  <= WRDATA;
                    12'h340: MSCRATCH <= WRDATA;
                    12'h305: MTVEC    <= WRDATA;
                    12'h341: MEPC     <= WRDATA;
                    12'h304: MIE      <= WRDATA;
                endcase
            end
            else
            if(MIP[11] && JREQ)
            begin
                MEPC   <= JVAL;             // interrupt saves the next PC!
                MSTATUS[3] <= 0;            // no interrupts when handling ebreak!
                MSTATUS[7] <= MSTATUS[3];   // copy old MIE bit
                MCAUSE <= 32'h8000000b;     // ext interrupt
            end
            else
            if(MRET)
            begin
                MSTATUS[3] <= MSTATUS[7]; // return last MIE bit
            end
        end
`endif

`ifdef __EBREAK__
   
        if(XRES)
        begin
            STVEC    <= 0;
            SEPC     <= 0;
            SIE      <= 0;
            SIP      <= 0;
            SCAUSE   <= 0;
            SSTATUS  <= 0;
            SSCRATCH <= 0;
        end
        else
        if(!HLT||!FLUSH)
        begin
            if(IAER||IBER||IERR||EBRK||DAER||DBER) // ebreak cannot be blocked!
            begin
                SEPC   <= PC;               // ebreak saves the current PC!
                SSTATUS[1] <= 0;            // no interrupts when handling ebreak!
                SSTATUS[5] <= SSTATUS[1];   // copy old MIE bit
                
                SCAUSE <=      IAER ? 32'd0 :
                               IBER ? 32'd1 :
                               IERR ? 32'd2 :
                               EBRK ? 32'd3 : 
                          DAER&&DRD ? 32'd4 :
                          DBER&&DRD ? 32'd5 :
                          DAER&&DWR ? 32'd6 :
                          DBER&&DWR ? 32'd7 :
                                    -1;
                          
                SIP[1] <= 1;                // set when ebreak!
            end
            else
            if(CSRX)
            begin
                case(XIDATA[31:20])
                    12'h100: SSTATUS  <= WRDATA;
                    12'h140: SSCRATCH <= WRDATA;
                    12'h105: STVEC    <= WRDATA;
                    12'h141: SEPC     <= WRDATA;
                    12'h104: SIE      <= WRDATA;
                endcase
            end
            else
            if(SRET)
            begin
                SSTATUS[3] <= SSTATUS[7]; // return last MIE bit
                SIP[1] <= 0;              //return from ebreak
            end
        end
        
`endif

`ifdef __RV32E__
        REGS[DPTR] <=   XRES||DPTR[3:0]==0 ? 0  :        // reset x0
`else
        REGS[DPTR] <=   XRES||DPTR[4:0]==0 ? 0  :        // reset x0
`endif
                       HLT ? DREG :        // halt
                       LCC ? LDATA :
                     AUIPC ? PCSIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                  MCC||RCC ? RMDATA:

`ifdef __COPROCESSOR__
                       CUS ? CPR_RDW :
`endif
`ifdef __CSR__
                       CSRX ? CRDATA :
`endif
                             DREG;

`ifdef __3STAGE__

    `ifdef __THREADS__

        NXPC <= /*XRES ? `__RESETPC__ :*/ HLT ? NXPC : NXPC2[TPTR];

        NXPC2[XRES ? RESMODE : TPTR] <=  XRES ? `__RESETPC__ : HLT ? NXPC2[TPTR] :   // reset and halt
                                      JREQ ? JVAL :                            // jmp/bra
                                             NXPC2[TPTR]+4;                   // normal flow

        TPTR <= XRES ? 0 : HLT ? TPTR :        // reset and halt
                            JAL /*JREQ*/ ? TPTR+1 : TPTR;
                 //TPTR==0/*&& IREQ*/&&JREQ ? 1 :         // wait pipeflush to switch to irq
                 //TPTR==1/*&&!IREQ*/&&JREQ ? 0 : TPTR;  // wait pipeflush to return from irq

    `else
        NXPC <= /*XRES ? `__RESETPC__ :*/ HLT ? NXPC : NXPC2;

        NXPC2 <=  XRES ? `__RESETPC__ : HLT ? NXPC2 :   // reset and halt
        `ifdef __EBREAK__
                     SRET ? SEPC :  // return from system call
                     STVEC&&
                     (IAER||
                     IBER||
                     IERR||
                     EBRK||
                     DAER||
                     DBER) ? STVEC : // ebreak causes an system call                     
        `endif

        `ifdef __INTERRUPT__
                     MRET ? MEPC :  // return from interrupt
                    MIP[11]&&JREQ ? MTVEC : // pending interrupt + pipeline flush
        `endif
                     JREQ ? JVAL :                    // jmp/bra
                            NXPC2+4;                   // normal flow

    `endif

`else
        NXPC <= XRES ? `__RESETPC__ : HLT ? NXPC :   // reset and halt
        
        `ifdef __EBREAK__
                     MRET ? MEPC :
                     EBRK ? MTVEC : // ebreak causes an interrupt
        `endif
        `ifdef __INTERRUPT__
                     MRET ? MEPC :
                    MIP[11]&&JREQ ? MTVEC : // pending interrupt + pipeline flush
        `endif
              JREQ ? JVAL :                   // jmp/bra
                     NXPC+4;                   // normal flow
`endif
        PC   <= /*XRES ? `__RESETPC__ :*/ HLT ? PC : NXPC; // current program counter
    end

    // IO and memory interface

    assign DATAO = SDATA;
    assign DADDR = U1REG + SIMM;

    // based in the Scc and Lcc

    assign DRW      = !SCC;
    assign DLEN[0] = (SCC||LCC)&&FCT3[1:0]==0; // byte
    assign DLEN[1] = (SCC||LCC)&&FCT3[1:0]==1; // word
    assign DLEN[2] = (SCC||LCC)&&FCT3[1:0]==2; // long

`ifdef __BIG__

    assign DBE = FCT3==0||FCT3==4 ? ( DADDR[1:0]==0 ? 4'b1000 : // sb/lb
                                      DADDR[1:0]==1 ? 4'b0100 :
                                      DADDR[1:0]==2 ? 4'b0010 :
                                                      4'b0001 ) :
                 FCT3==1||FCT3==5 ? ( DADDR[1]==0   ? 4'b1100 : // sh/lh
                                                      4'b0011 ) :
                                                      4'b1111; // sw/lw
`else
    assign DBE = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? 4'b1000 : // sb/lb
                                      DADDR[1:0]==2 ? 4'b0100 :
                                      DADDR[1:0]==1 ? 4'b0010 :
                                                      4'b0001 ) :
                 FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? 4'b1100 : // sh/lh
                                                      4'b0011 ) :
                                                      4'b1111; // sw/lw
`endif

    assign DWR     = SCC;
    assign DRD     = LCC;
    assign DAS     = SCC||LCC;

`ifdef __3STAGE__
    `ifdef __THREADS__
        assign IADDR = NXPC2[TPTR];
    `else
        assign IADDR = NXPC2;
    `endif
`else
    assign IADDR = NXPC;
`endif
    
`ifdef __INTERRUPT__
    assign DEBUG = { IRQ, MIP, MIE, MRET };
`else
    assign DEBUG = { XRES, |FLUSH, SCC, LCC };
`endif

`ifdef SIMULATION

    `ifdef __PERFMETER__

        integer clocks=0, running=0, load=0, store=0, flush=0, halt=0;

    `ifdef __THREADS__
        integer thread[0:(2**`__THREADS__)-1],curtptr=0,cnttptr=0;
        integer j;

        initial for(j=0;j!=(2**`__THREADS__);j=j+1) thread[j] = 0;
    `endif

        always@(posedge CLK)
        begin
            if(!XRES)
            begin
                clocks = clocks+1;

                if(HLT)
                begin
                         if(SCC)	store = store+1;
                    else if(LCC)	load  = load +1;
                    else 		halt  = halt +1;
                end
                else
                if(|FLUSH)
                begin
                    flush=flush+1;
                end
                else
                begin

        `ifdef __THREADS__
                    for(j=0;j!=(2**`__THREADS__);j=j+1)
                            thread[j] = thread[j]+(j==TPTR?1:0);

                    if(TPTR!=curtptr)
                    begin
                        curtptr = TPTR;
                        cnttptr = cnttptr+1;
                    end
        `endif
                    running = running +1;
                end

                if(ESIMREQ)
                begin
                    $display("****************************************************************************");
                    $display("DarkRISCV Pipeline Report (%0d clocks, %0d instr, CPI = %.2f):",
                        clocks,running,1.0*clocks/running);

                    $display("core%0d: %0d%% run, %0d%% wait (%0d%% i-bus, %0d%% d-bus/rd, %0d%% d-bus/wr), %0d%% flush",
                        CPTR,
                        100.0*running/clocks,
                        100.0*(load+store+halt)/clocks,
                        100.0*halt/clocks,
                        100.0*load/clocks,
                        100.0*store/clocks,
                        100.0*flush/clocks);

         `ifdef __THREADS__
                    for(j=0;j!=(2**`__THREADS__);j=j+1) $display("  thread%0d: %0d%% running",j,100.0*thread[j]/clocks);

                    $display("%0d thread switches, %0d clocks/threads",cnttptr,clocks/cnttptr);
         `endif
                    $display("****************************************************************************");
                    $finish();
                end
            end
        `ifndef __EBREAK__
            if(!HLT&&!FLUSH&&EBRK)
            begin
                $display("breakpoint at %x",PC);
                $stop();
            end
        `endif        
            if(!HLT && !FLUSH && (XIDATA===32'dx || XIDATA[6:0]==0))
            begin
                $display("invalid XIDATA=%x at %x %s",XIDATA,PC,XIDATA[6:0]==0?"(check for ENDIAN on rtl/config.vh and src/config.mk)":"");
                $finish();  
            end
            
            if(LCC&&!HLT&&!FLUSH&&( (DLEN==4 && DATAI[31:0]===32'dx)||
                                    (DLEN==2 && DATAI[15:0]===16'dx)||
                                    (DLEN==1 && DATAI[ 7:0]=== 8'dx)))
            begin
                $display("invalid DATAI@%x at %x",DADDR,PC);
                $finish();
            end
            
        `ifdef __TRACE__
            if(!XRES)
            begin
            `ifdef __TRACEFULL__
                if(FLUSH)
                    $display("trace: %x:%x       flushed",PC,XIDATA);
                else
                if(HLT)
                begin
                    //$display("%x:%x       %s halted       %x:%x",PC,XIDATA,LCC?"lx":"sx",DADDR,LCC?LDATA:DATAO);
                    $display("trace: %x:%x       halted",PC,XIDATA);
                end
                else
            `else
                if(!FLUSH && !HLT)
            `endif
                begin
                    case(XIDATA[6:0])
                        `LUI:     $display("trace: %x:%x lui   %%x%0x,%0x",                PC,XIDATA,DPTR,$signed(SIMM));
                        `AUIPC:   $display("trace: %x:%x auipc %%x%0x,PC[%0x]",            PC,XIDATA,DPTR,$signed(SIMM));
                        `JAL:     $display("trace: %x:%x jal   %%x%0x,%0x",                PC,XIDATA,DPTR,$signed(SIMM));
                        `JALR:    $display("trace: %x:%x jalr  %%x%0x,%%x%0x,%0d",         PC,XIDATA,DPTR,S1PTR,$signed(SIMM));
                        `BCC:     $display("trace: %x:%x bcc   %%x%0x,%%x%0x,PC[%0d]",     PC,XIDATA,S1PTR,S2PTR,$signed(SIMM));
                        `LCC:     $display("trace: %x:%x lx    %%x%0x,%%x%0x[%0d]\t%x:%x",  PC,XIDATA,DPTR,S1PTR,$signed(SIMM),DADDR,LDATA);
                        `SCC:     $display("trace: %x:%x sx    %%x%0x,%%x%0x[%0d]\t%x:%x",  PC,XIDATA,DPTR,S1PTR,$signed(SIMM),DADDR,DATAO);
                        `MCC:     $display("trace: %x:%x alui  %%x%0x,%%x%0x,%0d",         PC,XIDATA,DPTR,S1PTR,$signed(SIMM));
                        `RCC:     $display("trace: %x:%x alu   %%x%0x,%%x%0x,%%x%0x",      PC,XIDATA,DPTR,S1PTR,S2PTR);
                        `SYS:     $display("trace: %x:%x sys   (no decode)",               PC,XIDATA);
                        `CUS:     $display("trace: %x:%x cus   (no decode)",               PC,XIDATA);
                        default:  $display("trace: %x:%x ???   (no decode)",               PC,XIDATA);
                    endcase
                end
            end        
        `endif
        
        end

    `else
        always@(posedge CLK) if(ESIMREQ) ESIMACK <= 1;
    `endif


`endif

endmodule
