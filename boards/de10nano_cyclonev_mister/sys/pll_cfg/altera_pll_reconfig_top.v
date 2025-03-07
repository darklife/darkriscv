// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ps/1ps

module altera_pll_reconfig_top
#(
    parameter   reconf_width            = 64,
    parameter   device_family           = "Stratix V",
    parameter   RECONFIG_ADDR_WIDTH     = 6,
    parameter   RECONFIG_DATA_WIDTH     = 32,
    
	parameter   ROM_ADDR_WIDTH          = 9,
    parameter   ROM_DATA_WIDTH          = 32,
	parameter	ROM_NUM_WORDS           = 512,

    parameter   ENABLE_MIF              = 0,    
    parameter   MIF_FILE_NAME           = "",
	
	parameter 	ENABLE_BYTEENABLE		= 0,
	parameter	BYTEENABLE_WIDTH		= 4,
    parameter   WAIT_FOR_LOCK           = 1
) ( 

    //input
    input   wire    mgmt_clk,
    input   wire    mgmt_reset,


    //conduits
    output  wire [reconf_width-1:0] reconfig_to_pll,
    input  wire [reconf_width-1:0] reconfig_from_pll,

    // user data (avalon-MM slave interface)
    output  wire [RECONFIG_DATA_WIDTH-1:0] mgmt_readdata,
    output  wire        mgmt_waitrequest,
    input   wire [RECONFIG_ADDR_WIDTH-1:0]  mgmt_address,
    input   wire        mgmt_read,
    input   wire        mgmt_write,
    input   wire [RECONFIG_DATA_WIDTH-1:0] mgmt_writedata,
	
	//conditional input 
	input 	wire [BYTEENABLE_WIDTH-1:0] mgmt_byteenable
);

localparam  NM28_START_REG 		= 6'b000010;
localparam  NM20_START_REG 		= 9'b000000000;
localparam 	NM20_MIFSTART_ADDR	= 9'b000010000;

localparam MIF_STATE_DONE = 2'b00;
localparam MIF_STATE_START = 2'b01;
localparam MIF_STATE_BUSY = 2'b10;

wire mgmt_byteenable_write;
assign mgmt_byteenable_write = (ENABLE_BYTEENABLE == 1) ? 
										((mgmt_byteenable == {BYTEENABLE_WIDTH{1'b1}}) ? mgmt_write : 1'b0) : 
										mgmt_write;
										
generate
if (device_family == "Arria 10")
begin:nm20_reconfig
	if(ENABLE_MIF == 1)
	begin:mif_reconfig_20nm // Generate Reconfig with MIF
	
		// MIF-related regs/wires
        reg [RECONFIG_ADDR_WIDTH-1:0]   reconfig_mgmt_addr; 
        reg                             reconfig_mgmt_read;
        reg                             reconfig_mgmt_write;
        reg [RECONFIG_DATA_WIDTH-1:0]   reconfig_mgmt_writedata;
        wire                            reconfig_mgmt_waitrequest;
        wire [RECONFIG_DATA_WIDTH-1:0]   reconfig_mgmt_readdata;

        wire [RECONFIG_ADDR_WIDTH-1:0]   mif2reconfig_addr;
        wire							 mif_busy;
        wire                             mif2reconfig_read;
        wire                             mif2reconfig_write;
        wire [RECONFIG_DATA_WIDTH-1:0]   mif2reconfig_writedata;
        wire [ROM_ADDR_WIDTH-1:0]        mif_base_addr;
        reg mif_select;
		//wire 							mif_user_start; // start signal provided by user to start mif
        //reg user_start;

		reg [1:0] mif_curstate;
		reg [1:0] mif_nextstate;

        wire mif_start; //start signal to mif reader

        assign mgmt_waitrequest = reconfig_mgmt_waitrequest | mif_busy;// | user_start;
        // Don't output readdata if MIF streaming is taking place
        assign mgmt_readdata = (mif_select) ? 32'b0 : reconfig_mgmt_readdata;

		//user must lower this by the time mif streaming is done - suggest to lower after 1 cycle
		assign mif_start = mgmt_byteenable_write & (mgmt_address == NM20_MIFSTART_ADDR);
		
		//mif base addr is initially specified by the user
		assign mif_base_addr = mgmt_writedata[ROM_ADDR_WIDTH-1:0];
		
		//MIF statemachine
		always @(posedge mgmt_clk)
		begin
			if(mgmt_reset)
				mif_curstate <= MIF_STATE_DONE;
			else
				mif_curstate <= mif_nextstate;
		end
		
		always @(*)
		begin
			case (mif_curstate)
				MIF_STATE_DONE:
				begin
					if(mif_start)
						mif_nextstate <= MIF_STATE_START;
					else
						mif_nextstate <= MIF_STATE_DONE;
				end
				MIF_STATE_START:
				begin
					mif_nextstate <= MIF_STATE_BUSY;
				end				
				MIF_STATE_BUSY:
				begin
					if(mif_busy)
						mif_nextstate <= MIF_STATE_BUSY;
					else
						mif_nextstate <= MIF_STATE_DONE;
				end
			endcase
		end
		
		//Mif muxes
        always @(*)
        begin
            if (mgmt_reset)
            begin
                reconfig_mgmt_addr      <= 0;
                reconfig_mgmt_read      <= 0;
                reconfig_mgmt_write     <= 0;
                reconfig_mgmt_writedata <= 0;
                //user_start              <= 0;
            end
            else
            begin
                reconfig_mgmt_addr      <= (mif_select) ? mif2reconfig_addr : mgmt_address;
                reconfig_mgmt_read      <= (mif_select) ? mif2reconfig_read : mgmt_read;
                reconfig_mgmt_write     <= (mif_select) ? mif2reconfig_write : mgmt_byteenable_write;
                reconfig_mgmt_writedata <= (mif_select) ? mif2reconfig_writedata : mgmt_writedata;
                //user_start              <= (mgmt_address == NM20_START_REG && mgmt_write == 1'b1) ? 1'b1 : 1'b0;
            end
        end

        always @(*)
        begin
            if (mgmt_reset)
            begin
                mif_select <= 0;
            end
            else 
            begin
                mif_select <= (mif_start || mif_busy) ? 1'b1 : 1'b0;
            end
        end
	
        twentynm_pll_reconfig_mif_reader  
        #(
            .RECONFIG_ADDR_WIDTH(RECONFIG_ADDR_WIDTH),
            .RECONFIG_DATA_WIDTH(RECONFIG_DATA_WIDTH),
            .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
            .ROM_DATA_WIDTH(ROM_DATA_WIDTH),
            .ROM_NUM_WORDS(ROM_NUM_WORDS),
            .DEVICE_FAMILY(device_family),
            .ENABLE_MIF(ENABLE_MIF),
            .MIF_FILE_NAME(MIF_FILE_NAME)
        ) twentynm_pll_reconfig_mif_reader_inst0 (
            .mif_clk(mgmt_clk),
            .mif_rst(mgmt_reset),
            
            //Altera_PLL Reconfig interface
            //inputs
            .reconfig_waitrequest(reconfig_mgmt_waitrequest),
			//.reconfig_read_data(reconfig_mgmt_readdata),
            //outputs
            .reconfig_write_data(mif2reconfig_writedata),
            .reconfig_addr(mif2reconfig_addr),
            .reconfig_write(mif2reconfig_write),
            .reconfig_read(mif2reconfig_read),

            //MIF Ctrl Interface
            //inputs
            .mif_base_addr(mif_base_addr),
            .mif_start(mif_start),
            //outputs
            .mif_busy(mif_busy)
        );
		
        // ------ END MIF-RELATED MANAGEMENT ------	
		
		twentynm_iopll_reconfig_core 
        #(
            .WAIT_FOR_LOCK(WAIT_FOR_LOCK)
        ) twentynm_iopll_reconfig_core_inst	(
			// Inputs
			.mgmt_clk(mgmt_clk),
			.mgmt_rst_n(~mgmt_reset),
			.mgmt_read(reconfig_mgmt_read),
			.mgmt_write(reconfig_mgmt_write),
			.mgmt_address(reconfig_mgmt_addr),
			.mgmt_writedata(reconfig_mgmt_writedata),

			// Outputs
			.mgmt_readdata(reconfig_mgmt_readdata),
			.mgmt_waitrequest(reconfig_mgmt_waitrequest),
			
			// PLL Conduits
			.reconfig_to_pll(reconfig_to_pll),
			.reconfig_from_pll(reconfig_from_pll)
		);
		
	end // End generate reconfig with MIF
	else 
	begin:reconfig_core_20nm
		twentynm_iopll_reconfig_core 
        #(
            .WAIT_FOR_LOCK(WAIT_FOR_LOCK)
        ) twentynm_iopll_reconfig_core_inst	(
			// Inputs
			.mgmt_clk(mgmt_clk),
			.mgmt_rst_n(~mgmt_reset),
			.mgmt_read(mgmt_read),
			.mgmt_write(mgmt_byteenable_write),
			.mgmt_address(mgmt_address),
			.mgmt_writedata(mgmt_writedata),

			// Outputs
			.mgmt_readdata(mgmt_readdata),
			.mgmt_waitrequest(mgmt_waitrequest),
			
			// PLL Conduits
			.reconfig_to_pll(reconfig_to_pll),
			.reconfig_from_pll(reconfig_from_pll)
		);
	end
end // 20nm reconfig
else
begin:NM28_reconfig
    if (ENABLE_MIF == 1)
    begin:mif_reconfig // Generate Reconfig with MIF

        // MIF-related regs/wires
        reg [RECONFIG_ADDR_WIDTH-1:0]   reconfig_mgmt_addr;
        reg                             reconfig_mgmt_read;
        reg                             reconfig_mgmt_write;
        reg [RECONFIG_DATA_WIDTH-1:0]   reconfig_mgmt_writedata;
        wire                            reconfig_mgmt_waitrequest;
        wire [RECONFIG_DATA_WIDTH-1:0]   reconfig_mgmt_readdata;

        wire [RECONFIG_ADDR_WIDTH-1:0]   mif2reconfig_addr;
        wire										mif2reconfig_busy;
        wire                             mif2reconfig_read;
        wire                             mif2reconfig_write;
        wire [RECONFIG_DATA_WIDTH-1:0]   mif2reconfig_writedata;
        wire  [ROM_ADDR_WIDTH-1:0]        mif_base_addr;
        reg mif_select;
        reg user_start;

        wire reconfig2mif_start_out;

        assign mgmt_waitrequest = reconfig_mgmt_waitrequest | mif2reconfig_busy | user_start;
        // Don't output readdata if MIF streaming is taking place
        assign mgmt_readdata = (mif_select) ? 32'b0 : reconfig_mgmt_readdata;

        always @(posedge mgmt_clk)
        begin
            if (mgmt_reset)
            begin
                reconfig_mgmt_addr      <= 0;
                reconfig_mgmt_read      <= 0;
                reconfig_mgmt_write     <= 0;
                reconfig_mgmt_writedata <= 0;
                user_start              <= 0;
            end
            else
            begin
                reconfig_mgmt_addr      <= (mif_select) ? mif2reconfig_addr : mgmt_address;
                reconfig_mgmt_read      <= (mif_select) ? mif2reconfig_read : mgmt_read;
                reconfig_mgmt_write     <= (mif_select) ? mif2reconfig_write : mgmt_byteenable_write;
                reconfig_mgmt_writedata <= (mif_select) ? mif2reconfig_writedata : mgmt_writedata;
                user_start              <= (mgmt_address == NM28_START_REG && mgmt_byteenable_write == 1'b1) ? 1'b1 : 1'b0;
            end
        end

        always @(*)
        begin
            if (mgmt_reset)
            begin
                mif_select <= 0;
            end
            else 
            begin
                mif_select <= (reconfig2mif_start_out || mif2reconfig_busy) ? 1'b1 : 1'b0;
            end
        end

        altera_pll_reconfig_mif_reader 
        #(
            .RECONFIG_ADDR_WIDTH(RECONFIG_ADDR_WIDTH),
            .RECONFIG_DATA_WIDTH(RECONFIG_DATA_WIDTH),
            .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
            .ROM_DATA_WIDTH(ROM_DATA_WIDTH),
            .ROM_NUM_WORDS(ROM_NUM_WORDS),
            .DEVICE_FAMILY(device_family),
            .ENABLE_MIF(ENABLE_MIF),
            .MIF_FILE_NAME(MIF_FILE_NAME)
        ) altera_pll_reconfig_mif_reader_inst0 (
            .mif_clk(mgmt_clk),
            .mif_rst(mgmt_reset),
            
            //Altera_PLL Reconfig interface
            //inputs
            .reconfig_busy(reconfig_mgmt_waitrequest),
            .reconfig_read_data(reconfig_mgmt_readdata),
            //outputs
            .reconfig_write_data(mif2reconfig_writedata),
            .reconfig_addr(mif2reconfig_addr),
            .reconfig_write(mif2reconfig_write),
            .reconfig_read(mif2reconfig_read),

            //MIF Ctrl Interface
            //inputs
            .mif_base_addr(mif_base_addr),
            .mif_start(reconfig2mif_start_out),
            //outputs
            .mif_busy(mif2reconfig_busy)
        );

        // ------ END MIF-RELATED MANAGEMENT ------


        altera_pll_reconfig_core
        #(
            .reconf_width(reconf_width),
            .device_family(device_family),
            .RECONFIG_ADDR_WIDTH(RECONFIG_ADDR_WIDTH),
            .RECONFIG_DATA_WIDTH(RECONFIG_DATA_WIDTH),
            .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
            .ROM_DATA_WIDTH(ROM_DATA_WIDTH),
            .ROM_NUM_WORDS(ROM_NUM_WORDS)
        ) altera_pll_reconfig_core_inst0 (
            //inputs
            .mgmt_clk(mgmt_clk),
            .mgmt_reset(mgmt_reset),

            //PLL interface conduits
            .reconfig_to_pll(reconfig_to_pll),
            .reconfig_from_pll(reconfig_from_pll),

            //User data outputs
            .mgmt_readdata(reconfig_mgmt_readdata),
            .mgmt_waitrequest(reconfig_mgmt_waitrequest),
            
            //User data inputs
            .mgmt_address(reconfig_mgmt_addr),
            .mgmt_read(reconfig_mgmt_read),
            .mgmt_write(reconfig_mgmt_write),
            .mgmt_writedata(reconfig_mgmt_writedata),

            // other
            .mif_start_out(reconfig2mif_start_out),
            .mif_base_addr(mif_base_addr)
        );

    end // End generate reconfig with MIF
    else
    begin:reconfig_core // Generate Reconfig core only

        wire reconfig2mif_start_out;
        wire  [ROM_ADDR_WIDTH-1:0]        mif_base_addr;

        altera_pll_reconfig_core
        #(
            .reconf_width(reconf_width),
            .device_family(device_family),
            .RECONFIG_ADDR_WIDTH(RECONFIG_ADDR_WIDTH),
            .RECONFIG_DATA_WIDTH(RECONFIG_DATA_WIDTH),
            .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
            .ROM_DATA_WIDTH(ROM_DATA_WIDTH),
            .ROM_NUM_WORDS(ROM_NUM_WORDS)
        ) altera_pll_reconfig_core_inst0 (
            //inputs
            .mgmt_clk(mgmt_clk),
            .mgmt_reset(mgmt_reset),

            //PLL interface conduits
            .reconfig_to_pll(reconfig_to_pll),
            .reconfig_from_pll(reconfig_from_pll),

            //User data outputs
            .mgmt_readdata(mgmt_readdata),
            .mgmt_waitrequest(mgmt_waitrequest),
            
            //User data inputs
            .mgmt_address(mgmt_address),
            .mgmt_read(mgmt_read),
            .mgmt_write(mgmt_byteenable_write),
            .mgmt_writedata(mgmt_writedata),

            // other
            .mif_start_out(reconfig2mif_start_out),
            .mif_base_addr(mif_base_addr)
        );

        
    end // End generate reconfig core only
end // End 28nm Reconfig
endgenerate

endmodule

