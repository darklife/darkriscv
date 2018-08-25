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

// opcodes

`define LUI     7'b0110111
`define AUIPC   7'b0010111
`define JAL     7'b1101111
`define JALR    7'b1100111
`define BCC     7'b1100011
`define LCC     7'b0000011
`define SCC     7'b0100011
`define MCC     7'b0010011
`define RCC     7'b0110011
`define FCC     7'b0001111
`define CCC     7'b1110011

module darkriscv
#(
    parameter [31:0] RESET_PC = 0,
    parameter [31:0] RESET_SP = 4096
) (
    input             CLK,   // clock
    input             RES,   // reset
    
    input      [31:0] IDATA, // instruction data bus
    output     [31:0] IADDR, // instruction addr bus
    input             IHIT,  // instruction cache hit
    
    input      [31:0] DATAI, // data bus (input)
    output     [31:0] DATAO, // data bus (output)
    output     [31:0] DADDR, // addr bus
    input             DHIT,  // data cache hit
    
    output            WR,    // write enable
    output            RD,    // read enable 
    
    output [3:0]  DEBUG      // old-school osciloscope based debug! :)
);

    // flush instruction pipeline    
    
    reg FLUSH = 1;

    // IDATA is break apart as described in the RV32I specification

    reg [31:0] XIDATA;

    wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0];
    wire [4:0] DPTR   = RES   ? 2 : XIDATA[11:7];
    wire [2:0] FCT3   = XIDATA[14:12];
    wire [4:0] S1PTR  = XIDATA[19:15];
    wire [4:0] S2PTR  = XIDATA[24:20];
    wire [6:0] FCT7   = XIDATA[31:25];

    always@(posedge CLK)
    begin
        XIDATA <= IDATA;
    end
    
    // dummy 32-bit words w/ all-0s and all-1s: 

    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;

    // signal extended immediate, according to the instruction type:

    reg [31:0] SIMM;
    
    always@(posedge CLK)
    begin    
        SIMM  <= IDATA[6:0]==`SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { IDATA[31] ? ALL1[31:13]:ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { IDATA[31] ? ALL1[31:21]:ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:20] }; // i-type
    end
    
    // non-signal extended immediate, according to the instruction type:

    reg [31:0] UIMM;
    
    always@(posedge CLK)
    begin
        UIMM  <= IDATA[6:0]==`SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { ALL0[31:12], IDATA[31:20] }; // i-type
    end
    
    // main opcode decoder:
                                
    wire    LUI = OPCODE==7'b0110111;
    wire  AUIPC = OPCODE==7'b0010111;
    wire    JAL = OPCODE==7'b1101111;
    wire   JALR = OPCODE==7'b1100111;
    wire    BCC = OPCODE==7'b1100011; //FCT3
    wire    LCC = OPCODE==7'b0000011; //FCT3
    wire    SCC = OPCODE==7'b0100011; //FCT3
    wire    MCC = OPCODE==7'b0010011; //FCT3
    wire    RCC = OPCODE==7'b0110011; //FCT3
    wire    FCC = OPCODE==7'b0001111; //FCT3
    wire    CCC = OPCODE==7'b1110011; //FCT3

    reg [31:0] NXPC;        // 32-bit look-ahead program counter
    reg [31:0] PC;		    // 32-bit program counter
    reg [31:0] REG [0:31];	// general-purpose 32x32-bit registers

    integer i;
    
    initial for(i=0;i!=32;i=i+1) REG[i] = 0;		// makes the simulation looks better!

    // source-1 and source-1 register selection, with impicit 0 value in the x0:

    wire signed   [31:0] S1REG = S1PTR ? REG[S1PTR] : 0;
    wire signed   [31:0] S2REG = S2PTR ? REG[S2PTR] : 0;
    wire          [31:0] U1REG = S1PTR ? REG[S1PTR] : 0;
    wire          [31:0] U2REG = S2PTR ? REG[S2PTR] : 0;
    
    // L-group of instructions (OPCODE==7'b0000011)

    wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? { FCT3==0&&DATAI[31] ? ALL1[31:24]:ALL0[31:24] , DATAI[31:24] } : 
                                             DADDR[1:0]==2 ? { FCT3==0&&DATAI[23] ? ALL1[31:24]:ALL0[31:24] , DATAI[23:16] } : 
                                             DADDR[1:0]==1 ? { FCT3==0&&DATAI[15] ? ALL1[31:24]:ALL0[31:24] , DATAI[15: 8] } :
                                                             { FCT3==0&&DATAI[ 7] ? ALL1[31:24]:ALL0[31:24] , DATAI[ 7: 0] } ) :
                        FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? { FCT3==1&&DATAI[31] ? ALL1[31:16]:ALL0[31:16] , DATAI[31:16] } :
                                                             { FCT3==1&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } ) :
                                             DATAI;

    // S-group of instructions (OPCODE==7'b0100011)

    wire [31:0] SDATA = FCT3==0 ? ( DADDR[1:0]==3 ? { U2REG[ 7: 0], ALL0 [23:0] } : 
                                    DADDR[1:0]==2 ? { ALL0 [31:24], U2REG[ 7:0], ALL0[15:0] } : 
                                    DADDR[1:0]==1 ? { ALL0 [31:16], U2REG[ 7:0], ALL0[7:0] } :
                                                    { ALL0 [31: 8], U2REG[ 7:0] } ) :
                        FCT3==1 ? ( DADDR[1]==1   ? { U2REG[15: 0], ALL0 [15:0] } :
                                                    { ALL0 [31:16], U2REG[15:0] } ) :
                                    U2REG;

    // C-group not implemented yet!
    
    wire [31:0] CDATA = 0;	// status register istructions not implemented yet

    // I-group (merged M/R-groups OPCODE==7'b0x10011

    wire signed [31:0] SOP2 = MCC ? SIMM : S2REG; // signed
    wire        [31:0] UOP2 = MCC ? UIMM : FCT3==0 && FCT7[5] ? -U2REG : U2REG; // unsigned

    wire [31:0] MRDATA = FCT3==0 ? U1REG+UOP2 :
                         FCT3==1 ? U1REG<<UOP2[4:0] :
                         FCT3==2 ? S1REG<SOP2?1:0 : // signed
                         FCT3==3 ? U1REG<UOP2?1:0 : //unsigned
                         FCT3==5 ? (FCT7[5] ? U1REG>>>UOP2[4:0] : U1REG>>UOP2[4:0]) :
                         FCT3==4 ? U1REG^UOP2 :
                         FCT3==6 ? U1REG|UOP2 :
                         FCT3==7 ? U1REG&UOP2 :                           
                                   0;

    // J/B-group of instructions (OPCODE==7'b1100011)
    
    wire BMUX       = BCC==1 && (
                          FCT3==4 ? S1REG>=S2REG : // signed
                          FCT3==5 ? S1REG<=S2REG : // signed
                          FCT3==6 ? U1REG>=U2REG : // unsigned
                          FCT3==7 ? U1REG<=U2REG : // unsigned
                          FCT3==0 ? U1REG==U2REG : 
                          FCT3==1 ? U1REG!=U2REG : 
                                    0);

    wire        JREQ = (JAL||JALR||BMUX);
    wire [31:0] JVAL = SIMM + (JALR ? U1REG : PC);
            
    always@(posedge CLK)
    begin    
        FLUSH <= (JAL||JALR||BMUX||RES);    // flush the pipeline!
        
        REG[DPTR] <= RES ? RESET_SP :               // register bank update
                     AUIPC ? NXPC+SIMM :            
                     JAL||JALR ? NXPC :
                     LUI ? SIMM :
                     LCC ? LDATA :
                     MCC ? MRDATA : 
                     RCC ? MRDATA : 
                     CCC ? CDATA : 
                           REG[DPTR];
        
        if(IHIT) // instruction cache hit
        begin
            NXPC <=               RES ? RESET_PC-4 : // reset
                                 JREQ ? JVAL : // jmp/bra
                    (LCC||SCC)&&!DHIT ? NXPC : // load/store w/ cache miss
                                        NXPC+4;  // program counter (pre-fetch)
        end
        
        PC   <= NXPC; // program counter        
    end

    // IO and memory interface

    assign DATAO = SDATA; // SCC ? SDATA : 0;
    assign DADDR = U1REG + SIMM; // (SCC||LCC) ? U1REG + SIMM : 0;
    assign RD = LCC;
    assign WR = SCC;

    assign IADDR = NXPC;
        
    assign DEBUG = { RES, FLUSH, WR, RD };

endmodule
