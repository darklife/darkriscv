`timescale 1ns / 1ps
`include "../../rtl/config.vh"

module darkram #(parameter INIT_FILE = "../memory_init.mif")
(
    input           CLK,    // Clock
    input           RES,    // Reset
    input           HLT,    // Halt

    input           IDREQ,  // Instruction fetch request
    input  [31:0]   IADDR,  // Instruction address
    output [31:0]   IDATA,  // Instruction data output
    output          IDACK,  // Instruction acknowledge

    input           XDREQ,  // Data request
    input           XRD,    // Read enable
    input           XWR,    // Write enable
    input  [3:0]    XBE,    // Byte enable
    input  [31:0]   XADDR,  // Data address
    input  [31:0]   XATAI,  // Data input
    output [31:0]   XATAO,  // Data output
    output          XDACK,  // Data acknowledge

    output [3:0]    DEBUG   // Debug signals
);

    // Internal signals
    wire [31:0] ram_q_a, ram_q_b;
    wire        write_enable;


    // Instantiate altsyncram
    altsyncram #(
        .operation_mode("BIDIR_DUAL_PORT"),
        .width_a(32),
        .widthad_a(13),  // Address width for 4KB RAM
        .numwords_a(2048),
        .width_b(32),
        .widthad_b(13),
        .numwords_b(2048),
        .lpm_type("altsyncram"),
        .ram_block_type("AUTO"),
        .init_file(INIT_FILE),
        .outdata_reg_a("UNREGISTERED"),
        .outdata_reg_b("UNREGISTERED"),
        .indata_reg_b("CLOCK0"),
        .address_reg_b("CLOCK0"),
        .wrcontrol_wraddress_reg_b("CLOCK0"),
        .byte_size(8),
        .width_byteena_a(4),
        .width_byteena_b(4),
        .byteena_reg_b("CLOCK0")
    ) ram_inst (
        .clock0(CLK),
        .address_a(IADDR[12:2]),
        .q_a(ram_q_a),
        .address_b(XADDR[12:2]),
        .wren_b(write_enable),
        .byteena_b(XBE),
        .data_b(XATAI),
        .q_b(ram_q_b)
    );
    assign write_enable = XWR & XDREQ;

    // Assign instruction fetch outputs
    assign IDATA = ram_q_a;
    assign IDACK = IDREQ;  // Immediate ACK for simplicity

    // Assign data read/write outputs
    assign XATAO = ram_q_b;
    assign XDACK = DTACK==1 ||(XDREQ&&XWR);
    reg [3:0] DTACK  = 0;
    always@(posedge CLK) // stage #1.0
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : XDREQ && XRD ? 1 : 0;
    end

    // Debug outputs (for observability)
    assign DEBUG = { XDREQ,XRD,XWR,XDACK };

endmodule
