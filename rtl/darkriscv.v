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

// pipeline stages:
// 
// 2-stages: core and memory in different clock edges result in less clock performance, but
// less losses when the program counter changes (pipeline flush = 1 clock). Works like a 4-stage
// pipeline and remember the 68040 clock scheme.
// 
// 3-stages: core and memory in the same clock edge result in more clock performance, but
// more losses when the program counter changes (pipeline flush = 2 clocks).
    
`define STAGE3

module darkriscv
#(
    parameter [31:0] RESET_PC = 0,
    parameter [31:0] RESET_SP = 4096
) (
    input             CLK,   // clock
    input             RES,   // reset
    input             HLT,   // halt
    
    input      [31:0] IDATA, // instruction data bus
    output     [31:0] IADDR, // instruction addr bus
    
    input      [31:0] DATAI, // data bus (input)
    output     [31:0] DATAO, // data bus (output)
    output     [31:0] DADDR, // addr bus
    
    output            WR,    // write enable
    output            RD,    // read enable 
    
    output [3:0]  DEBUG      // old-school osciloscope based debug! :)
);

    // dummy 32-bit words w/ all-0s and all-1s: 

    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;

    reg [1:0] FLUSH;  // flush instruction pipeline 
    
    // IDATA is break apart as described in the RV32I specification

    reg [31:0] XIDATA;

    wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0];
    wire [4:0] DPTR   = XIDATA[11: 7];
    wire [2:0] FCT3   = XIDATA[14:12];
    wire [4:0] S1PTR  = XIDATA[19:15];
    wire [4:0] S2PTR  = XIDATA[24:20];
    wire [6:0] FCT7   = XIDATA[31:25];

    always@(posedge CLK)
    begin        
        XIDATA <= RES ? { ALL0[31:12], 5'd2, ALL0[6:0] } : HLT ? XIDATA : IDATA;
    end   

    // signal extended immediate, according to the instruction type:

    reg [31:0] SIMM;
    
    always@(posedge CLK)
    begin    
        SIMM  <= RES ? 0 : HLT ? SIMM :
                 IDATA[6:0]==`SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
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
        UIMM  <= RES ? 0: HLT ? UIMM :
                 IDATA[6:0]==`SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
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

    reg [31:0] NXPC2;       // 32-bit program counter t+2
    reg [31:0] NXPC;        // 32-bit program counter t+1
    reg [31:0] PC;		    // 32-bit program counter t+0
    
    reg [31:0] REG [0:31];	// general-purpose 32x32-bit registers

    integer i; 
    initial for(i=0;i!=32;i=i+1) REG[i] = 0; // makes the simulation looks better!

    // source-1 and source-1 register selection

    wire signed   [31:0] S1REG = REG[S1PTR];
    wire signed   [31:0] S2REG = REG[S2PTR];
    wire          [31:0] U1REG = REG[S1PTR];
    wire          [31:0] U2REG = REG[S2PTR];
    
    // L-group of instructions (OPCODE==7'b0000011)

    wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? { FCT3==0&&DATAI[31] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[31:24] } :
                                             DADDR[1:0]==2 ? { FCT3==0&&DATAI[23] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[23:16] } :
                                             DADDR[1:0]==1 ? { FCT3==0&&DATAI[15] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[15: 8] } :
                                                             { FCT3==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } ):
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
/*
    wire signed [31:0] SOP2 = MCC ? SIMM : S2REG; // signed
    wire        [31:0] UOP2 = MCC ? UIMM : FCT3==0 && FCT7[5] ? -U2REG : U2REG; // unsigned

    wire [31:0] MRDATA = FCT3==0 ? U1REG+SOP2 :
                         FCT3==1 ? U1REG<<UOP2[4:0] :
                         FCT3==2 ? S1REG<SOP2?1:0 : // signed
                         FCT3==3 ? U1REG<UOP2?1:0 : //unsigned
                         FCT3==5 ? (FCT7[5] ? U1REG>>>UOP2[4:0] : U1REG>>UOP2[4:0]) :
                         FCT3==4 ? U1REG^UOP2 :
                         FCT3==6 ? U1REG|UOP2 :
                         FCT3==7 ? U1REG&UOP2 :                           
                                   0;
*/

    // M-group of instructions (OPCODE==7'b0010011)
`ifdef MODEL_TECH
    wire [31:0] MDATA_FCT3EQ5 = FCT7[5]==0||U1REG[31]==0 ? U1REG>>UIMM[4:0] : // workaround for modelsim
                                -((-U1REG)>>UIMM[4:0]);
`else
    wire [31:0] MDATA_FCT3EQ5 = (FCT7[5] ? U1REG>>>UIMM[4:0] : U1REG>>UIMM[4:0]);
`endif
    wire [31:0] MDATA = FCT3==0 ? U1REG+SIMM :
                        FCT3==1 ? U1REG<<UIMM[4:0] :
                        FCT3==2 ? S1REG<SIMM?1:0 : // signed
                        FCT3==3 ? U1REG<UIMM?1:0 : // unsigned
                        FCT3==5 ? MDATA_FCT3EQ5 : // (FCT7[5] ? U1REG>>>UIMM[4:0] : U1REG>>UIMM[4:0]) :
                        FCT3==4 ? U1REG^SIMM :
                        FCT3==6 ? U1REG|SIMM :
                        FCT3==7 ? U1REG&SIMM :                           
                                  0;


    // R-group of instructions (OPCODE==7'b0110011)
`ifdef MODEL_TECH
    wire [31:0] RDATA_FCT3EQ5 = FCT7[5]==0||U1REG[31]==0 ? U1REG>>U2REG[4:0] : // workaround for modelsim
                                -((-U1REG)>>U2REG[4:0]);
`else
    wire [31:0] RDATA_FCT3EQ5 = (FCT7[5] ? U1REG>>>U2REG[4:0] : U1REG>>U2REG[4:0]);
`endif                        
    wire [31:0] RDATA = FCT3==0 ? (FCT7[5] ? U1REG-U2REG : U1REG+U2REG) :
                        FCT3==1 ? U1REG<<U2REG[4:0] :
                        FCT3==2 ? S1REG<S2REG?1:0 : // signed
                        FCT3==3 ? U1REG<U2REG?1:0 : // unsigned
                        FCT3==5 ? RDATA_FCT3EQ5 : // (FCT7[5] ? U1REG>>>U2REG[4:0] : U1REG>>U2REG[4:0]) :
                        FCT3==4 ? U1REG^U2REG :                        
                        FCT3==6 ? U1REG|U2REG :
                        FCT3==7 ? U1REG&U2REG :                        
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
`ifdef STAGE3

        FLUSH <= RES ? 2 : HLT ? FLUSH :        // reset and halt
                       FLUSH ? FLUSH-1 : 
                       (JAL||JALR||BMUX||RES) ? 2 : 0;  // flush the pipeline!
`else
        FLUSH <= RES ? 1 : HLT ? FLUSH :        // reset and halt
                       (JAL||JALR||BMUX||RES);  // flush the pipeline!
`endif
        REG[DPTR] <=   RES ? RESET_SP  :        // reset sp
                       HLT ? REG[DPTR] :        // halt
                     !DPTR ? 0 :                // x0 = 0, always!
                     AUIPC ? NXPC+SIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                       LCC ? LDATA :
                       MCC ? MDATA : 
                       RCC ? RDATA : 
                       CCC ? CDATA : 
                             REG[DPTR];

`ifdef STAGE3

        NXPC <= RES ? RESET_PC : HLT ? NXPC : NXPC2;
        
        NXPC2 <=  RES ? RESET_PC : HLT ? NXPC2 :   // reset and halt
                 JREQ ? JVAL :                    // jmp/bra
                        NXPC2+4;                   // normal flow
`else
        NXPC <= RES ? RESET_PC : HLT ? NXPC :   // reset and halt
              JREQ ? JVAL :                   // jmp/bra
                     NXPC+4;                   // normal flow
`endif

        PC   <= RES ? RESET_PC : HLT ? PC : NXPC; // current program counter

`ifdef DEBUG
        if(PC=4)                $display("pipeline stages=%d",     STAGES);
        if(OPCODE[6:0]==`LUI)   $display("%08x: %08x %08x lui",    PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`AUIPC) $display("%08x: %08x %08x auipc",  PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`JAL)   $display("%08x: %08x %08x jal",    PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`JALR)  $display("%08x: %08x %08x jalr",   PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`BCC)   $display("%08x: %08x %08x bcc",    PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`LCC)   $display("%08x: %08x %08x lcc",    PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`SCC)   $display("%08x: %08x %08x scc",    PC,XIDATA,OPCODE);
        if(OPCODE[6:0]==`MCC)   $display("%08x: %08x %08x mcc",    PC,XIDATA,OPCODE);        
        if(OPCODE[6:0]==`RCC)   $display("%08x: %08x %08x rcc",    PC,XIDATA,OPCODE);                
        if(OPCODE[6:0]==0)      $display("%08x: %08x %08x flush",  PC,XIDATA,OPCODE);                
`endif        
    end

    // IO and memory interface

    assign DATAO = SDATA; // SCC ? SDATA : 0;
    assign DADDR = U1REG + SIMM; // (SCC||LCC) ? U1REG + SIMM : 0;
    assign RD = LCC;
    assign WR = SCC;
`ifdef STAGE3
    assign IADDR = NXPC2;
`else
    assign IADDR = NXPC;
`endif        

    assign DEBUG = { RES, FLUSH, WR, RD };

endmodule
