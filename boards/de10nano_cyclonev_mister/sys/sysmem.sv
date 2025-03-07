`timescale 1 ps / 1 ps
module sysmem_lite
(
	output         clock,
	output         reset_out,

	input          reset_hps_cold_req,
	input          reset_hps_warm_req,
	input          reset_core_req,

	input          ram1_clk,
	input   [28:0] ram1_address,
	input    [7:0] ram1_burstcount,
	output         ram1_waitrequest,
	output  [63:0] ram1_readdata,
	output         ram1_readdatavalid,
	input          ram1_read,
	input   [63:0] ram1_writedata,
	input    [7:0] ram1_byteenable,
	input          ram1_write,

	input          ram2_clk,
	input   [28:0] ram2_address,
	input    [7:0] ram2_burstcount,
	output         ram2_waitrequest,
	output  [63:0] ram2_readdata,
	output         ram2_readdatavalid,
	input          ram2_read,
	input   [63:0] ram2_writedata,
	input    [7:0] ram2_byteenable,
	input          ram2_write,

	input          vbuf_clk,
	input   [27:0] vbuf_address,
	input    [7:0] vbuf_burstcount,
	output         vbuf_waitrequest,
	output [127:0] vbuf_readdata,
	output         vbuf_readdatavalid,
	input          vbuf_read,
	input  [127:0] vbuf_writedata,
	input   [15:0] vbuf_byteenable,
	input          vbuf_write
);

assign reset_out = ~init_reset_n | ~hps_h2f_reset_n | reset_core_req;

////////////////////////////////////////////////////////
////          f2sdram_safe_terminator_ram1          ////
////////////////////////////////////////////////////////
wire  [28:0] f2h_ram1_address;
wire   [7:0] f2h_ram1_burstcount;
wire         f2h_ram1_waitrequest;
wire  [63:0] f2h_ram1_readdata;
wire         f2h_ram1_readdatavalid;
wire         f2h_ram1_read;
wire  [63:0] f2h_ram1_writedata;
wire   [7:0] f2h_ram1_byteenable;
wire         f2h_ram1_write;

(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"} *) reg ram1_reset_0 = 1'b1;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"} *) reg ram1_reset_1 = 1'b1;
always @(posedge ram1_clk) begin
	ram1_reset_0 <= reset_out;
	ram1_reset_1 <= ram1_reset_0;
end

f2sdram_safe_terminator #(64, 8) f2sdram_safe_terminator_ram1
(
	.clk                      (ram1_clk),
	.rst_req_sync             (ram1_reset_1),

	.waitrequest_slave        (ram1_waitrequest),
	.burstcount_slave         (ram1_burstcount),
	.address_slave            (ram1_address),
	.readdata_slave           (ram1_readdata),
	.readdatavalid_slave      (ram1_readdatavalid),
	.read_slave               (ram1_read),
	.writedata_slave          (ram1_writedata),
	.byteenable_slave         (ram1_byteenable),
	.write_slave              (ram1_write),

	.waitrequest_master       (f2h_ram1_waitrequest),
	.burstcount_master        (f2h_ram1_burstcount),
	.address_master           (f2h_ram1_address),
	.readdata_master          (f2h_ram1_readdata),
	.readdatavalid_master     (f2h_ram1_readdatavalid),
	.read_master              (f2h_ram1_read),
	.writedata_master         (f2h_ram1_writedata),
	.byteenable_master        (f2h_ram1_byteenable),
	.write_master             (f2h_ram1_write)
);

////////////////////////////////////////////////////////
////          f2sdram_safe_terminator_ram2          ////
////////////////////////////////////////////////////////
wire  [28:0] f2h_ram2_address;
wire   [7:0] f2h_ram2_burstcount;
wire         f2h_ram2_waitrequest;
wire  [63:0] f2h_ram2_readdata;
wire         f2h_ram2_readdatavalid;
wire         f2h_ram2_read;
wire  [63:0] f2h_ram2_writedata;
wire   [7:0] f2h_ram2_byteenable;
wire         f2h_ram2_write;

(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"} *) reg ram2_reset_0 = 1'b1;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"} *) reg ram2_reset_1 = 1'b1;
always @(posedge ram2_clk) begin
	ram2_reset_0 <= reset_out;
	ram2_reset_1 <= ram2_reset_0;
end

f2sdram_safe_terminator #(64, 8) f2sdram_safe_terminator_ram2
(
	.clk                      (ram2_clk),
	.rst_req_sync             (ram2_reset_1),

	.waitrequest_slave        (ram2_waitrequest),
	.burstcount_slave         (ram2_burstcount),
	.address_slave            (ram2_address),
	.readdata_slave           (ram2_readdata),
	.readdatavalid_slave      (ram2_readdatavalid),
	.read_slave               (ram2_read),
	.writedata_slave          (ram2_writedata),
	.byteenable_slave         (ram2_byteenable),
	.write_slave              (ram2_write),

	.waitrequest_master       (f2h_ram2_waitrequest),
	.burstcount_master        (f2h_ram2_burstcount),
	.address_master           (f2h_ram2_address),
	.readdata_master          (f2h_ram2_readdata),
	.readdatavalid_master     (f2h_ram2_readdatavalid),
	.read_master              (f2h_ram2_read),
	.writedata_master         (f2h_ram2_writedata),
	.byteenable_master        (f2h_ram2_byteenable),
	.write_master             (f2h_ram2_write)
);

////////////////////////////////////////////////////////
////          f2sdram_safe_terminator_vbuf          ////
////////////////////////////////////////////////////////
wire  [27:0] f2h_vbuf_address;
wire   [7:0] f2h_vbuf_burstcount;
wire         f2h_vbuf_waitrequest;
wire [127:0] f2h_vbuf_readdata;
wire         f2h_vbuf_readdatavalid;
wire         f2h_vbuf_read;
wire [127:0] f2h_vbuf_writedata;
wire  [15:0] f2h_vbuf_byteenable;
wire         f2h_vbuf_write;

(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"} *) reg vbuf_reset_0 = 1'b1;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"} *) reg vbuf_reset_1 = 1'b1;
always @(posedge vbuf_clk) begin
	vbuf_reset_0 <= reset_out;
	vbuf_reset_1 <= vbuf_reset_0;
end

f2sdram_safe_terminator #(128, 8) f2sdram_safe_terminator_vbuf
(
	.clk                      (vbuf_clk),
	.rst_req_sync             (vbuf_reset_1),

	.waitrequest_slave        (vbuf_waitrequest),
	.burstcount_slave         (vbuf_burstcount),
	.address_slave            (vbuf_address),
	.readdata_slave           (vbuf_readdata),
	.readdatavalid_slave      (vbuf_readdatavalid),
	.read_slave               (vbuf_read),
	.writedata_slave          (vbuf_writedata),
	.byteenable_slave         (vbuf_byteenable),
	.write_slave              (vbuf_write),

	.waitrequest_master       (f2h_vbuf_waitrequest),
	.burstcount_master        (f2h_vbuf_burstcount),
	.address_master           (f2h_vbuf_address),
	.readdata_master          (f2h_vbuf_readdata),
	.readdatavalid_master     (f2h_vbuf_readdatavalid),
	.read_master              (f2h_vbuf_read),
	.writedata_master         (f2h_vbuf_writedata),
	.byteenable_master        (f2h_vbuf_byteenable),
	.write_master             (f2h_vbuf_write)
);

////////////////////////////////////////////////////////
////             HPS <> FPGA interfaces             ////
////////////////////////////////////////////////////////
sysmem_HPS_fpga_interfaces fpga_interfaces (
	.f2h_cold_rst_req_n       (~reset_hps_cold_req),
	.f2h_warm_rst_req_n       (~reset_hps_warm_req),
	.h2f_user0_clk            (clock),
	.h2f_rst_n                (hps_h2f_reset_n),
	.f2h_sdram0_clk           (vbuf_clk),
	.f2h_sdram0_ADDRESS       (f2h_vbuf_address),
	.f2h_sdram0_BURSTCOUNT    (f2h_vbuf_burstcount),
	.f2h_sdram0_WAITREQUEST   (f2h_vbuf_waitrequest),
	.f2h_sdram0_READDATA      (f2h_vbuf_readdata),
	.f2h_sdram0_READDATAVALID (f2h_vbuf_readdatavalid),
	.f2h_sdram0_READ          (f2h_vbuf_read),
	.f2h_sdram0_WRITEDATA     (f2h_vbuf_writedata),
	.f2h_sdram0_BYTEENABLE    (f2h_vbuf_byteenable),
	.f2h_sdram0_WRITE         (f2h_vbuf_write),
	.f2h_sdram1_clk           (ram1_clk),
	.f2h_sdram1_ADDRESS       (f2h_ram1_address),
	.f2h_sdram1_BURSTCOUNT    (f2h_ram1_burstcount),
	.f2h_sdram1_WAITREQUEST   (f2h_ram1_waitrequest),
	.f2h_sdram1_READDATA      (f2h_ram1_readdata),
	.f2h_sdram1_READDATAVALID (f2h_ram1_readdatavalid),
	.f2h_sdram1_READ          (f2h_ram1_read),
	.f2h_sdram1_WRITEDATA     (f2h_ram1_writedata),
	.f2h_sdram1_BYTEENABLE    (f2h_ram1_byteenable),
	.f2h_sdram1_WRITE         (f2h_ram1_write),
	.f2h_sdram2_clk           (ram2_clk),
	.f2h_sdram2_ADDRESS       (f2h_ram2_address),
	.f2h_sdram2_BURSTCOUNT    (f2h_ram2_burstcount),
	.f2h_sdram2_WAITREQUEST   (f2h_ram2_waitrequest),
	.f2h_sdram2_READDATA      (f2h_ram2_readdata),
	.f2h_sdram2_READDATAVALID (f2h_ram2_readdatavalid),
	.f2h_sdram2_READ          (f2h_ram2_read),
	.f2h_sdram2_WRITEDATA     (f2h_ram2_writedata),
	.f2h_sdram2_BYTEENABLE    (f2h_ram2_byteenable),
	.f2h_sdram2_WRITE         (f2h_ram2_write)
);

wire hps_h2f_reset_n;

reg init_reset_n = 0;
always @(posedge clock) begin
	integer timeout = 0;

	if(timeout < 2000000) begin
		init_reset_n <= 0;
		timeout <= timeout + 1;
	end
	else init_reset_n <= 1;
end

endmodule


module sysmem_HPS_fpga_interfaces
(
	// h2f_reset
	output wire [1 - 1 : 0 ] h2f_rst_n

	// f2h_cold_reset_req
	,input wire [1 - 1 : 0 ] f2h_cold_rst_req_n

	// f2h_warm_reset_req
	,input wire [1 - 1 : 0 ] f2h_warm_rst_req_n

	// h2f_user0_clock
	,output wire [1 - 1 : 0 ] h2f_user0_clk

	// f2h_sdram0_data
	,input wire [28 - 1 : 0 ] f2h_sdram0_ADDRESS
	,input wire [8 - 1 : 0 ] f2h_sdram0_BURSTCOUNT
	,output wire [1 - 1 : 0 ] f2h_sdram0_WAITREQUEST
	,output wire [128 - 1 : 0 ] f2h_sdram0_READDATA
	,output wire [1 - 1 : 0 ] f2h_sdram0_READDATAVALID
	,input wire [1 - 1 : 0 ] f2h_sdram0_READ
	,input wire [128 - 1 : 0 ] f2h_sdram0_WRITEDATA
	,input wire [16 - 1 : 0 ] f2h_sdram0_BYTEENABLE
	,input wire [1 - 1 : 0 ] f2h_sdram0_WRITE

	// f2h_sdram0_clock
	,input wire [1 - 1 : 0 ] f2h_sdram0_clk

	// f2h_sdram1_data
	,input wire [29 - 1 : 0 ] f2h_sdram1_ADDRESS
	,input wire [8 - 1 : 0 ] f2h_sdram1_BURSTCOUNT
	,output wire [1 - 1 : 0 ] f2h_sdram1_WAITREQUEST
	,output wire [64 - 1 : 0 ] f2h_sdram1_READDATA
	,output wire [1 - 1 : 0 ] f2h_sdram1_READDATAVALID
	,input wire [1 - 1 : 0 ] f2h_sdram1_READ
	,input wire [64 - 1 : 0 ] f2h_sdram1_WRITEDATA
	,input wire [8 - 1 : 0 ] f2h_sdram1_BYTEENABLE
	,input wire [1 - 1 : 0 ] f2h_sdram1_WRITE

	// f2h_sdram1_clock
	,input wire [1 - 1 : 0 ] f2h_sdram1_clk

	// f2h_sdram2_data
	,input wire [29 - 1 : 0 ] f2h_sdram2_ADDRESS
	,input wire [8 - 1 : 0 ] f2h_sdram2_BURSTCOUNT
	,output wire [1 - 1 : 0 ] f2h_sdram2_WAITREQUEST
	,output wire [64 - 1 : 0 ] f2h_sdram2_READDATA
	,output wire [1 - 1 : 0 ] f2h_sdram2_READDATAVALID
	,input wire [1 - 1 : 0 ] f2h_sdram2_READ
	,input wire [64 - 1 : 0 ] f2h_sdram2_WRITEDATA
	,input wire [8 - 1 : 0 ] f2h_sdram2_BYTEENABLE
	,input wire [1 - 1 : 0 ] f2h_sdram2_WRITE

	// f2h_sdram2_clock
	,input wire [1 - 1 : 0 ] f2h_sdram2_clk
);


wire [29 - 1 : 0] intermediate;
assign intermediate[0:0] = ~intermediate[1:1];
assign intermediate[8:8] = intermediate[4:4]|intermediate[7:7];
assign intermediate[2:2] = intermediate[9:9];
assign intermediate[3:3] = intermediate[9:9];
assign intermediate[5:5] = intermediate[9:9];
assign intermediate[6:6] = intermediate[9:9];
assign intermediate[10:10] = intermediate[9:9];
assign intermediate[11:11] = ~intermediate[12:12];
assign intermediate[17:17] = intermediate[14:14]|intermediate[16:16];
assign intermediate[13:13] = intermediate[18:18];
assign intermediate[15:15] = intermediate[18:18];
assign intermediate[19:19] = intermediate[18:18];
assign intermediate[20:20] = ~intermediate[21:21];
assign intermediate[26:26] = intermediate[23:23]|intermediate[25:25];
assign intermediate[22:22] = intermediate[27:27];
assign intermediate[24:24] = intermediate[27:27];
assign intermediate[28:28] = intermediate[27:27];
assign f2h_sdram0_WAITREQUEST[0:0] = intermediate[0:0];
assign f2h_sdram1_WAITREQUEST[0:0] = intermediate[11:11];
assign f2h_sdram2_WAITREQUEST[0:0] = intermediate[20:20];
assign intermediate[4:4] = f2h_sdram0_READ[0:0];
assign intermediate[7:7] = f2h_sdram0_WRITE[0:0];
assign intermediate[9:9] = f2h_sdram0_clk[0:0];
assign intermediate[14:14] = f2h_sdram1_READ[0:0];
assign intermediate[16:16] = f2h_sdram1_WRITE[0:0];
assign intermediate[18:18] = f2h_sdram1_clk[0:0];
assign intermediate[23:23] = f2h_sdram2_READ[0:0];
assign intermediate[25:25] = f2h_sdram2_WRITE[0:0];
assign intermediate[27:27] = f2h_sdram2_clk[0:0];

cyclonev_hps_interface_clocks_resets clocks_resets(
 .f2h_warm_rst_req_n({
    f2h_warm_rst_req_n[0:0] // 0:0
  })
,.f2h_pending_rst_ack({
    1'b1 // 0:0
  })
,.f2h_dbg_rst_req_n({
    1'b1 // 0:0
  })
,.h2f_rst_n({
    h2f_rst_n[0:0] // 0:0
  })
,.f2h_cold_rst_req_n({
    f2h_cold_rst_req_n[0:0] // 0:0
  })
,.h2f_user0_clk({
    h2f_user0_clk[0:0] // 0:0
  })
);


cyclonev_hps_interface_dbg_apb debug_apb(
 .DBG_APB_DISABLE({
    1'b0 // 0:0
  })
,.P_CLK_EN({
    1'b0 // 0:0
  })
);


cyclonev_hps_interface_tpiu_trace tpiu(
 .traceclk_ctl({
    1'b1 // 0:0
  })
);


cyclonev_hps_interface_boot_from_fpga boot_from_fpga(
 .boot_from_fpga_ready({
    1'b0 // 0:0
  })
,.boot_from_fpga_on_failure({
    1'b0 // 0:0
  })
,.bsel_en({
    1'b0 // 0:0
  })
,.csel_en({
    1'b0 // 0:0
  })
,.csel({
    2'b01 // 1:0
  })
,.bsel({
    3'b001 // 2:0
  })
);


cyclonev_hps_interface_fpga2hps fpga2hps(
 .port_size_config({
    2'b11 // 1:0
  })
);


cyclonev_hps_interface_hps2fpga hps2fpga(
 .port_size_config({
    2'b11 // 1:0
  })
);


cyclonev_hps_interface_fpga2sdram f2sdram(
 .cfg_rfifo_cport_map({
    16'b0010000100000000 // 15:0
  })
,.cfg_wfifo_cport_map({
    16'b0010000100000000 // 15:0
  })
,.rd_ready_3({
    1'b1 // 0:0
  })
,.cmd_port_clk_2({
    intermediate[28:28] // 0:0
  })
,.rd_ready_2({
    1'b1 // 0:0
  })
,.cmd_port_clk_1({
    intermediate[19:19] // 0:0
  })
,.rd_ready_1({
    1'b1 // 0:0
  })
,.cmd_port_clk_0({
    intermediate[10:10] // 0:0
  })
,.rd_ready_0({
    1'b1 // 0:0
  })
,.wrack_ready_2({
    1'b1 // 0:0
  })
,.wrack_ready_1({
    1'b1 // 0:0
  })
,.wrack_ready_0({
    1'b1 // 0:0
  })
,.cmd_ready_2({
    intermediate[21:21] // 0:0
  })
,.cmd_ready_1({
    intermediate[12:12] // 0:0
  })
,.cmd_ready_0({
    intermediate[1:1] // 0:0
  })
,.cfg_port_width({
    12'b000000010110 // 11:0
  })
,.rd_valid_3({
    f2h_sdram2_READDATAVALID[0:0] // 0:0
  })
,.rd_valid_2({
    f2h_sdram1_READDATAVALID[0:0] // 0:0
  })
,.rd_valid_1({
    f2h_sdram0_READDATAVALID[0:0] // 0:0
  })
,.rd_clk_3({
    intermediate[22:22] // 0:0
  })
,.rd_data_3({
    f2h_sdram2_READDATA[63:0] // 63:0
  })
,.rd_clk_2({
    intermediate[13:13] // 0:0
  })
,.rd_data_2({
    f2h_sdram1_READDATA[63:0] // 63:0
  })
,.rd_clk_1({
    intermediate[3:3] // 0:0
  })
,.rd_data_1({
    f2h_sdram0_READDATA[127:64] // 63:0
  })
,.rd_clk_0({
    intermediate[2:2] // 0:0
  })
,.rd_data_0({
    f2h_sdram0_READDATA[63:0] // 63:0
  })
,.cfg_axi_mm_select({
    6'b000000 // 5:0
  })
,.cmd_valid_2({
    intermediate[26:26] // 0:0
  })
,.cmd_valid_1({
    intermediate[17:17] // 0:0
  })
,.cmd_valid_0({
    intermediate[8:8] // 0:0
  })
,.cfg_cport_rfifo_map({
    18'b000000000011010000 // 17:0
  })
,.wr_data_3({
    2'b00 // 89:88
   ,f2h_sdram2_BYTEENABLE[7:0] // 87:80
   ,16'b0000000000000000 // 79:64
   ,f2h_sdram2_WRITEDATA[63:0] // 63:0
  })
,.wr_data_2({
    2'b00 // 89:88
   ,f2h_sdram1_BYTEENABLE[7:0] // 87:80
   ,16'b0000000000000000 // 79:64
   ,f2h_sdram1_WRITEDATA[63:0] // 63:0
  })
,.wr_data_1({
    2'b00 // 89:88
   ,f2h_sdram0_BYTEENABLE[15:8] // 87:80
   ,16'b0000000000000000 // 79:64
   ,f2h_sdram0_WRITEDATA[127:64] // 63:0
  })
,.cfg_cport_type({
    12'b000000111111 // 11:0
  })
,.wr_data_0({
    2'b00 // 89:88
   ,f2h_sdram0_BYTEENABLE[7:0] // 87:80
   ,16'b0000000000000000 // 79:64
   ,f2h_sdram0_WRITEDATA[63:0] // 63:0
  })
,.cfg_cport_wfifo_map({
    18'b000000000011010000 // 17:0
  })
,.wr_clk_3({
    intermediate[24:24] // 0:0
  })
,.wr_clk_2({
    intermediate[15:15] // 0:0
  })
,.wr_clk_1({
    intermediate[6:6] // 0:0
  })
,.wr_clk_0({
    intermediate[5:5] // 0:0
  })
,.cmd_data_2({
    18'b000000000000000000 // 59:42
   ,f2h_sdram2_BURSTCOUNT[7:0] // 41:34
   ,3'b000 // 33:31
   ,f2h_sdram2_ADDRESS[28:0] // 30:2
   ,intermediate[25:25] // 1:1
   ,intermediate[23:23] // 0:0
  })
,.cmd_data_1({
    18'b000000000000000000 // 59:42
   ,f2h_sdram1_BURSTCOUNT[7:0] // 41:34
   ,3'b000 // 33:31
   ,f2h_sdram1_ADDRESS[28:0] // 30:2
   ,intermediate[16:16] // 1:1
   ,intermediate[14:14] // 0:0
  })
,.cmd_data_0({
    18'b000000000000000000 // 59:42
   ,f2h_sdram0_BURSTCOUNT[7:0] // 41:34
   ,4'b0000 // 33:30
   ,f2h_sdram0_ADDRESS[27:0] // 29:2
   ,intermediate[7:7] // 1:1
   ,intermediate[4:4] // 0:0
  })
);

endmodule
