/*
 *  mt48lc16m16a2_ctrl - A sdram controller
 *
 *  Copyright (C) 2022  Hirosh Dabui <hirosh@dabui.de>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */
 
//`default_nettype none 
`timescale 1ns / 1ps

// ===============================
// 16Mx16 = 32MByte
// Row addressing 8k (A0-A12)
// Bank Switching 4 (BA0, BA1)
// Column Addressing 512 (A0-A8)
// ===============================

module mt48lc16m16a2_ctrl #(
    parameter SDRAM_CLK_FREQ = 64,
    parameter TRP_NS = 20,
    parameter TRC_NS = 66,
    parameter TRCD_NS = 20,
    parameter TCH_NS = 2,
    parameter CAS = 3'd2
) (
    input wire clk,
    input wire resetn,

    input wire [24:0] addr,
    input wire [31:0] din,
    input wire [3:0] wmask,
    input wire valid,
    output reg [31:0] dout,
    output reg ready,

    output wire sdram_clk,
    output wire sdram_cke,
    output wire [1:0] sdram_dqm,
    output wire [12:0] sdram_addr,  //  A0-A12 row address, A0-A8 column address
    output wire [1:0] sdram_ba,  // bank select A11,A12
    output wire sdram_csn,
    output wire sdram_wen,
    output wire sdram_rasn,
    output wire sdram_casn,
    inout wire [15:0] sdram_dq
);

  localparam ONE_MICROSECOND = SDRAM_CLK_FREQ;
  localparam WAIT_100US = 100 * ONE_MICROSECOND;  // 64 * 1/64e6 = 1us => 100 * 1us
  // command period; PRE to ACT in ns, e.g. 20ns
  parameter TRP = $rtoi((TRP_NS * ONE_MICROSECOND / 1000) + 1);
  // tRC command period (REF to REF/ACT TO ACT) in ns
  parameter TRC = $rtoi((TRC_NS * ONE_MICROSECOND / 1000) + 1);  //
  // tRCD active command to read/write command delay; row-col-delay in ns
  parameter TRCD = $rtoi((TRCD_NS * ONE_MICROSECOND / 1000) + 1);
  // tCH command hold time
  parameter TCH = $rtoi((TCH_NS * ONE_MICROSECOND / 1000) + 1);

  initial begin
    $display("sdram:         CLK: %0d MHz", SDRAM_CLK_FREQ);
    $display("sdram:  WAIT_100US: %0d cycles", WAIT_100US);
    $display("sdram:         TRP: %0d cycles", TRP);
    $display("sdram:         TRC: %0d cycles", TRC);
    $display("sdram:        TRCD: %0d cycles", TRCD);
    $display("sdram:         TCH: %0d cycles", TCH);
    $display("sdram: CAS_LATENCY: %0d cycles", CAS_LATENCY);
  end

  localparam BURST_LENGTH = 3'b001;  // 000=1, 001=2, 010=4, 011=8
  localparam ACCESS_TYPE = 1'b0;  // 0=sequential, 1=interleaved
  localparam CAS_LATENCY = CAS;  // 2/3 allowed, tRCD=20ns -> 3 cycles@128MHz
  localparam OP_MODE = 2'b00;  // only 00 (standard operation) allowed
  localparam NO_WRITE_BURST = 1'b0;  // 0= write burst enabled, 1=only single access write
  localparam sdram_mode = {1'b0, NO_WRITE_BURST, OP_MODE, CAS_LATENCY, ACCESS_TYPE, BURST_LENGTH};
  //
  // ISSI-IS425 datasheet page 16
  // (CS, RAS, CAS, WE)
  localparam CMD_MRS = 4'b0000;  // mode register set
  localparam CMD_ACT = 4'b0011;  // bank active
  localparam CMD_READ = 4'b0101;  // to have read variant with autoprecharge set A10=H
  localparam CMD_WRITE = 4'b0100;  // A10=H to have autoprecharge
  localparam CMD_BST = 4'b0110;  // burst stop
  localparam CMD_PRE = 4'b0010;  // precharge selected bank, A10=H both banks
  localparam CMD_REF = 4'b0001;  // auto refresh (cke=H), selfrefresh assign cke=L
  localparam CMD_NOP = 4'b0111;
  localparam CMD_DSEL = 4'b1xxx;

  reg [3:0] command;
  reg [3:0] command_nxt;
  reg cke;
  reg cke_nxt;
  reg [1:0] dqm;
  reg [12:0] saddr;
  reg [12:0] saddr_nxt;
  reg [1:0] ba;
  reg [1:0] ba_nxt;

  assign sdram_clk = clk;
  assign sdram_cke = cke;
  assign sdram_addr = saddr;
  assign sdram_dqm = dqm;
  assign {sdram_csn, sdram_rasn, sdram_casn, sdram_wen} = command;
  assign sdram_ba = ba;

  // state machine stuff
  localparam RESET = 0;
  localparam ASSERT_CKE = 1;
  localparam INIT_SEQ_PRE_CHARGE_ALL = 2;
  localparam INIT_SEQ_AUTO_REFRESH0 = 3;
  localparam INIT_SEQ_AUTO_REFRESH1 = 4;
  localparam INIT_SEQ_LOAD_MODE = 5;
  localparam IDLE = 6;
  localparam COL_READ = 7;
  localparam COL_READL = 8;
  localparam COL_READH = 9;
  localparam COL_WRITEL = 10;
  localparam COL_WRITEH = 11;
  localparam AUTO_REFRESH = 12;
  localparam PRE_CHARGE_ALL = 13;
  localparam WAIT_STATE = 14;
  localparam LAST_STATE = 15;

  parameter STATE_WIDTH = $clog2(LAST_STATE);

  reg [STATE_WIDTH -1:0] state;
  reg [STATE_WIDTH -1:0] state_nxt;
  reg [STATE_WIDTH -1:0] ret_state;
  reg [STATE_WIDTH -1:0] ret_state_nxt;
  parameter WAIT_STATE_WIDTH = $clog2(WAIT_100US);
  reg [WAIT_STATE_WIDTH -1:0] wait_states;
  reg [WAIT_STATE_WIDTH -1:0] wait_states_nxt;

  reg ready_nxt;
  reg [31:0] dout_nxt;
  reg [1:0] dqm_nxt;

  reg update_ready;
  reg update_ready_nxt;

  reg [15:0] dq;
  reg [15:0] dq_nxt;
  assign sdram_dq = oe ? dq : 16'hz;

  reg oe;
  reg oe_nxt;

  always @(posedge clk) begin
    if (~resetn) begin
      state <= RESET;
      ret_state <= RESET;
      ready <= 1'b0;
      wait_states <= 0;
      dout <= 0;
      command <= CMD_NOP;
      dqm <= 2'b11;
      dq <= 0;
      ba <= 2'b11;
      oe <= 1'b0;
      saddr <= 0;
      update_ready <= 1'b0;
    end else begin
      dq <= dq_nxt;
      dout <= dout_nxt;
      state <= state_nxt;
      ready <= ready_nxt;
      dqm <= dqm_nxt;
      cke <= cke_nxt;
      command <= command_nxt;
      wait_states <= wait_states_nxt;
      ret_state <= ret_state_nxt;
      ba <= ba_nxt;
      oe <= oe_nxt;
      saddr <= saddr_nxt;
      update_ready <= update_ready_nxt;
    end
  end

  always @(*) begin
    wait_states_nxt  = wait_states;
    state_nxt        = state;
    ready_nxt        = ready;
    ret_state_nxt    = ret_state;
    dout_nxt         = dout;
    command_nxt      = command;

    cke_nxt          = cke;
    saddr_nxt        = saddr;
    ba_nxt           = ba;
    dqm_nxt          = dqm;
    oe_nxt           = oe;
    dq_nxt           = dq;
    update_ready_nxt = update_ready;

    case (state)
      RESET: begin
        cke_nxt         = 1'b0;
        wait_states_nxt = WAIT_100US;
        ret_state_nxt   = ASSERT_CKE;
        state_nxt       = WAIT_STATE;
      end

      ASSERT_CKE: begin
        cke_nxt         = 1'b1;
        wait_states_nxt = 2;
        ret_state_nxt   = INIT_SEQ_PRE_CHARGE_ALL;
        state_nxt       = WAIT_STATE;
      end

      INIT_SEQ_PRE_CHARGE_ALL: begin
        cke_nxt         = 1'b1;
        command_nxt     = CMD_PRE;
        saddr_nxt[10]   = 1'b1;
        wait_states_nxt = TRP;
        ret_state_nxt   = INIT_SEQ_AUTO_REFRESH0;
        state_nxt       = WAIT_STATE;
      end

      INIT_SEQ_AUTO_REFRESH0: begin
        command_nxt = CMD_REF;
        wait_states_nxt = TRC;
        ret_state_nxt = INIT_SEQ_AUTO_REFRESH1;
        state_nxt = WAIT_STATE;
      end

      INIT_SEQ_AUTO_REFRESH1: begin
        command_nxt = CMD_REF;
        wait_states_nxt = TRC;
        ret_state_nxt = INIT_SEQ_LOAD_MODE;
        state_nxt = WAIT_STATE;
      end

      INIT_SEQ_LOAD_MODE: begin
        command_nxt = CMD_MRS;
        saddr_nxt = sdram_mode;
        wait_states_nxt = TCH;
        ret_state_nxt = IDLE;
        state_nxt = WAIT_STATE;
      end

      IDLE: begin
        oe_nxt = 1'b0;
        dqm_nxt = 2'b11;
        ready_nxt = 1'b0;
        if (valid && !ready) begin
          command_nxt     = CMD_ACT;
          ba_nxt          = addr[22:21];
          saddr_nxt       = {addr[24:23], addr[20:10]};
          wait_states_nxt = TRCD;
          ret_state_nxt   = |wmask ? COL_WRITEL : COL_READ;
          update_ready_nxt = 1'b1;
          state_nxt       = WAIT_STATE;
        end else begin
          /* autorefresh */
          command_nxt = CMD_DSEL; // CMD_REF;
          saddr_nxt = 0;
          ba_nxt = 0;
          wait_states_nxt = 3;  //TRC;
          ret_state_nxt = IDLE;
          update_ready_nxt = 1'b0;
          state_nxt = WAIT_STATE;
        end
      end

      COL_READ: begin
        command_nxt     = CMD_READ;
        dqm_nxt         = 2'b00;
        saddr_nxt       = {3'b001, addr[10:2], 1'b0};  // autoprecharge and column
        ba_nxt          = addr[22:21];
        wait_states_nxt = CAS_LATENCY;
        ret_state_nxt   = COL_READL;
        state_nxt       = WAIT_STATE;
      end

      COL_READL: begin
        command_nxt    = CMD_NOP;
        dqm_nxt        = 2'b00;
        dout_nxt[15:0] = sdram_dq;
        //wait_states_nxt = TRP;
        // ret_state_nxt   = COL_READH;
        state_nxt      = COL_READH;
      end

      COL_READH: begin
        command_nxt      = CMD_NOP;
        dqm_nxt          = 2'b00;
        dout_nxt[31:16]  = sdram_dq;
        wait_states_nxt  = TRP;
        ret_state_nxt    = IDLE;
        state_nxt        = WAIT_STATE;
      end

      COL_WRITEL: begin
        command_nxt = CMD_WRITE;
        dqm_nxt     = ~wmask[1:0];
        saddr_nxt   = {3'b001, addr[10:2], 1'b0};  // autoprecharge and column
        ba_nxt      = addr[22:21];
        dq_nxt      = din[15:0];
        oe_nxt      = 1'b1;
        //wait_states_nxt = TRP;
        //ret_state_nxt   = COL_WRITEH;
        state_nxt   = COL_WRITEH;
      end

      COL_WRITEH: begin
        command_nxt      = CMD_NOP;
        dqm_nxt          = ~wmask[3:2];
        saddr_nxt        = {3'b001, addr[10:2], 1'b0};  // autoprecharge and column
        ba_nxt           = addr[22:21];
        dq_nxt           = din[31:16];
        oe_nxt           = 1'b1;
        wait_states_nxt  = TRP;
        ret_state_nxt    = IDLE;
        state_nxt        = WAIT_STATE;
      end

      PRE_CHARGE_ALL: begin
        command_nxt = CMD_PRE;
        saddr_nxt[10] = 1'b1;  // select all banks
        ba_nxt = 0;
        wait_states_nxt = TRP;
        ret_state_nxt = IDLE;
        state_nxt = WAIT_STATE;
      end

      WAIT_STATE: begin
        command_nxt = CMD_NOP;
        wait_states_nxt = wait_states - 1;
        if (wait_states == 1) begin
          state_nxt = ret_state;
          if (ret_state == IDLE && update_ready) begin
            update_ready_nxt = 1'b0;
            ready_nxt = 1'b1;
          end
        end
      end

      default: begin
        state_nxt = state;
      end
    endcase
  end

endmodule
