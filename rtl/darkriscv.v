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

module darkriscv
(
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

    // flush instriction pipeline    
    reg FLUSH = 1;

    // idata is break apart as described in the RV32I specification

    wire [6:0] OPCODE = FLUSH ? 0 : IDATA[6:0];
    wire [4:0] DPTR   = RES ? 2 : IDATA[11:7];
    wire [2:0] FCT3   = IDATA[14:12];
    wire [4:0] S1PTR  = IDATA[19:15];
    wire [4:0] S2PTR  = IDATA[24:20];
    wire [6:0] FCT7   = IDATA[31:25];    
    
    // dummy 32-bit words w/ all-0s and all-1s: 

    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;

    // signal extended immediate, according to the instruction type:
    
    wire [31:0] SIMM   = SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                         BCC ? { IDATA[31] ? ALL1[31:13]:ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                         JAL ? { IDATA[31] ? ALL1[31:21]:ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                         LUI||
                         AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                 { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:20] }; // i-type

    // non-signal extended immediate, according to the instruction type:

    wire [31:0] UIMM   = SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                         BCC ? { ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                         JAL ? { ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                         LUI||
                         AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                 { ALL0[31:12], IDATA[31:20] }; // i-type
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

    reg [31:0] PC;		    // 32-bit program counter
    reg [31:0] REG [0:31];	// general-purpose 32x32-bit registers

    integer i;
    
    initial for(i=0;i!=32;i=i+1) REG[i] = 0;		// makes the simulation looks better!

    // source-1 and source-1 register selection, with impicit 0 value in the x0:

    wire signed   [31:0] S1REG = S1PTR ? REG[S1PTR] : 0;
    wire signed   [31:0] S2REG = S2PTR ? REG[S2PTR] : 0;
    wire          [31:0] U1REG = S1PTR ? REG[S1PTR] : 0;
    wire          [31:0] U2REG = S2PTR ? REG[S2PTR] : 0;
    
    wire [31:0] LDATA = DATAI;  // the load instruction is not fully implemented yet
    wire [31:0] CDATA = 0;	// status register istructions not implemented yet

    // M-group of instructions (OPCODE==7'b0010011)

    wire [31:0] MDATA = FCT3==0 ? U1REG+SIMM :
                        FCT3==1 ? U1REG<<S2PTR :
                        FCT3==2 ? U1REG<SIMM?1:0 :
                        FCT3==3 ? U1REG<UIMM?1:0 :
                        FCT3==5 ? (IDATA[30] ? U1REG>>>S2PTR : U1REG>>S2PTR) :                        
                        FCT3==4 ? U1REG^SIMM :
                        FCT3==6 ? U1REG|SIMM :
                        FCT3==7 ? U1REG&SIMM :                           
                                  0;

    // R-group of instructions (OPCODE==7'b0110011)
                        
    wire [31:0] RDATA = FCT3==0 ? (IDATA[30] ? U1REG-U2REG : U1REG+U2REG) :
                        FCT3==1 ? U1REG<<U2REG[4:0] :
                        FCT3==2 ? S1REG<S2REG?1:0 : // signed
                        FCT3==3 ? U1REG<U2REG?1:0 : // unsigned
                        FCT3==5 ? (IDATA[30] ? U1REG>>>U2REG[4:0] : U1REG>>U2REG[4:0]) :
                        FCT3==4 ? U1REG^U2REG :                        
                        FCT3==6 ? U1REG|U2REG :
                        FCT3==7 ? U1REG&U2REG :                        
                                  0;
                                  
    wire [31:0] JALRSUM = U1REG+SIMM; // 32-bit sum for J-instruction

    // B-group of instructions (OPCODE==7'b1100011)
    
    wire BMUX       = BCC==1 && (
                          FCT3==4 ? S1REG>=S2REG : // signed
                          FCT3==5 ? S1REG<=S2REG : // signed
                          FCT3==6 ? U1REG>=U2REG : // unsigned
                          FCT3==7 ? U1REG<=U2REG : // unsigned
                          FCT3==0 ? U1REG==U2REG : 
                          FCT3==1 ? U1REG!=U2REG : 
                                    0);
            
    always@(posedge CLK)
    begin
        if(HLT)
        begin
            if(RES)
            begin
                PC        <= 0;  // initial program counter
                FLUSH     <= 1;  // initial pipeline configuration
                REG[DPTR] <= 2048; // initial stack pointer
            end
        end
        else
        begin
            FLUSH <= (JAL||JALR||BMUX) ? 1 : 0;     // flush the pipeline!
            
            REG[DPTR] <= AUIPC ? PC+SIMM :          // register bank update
                         JAL||JALR ? PC :
                         LUI ? SIMM :
                         LCC ? LDATA :
                         MCC ? MDATA : 
                         RCC ? RDATA : 
                         CCC ? CDATA : 
                               REG[DPTR];
        
            PC <= JAL  ? PC+SIMM-4 : // program counter update
                  JALR ? JALRSUM : 
                  BMUX ? PC+SIMM : 
                  PC+4;
        end
    end

    // IO and memory interface

    assign DATAO = (SCC||LCC) ? U2REG : 0;
    assign DADDR = (SCC||LCC) ? U1REG + SIMM : 0;
    assign RD = LCC;
    assign WR = SCC;

    assign IADDR = PC;
        
    assign DEBUG = { RES, FLUSH, WR, RD };

endmodule
