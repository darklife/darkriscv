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

module altera_pll_reconfig_core
#(
    parameter 	reconf_width       	= 64,
    parameter 	device_family       	= "Stratix V",
    // MIF Streaming parameters
    parameter   RECONFIG_ADDR_WIDTH     = 6,
    parameter   RECONFIG_DATA_WIDTH     = 32,
    parameter   ROM_ADDR_WIDTH          = 9,
    parameter   ROM_DATA_WIDTH          = 32,
    parameter	ROM_NUM_WORDS           = 512
) ( 

    //input
    input   wire    mgmt_clk,
    input   wire    mgmt_reset,


    //conduits
    output  wire [reconf_width-1:0] reconfig_to_pll,
    input  wire [reconf_width-1:0] reconfig_from_pll,

    // user data (avalon-MM slave interface)
    output  wire [31:0] mgmt_readdata,
    output  wire        mgmt_waitrequest,
    input   wire [5:0]  mgmt_address,
    input   wire        mgmt_read,
    input   wire        mgmt_write,
    input   wire [31:0] mgmt_writedata,

    //other
    output  wire        mif_start_out,
    output  reg [ROM_ADDR_WIDTH-1:0]    mif_base_addr
);
    localparam mode_WR            = 1'b0;
    localparam mode_POLL          = 1'b1;
    localparam MODE_REG           = 6'b000000;
    localparam STATUS_REG         = 6'b000001;
    localparam START_REG          = 6'b000010;
    localparam N_REG              = 6'b000011;
    localparam M_REG              = 6'b000100;
    localparam C_COUNTERS_REG     = 6'b000101;
    localparam DPS_REG            = 6'b000110;
    localparam DSM_REG            = 6'b000111;
    localparam BWCTRL_REG         = 6'b001000;
    localparam CP_CURRENT_REG     = 6'b001001;
    localparam ANY_DPRIO          = 6'b100000;
    localparam CNT_BASE           = 5'b001010;
    localparam VCO_REG              = 6'b011100;
    localparam MIF_REG            = 6'b011111;
    
    //C Counters
    localparam number_of_counters = 5'd18;
    localparam  CNT_0 = 1'd0, CNT_1 = 5'd1, CNT_2 = 5'd2,
                CNT_3 = 5'd3, CNT_4 = 5'd4, CNT_5 = 5'd5,
                CNT_6 = 5'd6, CNT_7 = 5'd7, CNT_8 = 5'd8,
                CNT_9 = 5'd9, CNT_10 = 5'd10, CNT_11 = 5'd11,
                CNT_12 = 5'd12, CNT_13 = 5'd13, CNT_14 = 5'd14,
                CNT_15 = 5'd15, CNT_16 = 5'd16, CNT_17 = 5'd17;
    //C counter addresses
    localparam C_CNT_0_DIV_ADDR = 5'h00;
    localparam C_CNT_0_DIV_ADDR_DPRIO_1 = 5'h11;
    localparam C_CNT_0_3_BYPASS_EN_ADDR = 5'h15;
    localparam C_CNT_0_3_ODD_DIV_EN_ADDR = 5'h17;
    localparam C_CNT_4_17_BYPASS_EN_ADDR = 5'h14;
    localparam C_CNT_4_17_ODD_DIV_EN_ADDR = 5'h16;
    //N counter addresses
    localparam N_CNT_DIV_ADDR = 5'h13;
    localparam N_CNT_BYPASS_EN_ADDR = 5'h15;
    localparam N_CNT_ODD_DIV_EN_ADDR = 5'h17;
    //M counter addresses
    localparam M_CNT_DIV_ADDR = 5'h12;
    localparam M_CNT_BYPASS_EN_ADDR = 5'h15;
    localparam M_CNT_ODD_DIV_EN_ADDR = 5'h17;
    
    //DSM address
    localparam DSM_K_FRACTIONAL_DIVISION_ADDR_0 = 5'h18;
    localparam DSM_K_FRACTIONAL_DIVISION_ADDR_1 = 5'h19;
    localparam DSM_K_READY_ADDR = 5'h17;
    localparam DSM_K_DITHER_ADDR = 5'h17;
    localparam DSM_OUT_SEL_ADDR = 6'h30;
    
    //Other DSM params
    localparam DSM_K_READY_BIT_INDEX = 4'd11;
    //BWCTRL address
    //Bit 0-3 of addr
    localparam BWCTRL_ADDR = 6'h30;
    //CP_CURRENT address
    //Bit 0-2 of addr
    localparam CP_CURRENT_ADDR = 6'h31;
    
    // VCODIV address
    localparam VCO_ADDR = 5'h17;

    localparam DPRIO_IDLE = 3'd0, ONE = 3'd1, TWO = 3'd2, THREE = 3'd3, FOUR = 3'd4,
               FIVE = 3'd5, SIX = 3'd6, SEVEN = 3'd7, EIGHT = 4'd8, NINE = 4'd9, TEN = 4'd10,
               ELEVEN = 4'd11, TWELVE = 4'd12, THIRTEEN = 4'd13, FOURTEEN = 4'd14, DPRIO_DONE = 4'd15;
    localparam IDLE = 2'b00, WAIT_ON_LOCK = 2'b01, LOCKED = 2'b10;
    
    wire            clk;
    wire            reset;
    wire            gnd;

    wire [5: 0]     slave_address;
    wire            slave_read;
    wire            slave_write;
    wire [31: 0]    slave_writedata;

    reg  [31: 0]     slave_readdata_d;
    reg  [31: 0]     slave_readdata_q;
    wire            slave_waitrequest;
    reg             slave_mode;

    assign          clk             = mgmt_clk;

    assign          slave_address       = mgmt_address;
    assign          slave_read      = mgmt_read;    
    assign          slave_write     = mgmt_write;
    assign          slave_writedata     = mgmt_writedata;
    
    reg read_waitrequest;
    // Outputs
    assign          mgmt_readdata       = slave_readdata_q;
    assign          mgmt_waitrequest    = slave_waitrequest | read_waitrequest; //Read waitrequest asserted in polling mode

    //internal signals
    wire            locked_orig;
    wire            locked;
   
    wire            pll_start;
    wire            pll_start_valid;
    reg             status_read;
    wire            read_slave_mode_asserted;

    wire            pll_start_asserted;

    reg  [1:0]      current_state;
    reg  [1:0]      next_state;

    reg             status;//0=busy, 1=ready
    //user_mode_init user_mode_init_inst (clk, reset, dprio_mdio_dis, ser_shift_load);
    //declaring the init wires. These will have 0 on them for 64 clk cycles
    wire       [ 5:0]  init_dprio_address;
    wire               init_dprio_read;
    wire       [ 1:0]  init_dprio_byteen;
    wire               init_dprio_write;
    wire       [15:0]  init_dprio_writedata;

    wire               init_atpgmode;
    wire               init_mdio_dis;
    wire               init_scanen;
    wire               init_ser_shift_load;
    wire               dprio_init_done;

    //DPRIO output signals after initialization is done
    wire            dprio_clk;
    reg             avmm_dprio_write;
    reg             avmm_dprio_read;
    reg  [5:0]      avmm_dprio_address;
    reg  [15:0]     avmm_dprio_writedata;
    reg  [1:0]      avmm_dprio_byteen;
    wire            avmm_atpgmode;
    wire            avmm_mdio_dis;
    wire            avmm_scanen;

    //Final output wires that are muxed between the init and avmm wires.
    wire            dprio_init_reset;
    wire [5:0]      dprio_address /*synthesis keep*/;
    wire            dprio_read/*synthesis keep*/;
    wire [1:0]      dprio_byteen/*synthesis keep*/;
    wire            dprio_write/*synthesis keep*/;
    wire [15:0]     dprio_writedata/*synthesis keep*/;
    wire            dprio_mdio_dis/*synthesis keep*/;
    wire            dprio_ser_shift_load/*synthesis keep*/;
    wire            dprio_atpgmode/*synthesis keep*/;
    wire            dprio_scanen/*synthesis keep*/;


    //other PLL signals for dyn ph shift
    wire            phase_done/*synthesis keep*/;
    wire            phase_en/*synthesis keep*/;
    wire            up_dn/*synthesis keep*/;
    wire  [4:0]     cnt_sel;
    
    //DPRIO input signals
    wire  [15:0]     dprio_readdata;

    //internal logic signals
    //storage registers for user sent data
    reg             dprio_temp_read_1;
    reg             dprio_temp_read_2;
    reg             dprio_start;
    reg             mif_start_assert;
    reg             dps_start_assert;
    wire            usr_valid_changes;
    reg  [3:0]      dprio_cur_state;
    reg  [3:0]      dprio_next_state;
    reg  [15:0]     dprio_temp_m_n_c_readdata_1_d;
    reg  [15:0]     dprio_temp_m_n_c_readdata_2_d;
    reg  [15:0]     dprio_temp_m_n_c_readdata_1_q;
    reg  [15:0]     dprio_temp_m_n_c_readdata_2_q;
	reg 			dprio_write_done;
    //C counters signals
    reg  [7:0]      usr_c_cnt_lo;
    reg  [7:0]      usr_c_cnt_hi;
    reg             usr_c_cnt_bypass_en;
    reg             usr_c_cnt_odd_duty_div_en;
    reg  [7:0]      temp_c_cnt_lo [0:17]; 
    reg  [7:0]      temp_c_cnt_hi [0:17];
    reg             temp_c_cnt_bypass_en [0:17];
    reg      	    temp_c_cnt_odd_duty_div_en [0:17];
    reg             any_c_cnt_changed;
    reg             all_c_cnt_done_q;
    reg             all_c_cnt_done_d;
    reg  [17:0]     c_cnt_changed;
    reg  [17:0]     c_cnt_done_d;
    reg  [17:0]     c_cnt_done_q;
    //N counter signals
    reg  [7:0]      usr_n_cnt_lo; 
    reg  [7:0]      usr_n_cnt_hi;
    reg             usr_n_cnt_bypass_en;
    reg             usr_n_cnt_odd_duty_div_en;
    reg             n_cnt_changed;
    reg             n_cnt_done_d;
    reg             n_cnt_done_q;
    //M counter signals
    reg  [7:0]      usr_m_cnt_lo; 
    reg  [7:0]      usr_m_cnt_hi;
    reg             usr_m_cnt_bypass_en;
    reg             usr_m_cnt_odd_duty_div_en;
    reg             m_cnt_changed;
    reg             m_cnt_done_d;
    reg             m_cnt_done_q;
    //dyn phase regs
    reg  [15:0]     usr_num_shifts;
    reg  [4:0]      usr_cnt_sel /*synthesis preserve*/;
    reg             usr_up_dn;
    reg             dps_changed;
    wire            dps_changed_valid;
    wire            dps_done;

    //DSM Signals
    reg  [31:0]     usr_k_value;
    reg             dsm_k_changed;
    reg             dsm_k_done_d;
    reg             dsm_k_done_q;
    reg             dsm_k_ready_false_done_d;
    //BW signals 
    reg [3:0]       usr_bwctrl_value;
    reg             bwctrl_changed;
    reg             bwctrl_done_d;
    reg             bwctrl_done_q;
    //CP signals 
    reg [2:0]       usr_cp_current_value;
    reg             cp_current_changed;
    reg             cp_current_done_d;
    reg             cp_current_done_q;
    //VCO signals 
    reg             usr_vco_value;
    reg             vco_changed;
    reg             vco_done_d;
    reg             vco_done_q;
    //Manual DPRIO signals
    reg             manual_dprio_done_q;
    reg             manual_dprio_done_d;
    reg             manual_dprio_changed;
    reg  [5:0]      usr_dprio_address;
    reg  [15:0]     usr_dprio_writedata_0;
    reg             usr_r_w;
	 //keeping track of which operation happened last
	 reg  [5:0]		  operation_address;
    // Address wires for all C_counter DPRIO registers
    // These are outputs of LUTS, changing depending
    // on whether PLL_0 or PLL_1 being used


    //Fitter will tell if FPLL1 is being used 
    wire            fpll_1;

    // other
    reg             mif_reg_asserted;
    // MAIN FSM                             

    // Synchronize locked signal
   altera_std_synchronizer #(
        .depth(3)
    ) altera_std_synchronizer_inst (
        .clk(mgmt_clk),
        .reset_n(~mgmt_reset), 
        .din(locked_orig),
        .dout(locked)
    );
   
    always @(posedge clk)
    begin
        if (reset)
        begin
            dprio_cur_state <= DPRIO_IDLE;
            current_state <= IDLE;
        end
        else
        begin
            current_state <= next_state;
            dprio_cur_state <= dprio_next_state;
        end
    end

    always @(*)
     begin
        case(current_state)
          IDLE:
            begin
               if (pll_start & !slave_waitrequest & usr_valid_changes)
                 next_state = WAIT_ON_LOCK;
               else
                 next_state = IDLE;
            end
          WAIT_ON_LOCK:
            begin
               if (locked & dps_done & dprio_write_done)  // received locked high from PLL
                 begin
                    if (slave_mode==mode_WR) //if the mode is waitrequest, then
                                             // goto IDLE state directly
                      next_state = IDLE;
                    else
                      next_state = LOCKED; //otherwise go the locked state
                 end
               else
                  next_state = WAIT_ON_LOCK;
            end
              
          LOCKED:
            begin
               if (status_read) // stay in LOCKED until user reads status 
                 next_state = IDLE;
               else
                 next_state = LOCKED;
            end

          default: next_state = 2'bxx;
          
        endcase
     end


    // ask the pll to start reconfig
    assign pll_start = (pll_start_asserted & (current_state==IDLE))  ;
    assign pll_start_valid = (pll_start & (next_state==WAIT_ON_LOCK))  ;



    // WRITE OPERATIONS
    assign pll_start_asserted = slave_write & (slave_address == START_REG);
    assign mif_start_out = pll_start & mif_reg_asserted;

    //reading the mode register to determine what mode the slave will operate
    //in.
    always @(posedge clk)
    begin
        if (reset)
          slave_mode <= mode_WR;
        else if (slave_write & (slave_address == MODE_REG) & !slave_waitrequest)
          slave_mode <= slave_writedata[0];
    end

    //record which values user wants to change.

    //reading in the actual values that need to be reconfigged and sending
    //them to the PLL
    always @(posedge clk)
    begin
        if (reset)
        begin
            //reset all regs here
            //BW signals reset
            usr_bwctrl_value <= 0;
            bwctrl_changed <= 0;
            bwctrl_done_q <= 0;
            //CP signals reset
            usr_cp_current_value <= 0;
            cp_current_changed <= 0;
            cp_current_done_q <= 0;
            //VCO signals reset
            usr_vco_value <= 0;
            vco_changed <= 0;
            vco_done_q <= 0;
            //DSM signals reset
            usr_k_value <= 0;
            dsm_k_changed <= 0;
            dsm_k_done_q <= 0;
            //N counter signals reset
            usr_n_cnt_lo <= 0;
            usr_n_cnt_hi <= 0;
            usr_n_cnt_bypass_en <= 0;
            usr_n_cnt_odd_duty_div_en <= 0;
            n_cnt_changed <= 0;
            n_cnt_done_q <= 0;
            //M counter signals reset
            usr_m_cnt_lo <= 0;
            usr_m_cnt_hi <= 0;
            usr_m_cnt_bypass_en <= 0;
            usr_m_cnt_odd_duty_div_en <= 0;
            m_cnt_changed <= 0;
            m_cnt_done_q <= 0;
            //C counter signals reset
            usr_c_cnt_lo <= 0;
            usr_c_cnt_hi <= 0;
            usr_c_cnt_bypass_en <= 0;
            usr_c_cnt_odd_duty_div_en <= 0;
            any_c_cnt_changed <= 0;
            all_c_cnt_done_q <= 0;
            c_cnt_done_q <= 0;
            //generic signals
            dprio_start <= 0;
            mif_start_assert <= 0;
            dps_start_assert <= 0;
            dprio_temp_m_n_c_readdata_1_q <= 0;
            dprio_temp_m_n_c_readdata_2_q <= 0;
            c_cnt_done_q <= 0;
            //DPS signals
            usr_up_dn <= 0;
            usr_cnt_sel <= 0;
            usr_num_shifts <= 0;
            dps_changed <= 0;
            //manual DPRIO signals
            manual_dprio_changed <= 0;
            usr_dprio_address <= 0;
            usr_dprio_writedata_0 <= 0;
            usr_r_w <= 0;
	    operation_address <= 0;
            mif_reg_asserted <= 0;
            mif_base_addr <= 0;
        end
        else
        begin
            if (dprio_temp_read_1)
            begin
                dprio_temp_m_n_c_readdata_1_q <= dprio_temp_m_n_c_readdata_1_d; 
            end
            if (dprio_temp_read_2)
            begin
                dprio_temp_m_n_c_readdata_2_q <= dprio_temp_m_n_c_readdata_2_d; 
            end
            if ((dps_done)) dps_changed <= 0;
            if (dsm_k_done_d) dsm_k_done_q <= dsm_k_done_d;
            if (n_cnt_done_d) n_cnt_done_q <= n_cnt_done_d;
            if (m_cnt_done_d) m_cnt_done_q <= m_cnt_done_d;
            if (all_c_cnt_done_d) all_c_cnt_done_q <= all_c_cnt_done_d;
            if (c_cnt_done_d != 0) c_cnt_done_q <= c_cnt_done_q | c_cnt_done_d;
            if (bwctrl_done_d) bwctrl_done_q <= bwctrl_done_d;
            if (cp_current_done_d) cp_current_done_q <= cp_current_done_d;
            if (vco_done_d) vco_done_q <= vco_done_d;
            if (manual_dprio_done_d) manual_dprio_done_q <= manual_dprio_done_d;

            if (mif_start_out == 1'b1)
                mif_start_assert <= 0; // Signaled MIF block to start, so deassert on next cycle
            
            if (dps_done != 1'b1)
                dps_start_assert <= 0; // DPS has started, so dessert its start signal on next cycle

            if (dprio_next_state == ONE)
                dprio_start <= 0;
            if (dprio_write_done)
            begin
                bwctrl_done_q <= 0;
                cp_current_done_q <= 0;
                vco_done_q <= 0;
                dsm_k_done_q <= 0;
                dsm_k_done_q <= 0;
                n_cnt_done_q <= 0;
                m_cnt_done_q <= 0;
                all_c_cnt_done_q <= 0;
                c_cnt_done_q <= 0;
                dsm_k_changed <= 0;
                n_cnt_changed <= 0;
                m_cnt_changed <= 0;
                any_c_cnt_changed <= 0;
                bwctrl_changed <= 0;
                cp_current_changed <= 0;
                vco_changed <= 0;
                manual_dprio_changed <= 0;
                manual_dprio_done_q <= 0;
                if (dps_changed | dps_changed_valid | !dps_done )
                begin
                    usr_cnt_sel <= usr_cnt_sel;
                end
                else 
                begin
                    usr_cnt_sel <= 0;
                end
                mif_reg_asserted <= 0;
            end
            else 
            begin
                dsm_k_changed <= dsm_k_changed;
                n_cnt_changed <= n_cnt_changed;
                m_cnt_changed <= m_cnt_changed;
                any_c_cnt_changed <= any_c_cnt_changed;
                manual_dprio_changed <= manual_dprio_changed;
                mif_reg_asserted <= mif_reg_asserted;
                usr_cnt_sel <= usr_cnt_sel;
            end


            if(slave_write & !slave_waitrequest)
            begin
                case(slave_address)
                   //read in the values here from the user and act on them
                DSM_REG:
                begin
                    operation_address <= DSM_REG;
                    usr_k_value <= slave_writedata[31:0]; 
                    dsm_k_changed <= 1'b1;
                    dsm_k_done_q <= 0;
                    dprio_start <= 1'b1;
                end
                N_REG:
                begin
                    operation_address <= N_REG;
                    usr_n_cnt_lo <= slave_writedata[7:0]; 
                    usr_n_cnt_hi <= slave_writedata[15:8];
                    usr_n_cnt_bypass_en <= slave_writedata[16];
                    usr_n_cnt_odd_duty_div_en <= slave_writedata[17];
                    n_cnt_changed <= 1'b1;
                    n_cnt_done_q <= 0;
                    dprio_start <= 1'b1;
                end
                M_REG:
                begin
                    operation_address <= M_REG;
                    usr_m_cnt_lo <= slave_writedata[7:0]; 
                    usr_m_cnt_hi <= slave_writedata[15:8];
                    usr_m_cnt_bypass_en <= slave_writedata[16];
                    usr_m_cnt_odd_duty_div_en <= slave_writedata[17];
                    m_cnt_changed <= 1'b1;
                    m_cnt_done_q <= 0;
                    dprio_start <= 1'b1;
                end
                DPS_REG:
                begin
                    operation_address <= DPS_REG;
                    usr_num_shifts <= slave_writedata[15:0];
                    usr_cnt_sel <= slave_writedata[20:16];
                    usr_up_dn <= slave_writedata[21];
                    dps_changed <= 1;
                    dps_start_assert <= 1;
                end
                C_COUNTERS_REG:
                begin
						  operation_address <= C_COUNTERS_REG;
                    usr_c_cnt_lo <= slave_writedata[7:0]; 
                    usr_c_cnt_hi <= slave_writedata[15:8];
                    usr_c_cnt_bypass_en <= slave_writedata[16];
                    usr_c_cnt_odd_duty_div_en <= slave_writedata[17];
                    usr_cnt_sel <= slave_writedata[22:18];
                    any_c_cnt_changed <= 1'b1;
                    all_c_cnt_done_q <= 0;
                    dprio_start <= 1'b1;
                end
                BWCTRL_REG:
                begin
                    usr_bwctrl_value <= slave_writedata[3:0]; 
                    bwctrl_changed <= 1'b1;
                    bwctrl_done_q <= 0;
                    dprio_start <= 1'b1;
		    	  operation_address <= BWCTRL_REG;
                end
                CP_CURRENT_REG:
                begin
                    usr_cp_current_value <= slave_writedata[2:0]; 
                    cp_current_changed <= 1'b1;
                    cp_current_done_q <= 0;
                    dprio_start <= 1'b1;
		    operation_address <= CP_CURRENT_REG;
                end
                VCO_REG:
                begin
                    usr_vco_value <= slave_writedata[0]; 
                    vco_changed <= 1'b1;
                    vco_done_q <= 0;
                    dprio_start <= 1'b1;
		    operation_address <= VCO_REG;
                end
                ANY_DPRIO:
                begin
						  operation_address <= ANY_DPRIO;
                    manual_dprio_changed <= 1'b1;
                    usr_dprio_address <= slave_writedata[5:0];
                    usr_dprio_writedata_0 <= slave_writedata[21:6];
                    usr_r_w <= slave_writedata[22];
                    manual_dprio_done_q <= 0;
                    dprio_start <= 1'b1;
                end
                MIF_REG:
                begin
                    mif_reg_asserted <= 1'b1;
                    mif_base_addr <= slave_writedata[ROM_ADDR_WIDTH-1:0];
                    mif_start_assert <= 1'b1;
                end                
                endcase
             end
        end 
    end
    //C Counter assigning values to the 2-d array of values for each C counter
   
    reg [4:0] j;
    always @(posedge clk)
    begin

        if (reset)
        begin
            c_cnt_changed[17:0] <= 0;
            for (j = 0; j < number_of_counters; j = j + 1'b1)
            begin : c_cnt_reset
                temp_c_cnt_bypass_en[j] <= 0;
                temp_c_cnt_odd_duty_div_en[j] <= 0;
                temp_c_cnt_lo[j][7:0] <= 0;
                temp_c_cnt_hi[j][7:0] <= 0;
            end
        end
        else 
        begin
            if (dprio_write_done)
            begin
                c_cnt_changed <= 0;
            end
            if (any_c_cnt_changed && (operation_address == C_COUNTERS_REG))
            begin
                case (cnt_sel)
                    CNT_0:
                    begin
                        temp_c_cnt_lo [0] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [0] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [0] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [0] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [0] <= 1'b1;
                    end
                    CNT_1:
                    begin
                        temp_c_cnt_lo [1] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [1] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [1] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [1] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [1] <= 1'b1;
                    end
                    CNT_2:
                    begin
                        temp_c_cnt_lo [2] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [2] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [2] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [2] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [2] <= 1'b1;
                    end
                    CNT_3:
                    begin
                        temp_c_cnt_lo [3] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [3] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [3] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [3] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [3] <= 1'b1;
                    end
                    CNT_4:
                    begin
                        temp_c_cnt_lo [4] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [4] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [4] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [4] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [4] <= 1'b1;
                    end
                    CNT_5:
                    begin
                        temp_c_cnt_lo [5] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [5] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [5] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [5] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [5] <= 1'b1;
                    end
                    CNT_6:
                    begin
                        temp_c_cnt_lo [6] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [6] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [6] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [6] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [6] <= 1'b1;
                    end
                    CNT_7:
                    begin
                        temp_c_cnt_lo [7] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [7] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [7] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [7] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [7] <= 1'b1;
                    end
                    CNT_8:
                    begin
                        temp_c_cnt_lo [8] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [8] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [8] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [8] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [8] <= 1'b1;
                    end
                    CNT_9:
                    begin
                        temp_c_cnt_lo [9] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [9] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [9] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [9] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [9] <= 1'b1;
                    end
                    CNT_10:
                    begin
                        temp_c_cnt_lo [10] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [10] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [10] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [10] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [10] <= 1'b1;
                    end
                    CNT_11:
                    begin
                        temp_c_cnt_lo [11] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [11] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [11] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [11] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [11] <= 1'b1;
                    end
                    CNT_12:
                    begin
                        temp_c_cnt_lo [12] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [12] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [12] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [12] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [12] <= 1'b1;
                    end
                    CNT_13:
                    begin
                        temp_c_cnt_lo [13] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [13] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [13] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [13] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [13] <= 1'b1;
                    end
                    CNT_14:
                    begin
                        temp_c_cnt_lo [14] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [14] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [14] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [14] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [14] <= 1'b1;
                    end
                    CNT_15:
                    begin
                        temp_c_cnt_lo [15] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [15] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [15] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [15] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [15] <= 1'b1;
                    end
                    CNT_16:
                    begin
                        temp_c_cnt_lo [16] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [16] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [16] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [16] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [16] <= 1'b1;
                    end
                    CNT_17:
                    begin
                        temp_c_cnt_lo [17] <= usr_c_cnt_lo;
                        temp_c_cnt_hi [17] <= usr_c_cnt_hi;
                        temp_c_cnt_bypass_en [17] <= usr_c_cnt_bypass_en;
                        temp_c_cnt_odd_duty_div_en [17] <= usr_c_cnt_odd_duty_div_en;
                        c_cnt_changed [17] <= 1'b1;
                    end
                endcase

            end
        end
    end


    //logic to handle which writes the user indicated and wants to start.
    assign usr_valid_changes =dsm_k_changed| any_c_cnt_changed |n_cnt_changed | m_cnt_changed | dps_changed_valid |manual_dprio_changed |cp_current_changed|bwctrl_changed|vco_changed;

     
    //start the reconfig operations by writing to the DPRIO
    reg break_loop;
    reg [4:0] i;
    always @(*)
    begin 
        dprio_temp_read_1 = 0;
        dprio_temp_read_2 = 0;
        dprio_temp_m_n_c_readdata_1_d = 0;
        dprio_temp_m_n_c_readdata_2_d = 0;
        break_loop = 0;
        dprio_next_state = DPRIO_IDLE;
        avmm_dprio_write = 0;
        avmm_dprio_read = 0;
        avmm_dprio_address = 0;
        avmm_dprio_writedata = 0;
        avmm_dprio_byteen = 0;
        dprio_write_done = 1;
        manual_dprio_done_d = 0;
        n_cnt_done_d = 0;
        dsm_k_done_d = 0;
        dsm_k_ready_false_done_d = 0;
        m_cnt_done_d = 0;
        c_cnt_done_d[17:0] = 0;
        all_c_cnt_done_d = 0;
        bwctrl_done_d = 0;
        cp_current_done_d = 0;
        vco_done_d = 0;
        i = 0;
       
        // Deassert dprio_write_done so it doesn't reset mif_reg_asserted (toggled writes) 
        if (dprio_start | mif_start_assert)
            dprio_write_done = 0;

        if (current_state == WAIT_ON_LOCK)
        begin
            case (dprio_cur_state)
                ONE:
                begin
                    if (n_cnt_changed & !n_cnt_done_q) 
                    begin
			dprio_write_done = 0;
                    	avmm_dprio_write = 1'b1;
                    	avmm_dprio_byteen = 2'b11;
                    	dprio_next_state = TWO;
                        avmm_dprio_address = N_CNT_DIV_ADDR;
                        avmm_dprio_writedata[7:0] = usr_n_cnt_lo;
                        avmm_dprio_writedata[15:8] = usr_n_cnt_hi;
                    end
                    else if (m_cnt_changed & !m_cnt_done_q) 
                    begin
		    	dprio_write_done = 0;
                    	avmm_dprio_write = 1'b1;
                    	avmm_dprio_byteen = 2'b11;
                    	dprio_next_state = TWO;
                        avmm_dprio_address = M_CNT_DIV_ADDR;
                        avmm_dprio_writedata[7:0] = usr_m_cnt_lo;
                        avmm_dprio_writedata[15:8] = usr_m_cnt_hi;
                    end
                    else if (any_c_cnt_changed & !all_c_cnt_done_q)
                    begin

                        for (i = 0; (i < number_of_counters) & !break_loop; i = i + 1'b1)
                        begin : c_cnt_write_hilo
                            if (c_cnt_changed[i] & !c_cnt_done_q[i])
                            begin
				dprio_write_done = 0;
	                    	avmm_dprio_write = 1'b1;
        	            	avmm_dprio_byteen = 2'b11;
                	    	dprio_next_state = TWO;
                                if (fpll_1) avmm_dprio_address = C_CNT_0_DIV_ADDR + C_CNT_0_DIV_ADDR_DPRIO_1 - i;
                                else avmm_dprio_address = C_CNT_0_DIV_ADDR + i;
                                avmm_dprio_writedata[7:0] = temp_c_cnt_lo[i];
                                avmm_dprio_writedata[15:8] = temp_c_cnt_hi[i];
                                //To break from the loop, since only one counter
                                //is addressed at a time
                                break_loop = 1'b1;
                            end
                        end
                    end
                    else if (dsm_k_changed & !dsm_k_done_q) 
                    begin
		    	dprio_write_done = 0;
                        avmm_dprio_write = 0;
                        dprio_next_state = TWO;
                    end
                    else if (bwctrl_changed & !bwctrl_done_q) 
                    begin
		    	dprio_write_done = 0;
                        avmm_dprio_write = 0;
                        dprio_next_state = TWO;
                    end
                    else if (cp_current_changed & !cp_current_done_q) 
                    begin
		    	dprio_write_done = 0;		    
                        avmm_dprio_write = 0;
                        dprio_next_state = TWO;
                    end
                    else if (vco_changed & !vco_done_q) 
                    begin
		    	dprio_write_done = 0;		    
                        avmm_dprio_write = 0;
                        dprio_next_state = TWO;
                    end
                    else if (manual_dprio_changed & !manual_dprio_done_q)
                    begin
		    	dprio_write_done = 0;
                    	avmm_dprio_byteen = 2'b11;
                    	dprio_next_state = TWO;		    
                        avmm_dprio_write = usr_r_w;
                        avmm_dprio_address = usr_dprio_address;
                        avmm_dprio_writedata[15:0] = usr_dprio_writedata_0;
                    end
                    else dprio_next_state = DPRIO_IDLE;
                end
            
                TWO:
                begin
                    //handle reading the two setting bits on n_cnt, then
                    //writing them back while preserving other bits.
                    //Issue two consecutive reads then wait; readLatency=3
                    dprio_write_done = 0;
                    dprio_next_state = THREE;
                    avmm_dprio_byteen = 2'b11;
                    avmm_dprio_read = 1'b1;
                    if (n_cnt_changed & !n_cnt_done_q)
                    begin
                        avmm_dprio_address = N_CNT_BYPASS_EN_ADDR;
                    end
                    else if (m_cnt_changed & !m_cnt_done_q)
                    begin
                        avmm_dprio_address = M_CNT_BYPASS_EN_ADDR;
                    end
                   
                    else if (any_c_cnt_changed & !all_c_cnt_done_q)
                    begin
                        for (i = 0; (i < number_of_counters) & !break_loop; i = i + 1'b1)
                        begin : c_cnt_read_bypass
                            if (fpll_1)
                            begin
                                if (i > 13)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_BYPASS_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_BYPASS_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                            else
                            begin
                                if (i < 4)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_BYPASS_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_BYPASS_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                        end
                    end
                    //reading the K ready 16 bit word. Need to write 0 to it
                    //afterwards to indicate that K has not been done writing
                    else if (dsm_k_changed & !dsm_k_done_q) 
                    begin
                        avmm_dprio_address = DSM_K_READY_ADDR;
                        dprio_next_state = FOUR;
                    end
                    else if (bwctrl_changed & !bwctrl_done_q) 
                    begin
                        avmm_dprio_address = BWCTRL_ADDR;
                        dprio_next_state = FOUR;
                    end
                    else if (cp_current_changed & !cp_current_done_q) 
                    begin
                        avmm_dprio_address = CP_CURRENT_ADDR;
                        dprio_next_state = FOUR;
                    end
                    else if (vco_changed & !vco_done_q) 
                    begin
                        avmm_dprio_address = VCO_ADDR;
                        dprio_next_state = FOUR;
                    end
                    else if (manual_dprio_changed & !manual_dprio_done_q)
                    begin
                        avmm_dprio_read = ~usr_r_w;
                        avmm_dprio_address = usr_dprio_address;
                        dprio_next_state = DPRIO_DONE;
                    end
                    else dprio_next_state = DPRIO_IDLE;
                end       
                THREE:
                begin
                    dprio_write_done = 0;
                    avmm_dprio_byteen = 2'b11;
                    avmm_dprio_read = 1'b1;
                    dprio_next_state = FOUR;
                    if (n_cnt_changed & !n_cnt_done_q)
                    begin
                        avmm_dprio_address = N_CNT_ODD_DIV_EN_ADDR;
                    end
                    else if (m_cnt_changed & !m_cnt_done_q)
                    begin
                        avmm_dprio_address = M_CNT_ODD_DIV_EN_ADDR;
                    end
                    else if (any_c_cnt_changed & !all_c_cnt_done_q)
                    begin
                        for (i = 0; (i < number_of_counters) & !break_loop; i = i + 1'b1)
                        begin : c_cnt_read_odd_div
                            if (fpll_1)
                            begin
                                if (i > 13)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_ODD_DIV_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_ODD_DIV_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                            else
                            begin
                                if (i < 4)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_ODD_DIV_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_ODD_DIV_EN_ADDR;
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                        end
                    end   
                    else dprio_next_state = DPRIO_IDLE;
                end
                FOUR:
                begin
                    dprio_temp_read_1 = 1'b1;
                    dprio_write_done = 0;
                    if (vco_changed|cp_current_changed|bwctrl_changed|dsm_k_changed|n_cnt_changed|m_cnt_changed|any_c_cnt_changed)
                    begin
                        dprio_temp_m_n_c_readdata_1_d = dprio_readdata;
                        dprio_next_state = FIVE;
                    end
                    else dprio_next_state = DPRIO_IDLE;
                end
                FIVE:
                begin
                    dprio_write_done = 0;
                    dprio_temp_read_2 = 1'b1;
                    if (vco_changed|cp_current_changed|bwctrl_changed|dsm_k_changed|n_cnt_changed|m_cnt_changed|any_c_cnt_changed)
                    begin
                        //this is where DSM ready value comes.
                        //Need to store in a register to be used later
                        dprio_temp_m_n_c_readdata_2_d = dprio_readdata;
                        dprio_next_state = SIX;
                    end
                    else dprio_next_state = DPRIO_IDLE;
                end
                SIX:
                begin
                    dprio_write_done = 0;
                    avmm_dprio_write = 1'b1;
                    avmm_dprio_byteen = 2'b11;
                    dprio_next_state = SEVEN;
                    avmm_dprio_writedata = dprio_temp_m_n_c_readdata_1_q;
                    if (n_cnt_changed & !n_cnt_done_q)
                    begin
                        avmm_dprio_address = N_CNT_BYPASS_EN_ADDR;
                        avmm_dprio_writedata[5] = usr_n_cnt_bypass_en;
                    end
                    else if (m_cnt_changed & !m_cnt_done_q)
                    begin
                        avmm_dprio_address = M_CNT_BYPASS_EN_ADDR;
                        avmm_dprio_writedata[4] = usr_m_cnt_bypass_en;
                    end
                    else if (any_c_cnt_changed & !all_c_cnt_done_q)
                    begin
                        for (i = 0; (i < number_of_counters) & !break_loop; i = i + 1'b1)
                        begin : c_cnt_write_bypass
                            if (fpll_1)
                            begin
                                if (i > 13)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_BYPASS_EN_ADDR;
                                        avmm_dprio_writedata[i-14] = temp_c_cnt_bypass_en[i];
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_BYPASS_EN_ADDR;
                                        avmm_dprio_writedata[i] = temp_c_cnt_bypass_en[i];
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                            else
                            begin
                                if (i < 4)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_BYPASS_EN_ADDR;
                                        avmm_dprio_writedata[3-i] = temp_c_cnt_bypass_en[i];
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_BYPASS_EN_ADDR;
                                        avmm_dprio_writedata[17-i] = temp_c_cnt_bypass_en[i];
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                        end
                    end    
                    else if (dsm_k_changed & !dsm_k_done_q)
                    begin
                        avmm_dprio_write = 0;
                    end
                    else if (bwctrl_changed & !bwctrl_done_q) 
                    begin
                        avmm_dprio_write = 0;
                    end
                    else if (cp_current_changed & !cp_current_done_q) 
                    begin
                        avmm_dprio_write = 0;
                    end
                    else if (vco_changed & !vco_done_q) 
                    begin
                        avmm_dprio_write = 0;
                    end
                    else dprio_next_state = DPRIO_IDLE;
                end
                SEVEN:
                begin
                    dprio_write_done = 0;
                    dprio_next_state = EIGHT;
                    avmm_dprio_write = 1'b1;
                    avmm_dprio_byteen = 2'b11;
                    avmm_dprio_writedata = dprio_temp_m_n_c_readdata_2_q;
                    if (n_cnt_changed & !n_cnt_done_q)
                    begin
                        avmm_dprio_address = N_CNT_ODD_DIV_EN_ADDR;
                        avmm_dprio_writedata[5] = usr_n_cnt_odd_duty_div_en;
                        n_cnt_done_d = 1'b1;
                    end
                    else if (m_cnt_changed & !m_cnt_done_q)
                    begin
                        avmm_dprio_address = M_CNT_ODD_DIV_EN_ADDR;
                        avmm_dprio_writedata[4] = usr_m_cnt_odd_duty_div_en;
                        m_cnt_done_d = 1'b1;
                    end
                         
                    else if (any_c_cnt_changed & !all_c_cnt_done_q)
                    begin
                        for (i = 0; (i < number_of_counters) & !break_loop; i = i + 1'b1)
                        begin : c_cnt_write_odd_div
                            if (fpll_1)
                            begin
                                if (i > 13)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_ODD_DIV_EN_ADDR;
                                        avmm_dprio_writedata[i-14] = temp_c_cnt_odd_duty_div_en[i];
                                        c_cnt_done_d[i] = 1'b1;
                                        //have to OR the signals to prevent
                                        //overwriting of previous dones
                                        c_cnt_done_d = c_cnt_done_d | c_cnt_done_q;
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_ODD_DIV_EN_ADDR;
                                        avmm_dprio_writedata[i] = temp_c_cnt_odd_duty_div_en[i];
                                        c_cnt_done_d[i] = 1'b1;
                                        c_cnt_done_d = c_cnt_done_d | c_cnt_done_q;
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                            else
                            begin
                                if (i < 4)
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_0_3_ODD_DIV_EN_ADDR;
                                        avmm_dprio_writedata[3-i] = temp_c_cnt_odd_duty_div_en[i];
                                        c_cnt_done_d[i] = 1'b1;
                                        //have to OR the signals to prevent
                                        //overwriting of previous dones
                                        c_cnt_done_d = c_cnt_done_d | c_cnt_done_q;
                                        break_loop = 1'b1;
                                    end
                                end
                                else
                                begin
                                    if (c_cnt_changed[i] & !c_cnt_done_q[i])
                                    begin
                                        avmm_dprio_address = C_CNT_4_17_ODD_DIV_EN_ADDR;
                                        avmm_dprio_writedata[17-i] = temp_c_cnt_odd_duty_div_en[i];
                                        c_cnt_done_d[i] = 1'b1;
                                        c_cnt_done_d = c_cnt_done_d | c_cnt_done_q;
                                        break_loop = 1'b1;
                                    end
                                end
                            end
                        end
                    end
                    else if (dsm_k_changed & !dsm_k_done_q)
                    begin
                        avmm_dprio_address = DSM_K_READY_ADDR;
                        avmm_dprio_writedata[DSM_K_READY_BIT_INDEX] = 1'b0;
                        dsm_k_ready_false_done_d = 1'b1;
                    end
                    else if (bwctrl_changed & !bwctrl_done_q) 
                    begin
                        avmm_dprio_address = BWCTRL_ADDR;
                        avmm_dprio_writedata[3:0] = usr_bwctrl_value;
                        bwctrl_done_d = 1'b1;
                    end
                    else if (cp_current_changed & !cp_current_done_q) 
                    begin
                        avmm_dprio_address = CP_CURRENT_ADDR;
                        avmm_dprio_writedata[2:0] = usr_cp_current_value;
                        cp_current_done_d = 1'b1;
                    end
                    else if (vco_changed & !vco_done_q) 
                    begin
                        avmm_dprio_address = VCO_ADDR;
                        avmm_dprio_writedata[8] = usr_vco_value;
                        vco_done_d = 1'b1;
                    end

                   
                    //if all C_cnt that were changed are done, then assert all_c_cnt_done
                    if (c_cnt_done_d == c_cnt_changed)
                        all_c_cnt_done_d = 1'b1;
                    if (n_cnt_changed & n_cnt_done_d)
                        dprio_next_state = DPRIO_DONE;
                    if (any_c_cnt_changed & !all_c_cnt_done_d & !all_c_cnt_done_q)
                        dprio_next_state = ONE;
                    else if (m_cnt_changed & !m_cnt_done_d & !m_cnt_done_q)
                        dprio_next_state = ONE;
                    else if (dsm_k_changed & !dsm_k_ready_false_done_d)
                        dprio_next_state = TWO;
                    else if (dsm_k_changed & !dsm_k_done_q)
                        dprio_next_state = EIGHT;
                    else if (bwctrl_changed & !bwctrl_done_d)
                        dprio_next_state = TWO;
                    else if (cp_current_changed & !cp_current_done_d)
                        dprio_next_state = TWO;
                    else if (vco_changed & !vco_done_d)
                        dprio_next_state = TWO;
                    else 
                    begin
                        dprio_next_state = DPRIO_DONE;
                        dprio_write_done = 1'b1;
                    end
                end
                //finish the rest of the DSM reads/writes
                //writing k value, writing k_ready to 1.
                EIGHT: 
                begin
                    dprio_write_done = 0;
                    dprio_next_state = NINE;
                    avmm_dprio_write = 1'b1;
                    avmm_dprio_byteen = 2'b11;
                    if (dsm_k_changed & !dsm_k_done_q)
                    begin
                        avmm_dprio_address = DSM_K_FRACTIONAL_DIVISION_ADDR_0;
                        avmm_dprio_writedata[15:0] = usr_k_value[15:0];
                    end
                end
                NINE: 
                begin
                    dprio_write_done = 0;
                    dprio_next_state = TEN;
                    avmm_dprio_write = 1'b1;
                    avmm_dprio_byteen = 2'b11;
                    if (dsm_k_changed & !dsm_k_done_q)
                    begin
                        avmm_dprio_address = DSM_K_FRACTIONAL_DIVISION_ADDR_1;
                        avmm_dprio_writedata[15:0] = usr_k_value[31:16];
                    end
                end
                TEN:
                begin
                    dprio_write_done = 0;
                    dprio_next_state = ONE;
                    avmm_dprio_write = 1'b1;
                    avmm_dprio_byteen = 2'b11;
                    if (dsm_k_changed & !dsm_k_done_q)
                    begin
                        avmm_dprio_address = DSM_K_READY_ADDR;
                        //already have the readdata for DSM_K_READY_ADDR since we read it
                        //earlier. Just reuse here 
                        avmm_dprio_writedata = dprio_temp_m_n_c_readdata_2_q;
                        avmm_dprio_writedata[DSM_K_READY_BIT_INDEX] = 1'b1;
                        dsm_k_done_d = 1'b1;
                    end
                end
                DPRIO_DONE:
                begin
                    dprio_write_done = 1'b1;
                    if (dprio_start) dprio_next_state = DPRIO_IDLE;
                    else dprio_next_state = DPRIO_DONE;
                end
                DPRIO_IDLE:
                begin
                    if (dprio_start) dprio_next_state = ONE;
                    else dprio_next_state = DPRIO_IDLE;
                end 
                default:    dprio_next_state = 4'bxxxx;
            endcase
        end

    end


    //assert the waitreq signal according to the state of the slave
    assign slave_waitrequest = (slave_mode==mode_WR) ? ((locked === 1'b1) ? (((current_state==WAIT_ON_LOCK) & !dprio_write_done) | !dps_done |reset|!dprio_init_done) : 1'b1) : 1'b0;
        
    // Read operations
    always @(*)
    begin
    status = 0;
    if (slave_mode == mode_POLL)
        //asserting status to 1 if the slave is done.
       status = (current_state == LOCKED);
    end
    //************************************************************//
    //************************************************************//
    //******************** READ STATE MACHINE ********************//
    //************************************************************//
    //************************************************************//
    reg  [1:0]      current_read_state;
    reg  [1:0]      next_read_state;
    reg  [5:0]      slave_address_int_d;
    reg  [5:0]      slave_address_int_q;
    reg             dprio_read_1;
    reg  [5:0]      dprio_address_1;
    reg  [1:0]      dprio_byteen_1;
    reg  [4:0]      usr_cnt_sel_1;
    localparam READ = 2'b00, READ_WAIT = 2'b01, READ_IDLE = 2'b10, READ_POST_WAIT = 2'b11; 
    
    always @(*)
    begin
      if(next_read_state == READ_IDLE)
        begin
          read_waitrequest <= 1'b0;
        end
      else
        begin
          read_waitrequest <= 1'b1;
        end
    end
    
    always @(posedge clk)
    begin
        if (reset)
        begin
            current_read_state <= READ_IDLE;
            slave_address_int_q <= 0;
            slave_readdata_q <= 0;
        end
        else
        begin
            current_read_state <= next_read_state;
            slave_address_int_q <= slave_address_int_d;
            slave_readdata_q <= slave_readdata_d;
        end
    end
    always @(*)
    begin
        dprio_read_1 = 0;
        dprio_address_1 = 0;
        dprio_byteen_1 = 0;
        slave_address_int_d = 0;
        slave_readdata_d = 0;
        status_read = 0;
        usr_cnt_sel_1 = 0;
        case(current_read_state)
        READ_IDLE:
        begin
            slave_address_int_d = 0;
            next_read_state = READ_IDLE;
            if ((current_state != WAIT_ON_LOCK) && slave_read)
            begin
                slave_address_int_d = slave_address;
                if ((slave_address >= CNT_BASE) && (slave_address < CNT_BASE+18))
                begin
                    next_read_state = READ_WAIT;
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = 1'b1;
                    usr_cnt_sel_1 = (slave_address[4:0] - CNT_BASE);
                    if (fpll_1) dprio_address_1 = C_CNT_0_DIV_ADDR + C_CNT_0_DIV_ADDR_DPRIO_1 - cnt_sel;
                    else dprio_address_1 = C_CNT_0_DIV_ADDR + cnt_sel;
                end
                else
                begin
                case (slave_address)
                MODE_REG:
                begin
                    next_read_state = READ_WAIT;
                    slave_readdata_d = slave_mode;
                end
                STATUS_REG:
                begin
                    next_read_state = READ_WAIT;
                    status_read = 1'b1;
                    slave_readdata_d = status;
                end
                N_REG:
                begin
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = 1'b1;
                    dprio_address_1 = N_CNT_DIV_ADDR;
                    next_read_state = READ_WAIT;
                end
                M_REG:
                begin
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = 1'b1;
                    dprio_address_1 = M_CNT_DIV_ADDR;
                    next_read_state = READ_WAIT;
                end
                BWCTRL_REG:
                begin
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = 1'b1;
                    dprio_address_1 = BWCTRL_ADDR;
                    next_read_state = READ_WAIT;
                end
                CP_CURRENT_REG:
                begin
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = 1'b1;
                    dprio_address_1 = CP_CURRENT_ADDR;
                    next_read_state = READ_WAIT;
                end
                VCO_REG:
                begin
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = 1'b1;
                    dprio_address_1 = VCO_ADDR;
                    next_read_state = READ_WAIT;
                end
                ANY_DPRIO:
                begin
                    dprio_byteen_1 = 2'b11;
                    dprio_read_1 = ~slave_writedata[22];
                    dprio_address_1 = slave_writedata[5:0];
                    next_read_state = READ_WAIT;
                end
                default : next_read_state = READ_IDLE;
                endcase
            end
            end
            else
                next_read_state = READ_IDLE;
        end
        READ_WAIT:
        begin
            next_read_state = READ;
            slave_address_int_d = slave_address_int_q;
            case (slave_address_int_q)
            MODE_REG:
            begin
                slave_readdata_d = slave_readdata_q;
            end
            STATUS_REG:
            begin
                slave_readdata_d = slave_readdata_q;
            end
    	    endcase
        end
        READ:
        begin
            next_read_state = READ_POST_WAIT;
            slave_address_int_d = slave_address_int_q;
            slave_readdata_d = dprio_readdata;
            case (slave_address_int_q)
            MODE_REG:
            begin
                slave_readdata_d = slave_readdata_q;
            end
            STATUS_REG:
            begin
                slave_readdata_d = slave_readdata_q;
            end
            BWCTRL_REG:
            begin
                slave_readdata_d = dprio_readdata[3:0];
            end
            CP_CURRENT_REG:
            begin
                slave_readdata_d = dprio_readdata[2:0];
            end
            VCO_REG:
            begin
                slave_readdata_d = dprio_readdata[8];
            end
            ANY_DPRIO:
            begin
                slave_readdata_d = dprio_readdata;
            end
    	    endcase
        end
        READ_POST_WAIT:
        begin
            next_read_state = READ_IDLE;
        end
        default: next_read_state = 2'bxx;
        endcase
     end


    dyn_phase_shift dyn_phase_shift_inst (
        .clk(clk), 
        .reset(reset),
        .phase_done(phase_done),
        .pll_start_valid(pll_start_valid),
        .dps_changed(dps_changed),
        .dps_changed_valid(dps_changed_valid),
        .dprio_write_done(dprio_write_done),
        .usr_num_shifts(usr_num_shifts),
        .usr_cnt_sel(usr_cnt_sel|usr_cnt_sel_1),
        .usr_up_dn(usr_up_dn),
        .locked(locked),
        .dps_done(dps_done),
        .phase_en(phase_en),
        .up_dn(up_dn),
        .cnt_sel(cnt_sel));
    defparam dyn_phase_shift_inst.device_family = device_family;

    assign dprio_clk = clk;
    self_reset self_reset_inst (mgmt_reset, clk, reset, dprio_init_reset);
    
    dprio_mux dprio_mux_inst (
    .init_dprio_address(init_dprio_address),
    .init_dprio_read(init_dprio_read),
    .init_dprio_byteen(init_dprio_byteen),
    .init_dprio_write(init_dprio_write),
    .init_dprio_writedata(init_dprio_writedata),


    .init_atpgmode(init_atpgmode),
    .init_mdio_dis(init_mdio_dis),
    .init_scanen(init_scanen),
    .init_ser_shift_load(init_ser_shift_load),
    .dprio_init_done(dprio_init_done),

    // Inputs from avmm master
    .avmm_dprio_address(avmm_dprio_address | dprio_address_1),
    .avmm_dprio_read(avmm_dprio_read | dprio_read_1),
    .avmm_dprio_byteen(avmm_dprio_byteen | dprio_byteen_1),
    .avmm_dprio_write(avmm_dprio_write),
    .avmm_dprio_writedata(avmm_dprio_writedata),

    .avmm_atpgmode(avmm_atpgmode),
    .avmm_mdio_dis(avmm_mdio_dis),
    .avmm_scanen(avmm_scanen),

    // Outputs to fpll
    .dprio_address(dprio_address),
    .dprio_read(dprio_read),
    .dprio_byteen(dprio_byteen),
    .dprio_write(dprio_write),
    .dprio_writedata(dprio_writedata),

    .atpgmode(dprio_atpgmode),
    .mdio_dis(dprio_mdio_dis),
    .scanen(dprio_scanen),
    .ser_shift_load(dprio_ser_shift_load)
    );


    fpll_dprio_init fpll_dprio_init_inst (
    .clk(clk),
    .reset_n(~reset),
    .locked(locked),

    //outputs
    .dprio_address(init_dprio_address),
    .dprio_read(init_dprio_read),
    .dprio_byteen(init_dprio_byteen),
    .dprio_write(init_dprio_write),
    .dprio_writedata(init_dprio_writedata),

    .atpgmode(init_atpgmode),
    .mdio_dis(init_mdio_dis),
    .scanen(init_scanen),
    .ser_shift_load(init_ser_shift_load),
    .dprio_init_done(dprio_init_done));

    //address luts, to be reconfigged by the Fitter
    //FPLL_1 or 0 address lut
    generic_lcell_comb lcell_fpll_0_1 (
		.dataa(1'b0),
        .combout (fpll_1));
    defparam lcell_fpll_0_1.lut_mask = 64'hAAAAAAAAAAAAAAAA;
	 defparam lcell_fpll_0_1.dont_touch = "on";
	 defparam lcell_fpll_0_1.family = device_family;


    wire dprio_read_combout;
     generic_lcell_comb lcell_dprio_read (
		.dataa(fpll_1),
        .datab(dprio_read),
        .datac(1'b0),
        .datad(1'b0),
        .datae(1'b0),
        .dataf(1'b0),
      .combout (dprio_read_combout));
    defparam lcell_dprio_read.lut_mask = 64'hCCCCCCCCCCCCCCCC;
	 defparam lcell_dprio_read.dont_touch = "on";
	 defparam lcell_dprio_read.family = device_family;

   
    


    //assign reconfig_to_pll signals
    assign reconfig_to_pll[0] = dprio_clk;
    assign reconfig_to_pll[1] = ~dprio_init_reset;
    assign reconfig_to_pll[2] = dprio_write;
    assign reconfig_to_pll[3] = dprio_read_combout;
    assign reconfig_to_pll[9:4] = dprio_address;
    assign reconfig_to_pll[25:10] = dprio_writedata;
    assign reconfig_to_pll[27:26] = dprio_byteen;
    assign reconfig_to_pll[28] = dprio_ser_shift_load;
    assign reconfig_to_pll[29] = dprio_mdio_dis;
    assign reconfig_to_pll[30] = phase_en;
    assign reconfig_to_pll[31] = up_dn;
    assign reconfig_to_pll[36:32] = cnt_sel;
    assign reconfig_to_pll[37] = dprio_scanen;
    assign reconfig_to_pll[38] = dprio_atpgmode;
    //assign reconfig_to_pll[40:37] = clken;
    assign reconfig_to_pll[63:39] = 0;

    //assign reconfig_from_pll signals
    assign dprio_readdata = reconfig_from_pll [15:0]; 
    assign locked_orig    = reconfig_from_pll [16];
    assign phase_done     = reconfig_from_pll [17];

endmodule
module self_reset (input wire mgmt_reset, input wire clk, output wire reset, output wire init_reset);

    localparam RESET_COUNTER_VALUE = 3'd2;
    localparam INITIAL_WAIT_VALUE = 9'd340;
    reg [9:0]counter;
    reg local_reset;
    reg usr_mode_init_wait;
    initial 
    begin
        local_reset = 1'b1;
        counter = 0;
        usr_mode_init_wait = 0;
    end

    always @(posedge clk)
    begin
        if (mgmt_reset)
        begin
            counter <= 0;
        end
        else
        begin
            if (!usr_mode_init_wait)
            begin
                if (counter == INITIAL_WAIT_VALUE)
                begin
                    local_reset <= 0;
                    usr_mode_init_wait <= 1'b1;
                    counter <= 0;
                end
                else 
                begin
                counter <= counter + 1'b1;
                end
            end
            else
            begin
                if (counter == RESET_COUNTER_VALUE)
                    local_reset <= 0;
                else 
                    counter <= counter + 1'b1;
            end
        end
    end
    assign reset = mgmt_reset | local_reset;
    assign init_reset = local_reset;
endmodule

module dprio_mux (
    // Inputs from init block
    input       [ 5:0]  init_dprio_address,
    input               init_dprio_read,
    input       [ 1:0]  init_dprio_byteen,
    input               init_dprio_write,
    input       [15:0]  init_dprio_writedata,

    input               init_atpgmode,
    input               init_mdio_dis,
    input               init_scanen,
    input               init_ser_shift_load,
    input               dprio_init_done,

    // Inputs from avmm master
    input       [ 5:0]  avmm_dprio_address,
    input               avmm_dprio_read,
    input       [ 1:0]  avmm_dprio_byteen,
    input               avmm_dprio_write,
    input       [15:0]  avmm_dprio_writedata,

    input               avmm_atpgmode,
    input               avmm_mdio_dis,
    input               avmm_scanen,
    input               avmm_ser_shift_load,

    // Outputs to fpll
    output      [ 5:0]  dprio_address,
    output              dprio_read,
    output      [ 1:0]  dprio_byteen,
    output              dprio_write,
    output      [15:0]  dprio_writedata,

    output              atpgmode,
    output              mdio_dis,
    output              scanen,
    output              ser_shift_load
);

    assign  dprio_address   = dprio_init_done ? avmm_dprio_address    : init_dprio_address;
    assign  dprio_read      = dprio_init_done ? avmm_dprio_read       : init_dprio_read;
    assign  dprio_byteen    = dprio_init_done ? avmm_dprio_byteen     : init_dprio_byteen;
    assign  dprio_write     = dprio_init_done ? avmm_dprio_write      : init_dprio_write;
    assign  dprio_writedata = dprio_init_done ? avmm_dprio_writedata  : init_dprio_writedata;

    assign  atpgmode        = init_atpgmode;
    assign  scanen          = init_scanen;
    assign  mdio_dis        = init_mdio_dis;
    assign  ser_shift_load  = init_ser_shift_load ;
endmodule
module fpll_dprio_init (
    input               clk,
    input               reset_n,
    input               locked,

    output      [ 5:0]  dprio_address,
    output              dprio_read,
    output      [ 1:0]  dprio_byteen,
    output              dprio_write,
    output      [15:0]  dprio_writedata,

    output  reg         atpgmode,
    output  reg         mdio_dis,
    output  reg         scanen,
    output  reg         ser_shift_load,
    output  reg         dprio_init_done
);

    reg [1:0] rst_n = 2'b00;
    reg [6:0] count = 7'd0;
    reg init_done_forever;

    // Internal versions of control signals
    wire  int_mdio_dis;
    wire  int_ser_shift_load;
    wire  int_dprio_init_done;
    wire  int_atpgmode/*synthesis keep*/;
    wire  int_scanen/*synthesis keep*/;


    assign  dprio_address   = count[6] ? 5'b0 : count[5:0] ;
    assign  dprio_byteen    = 2'b11;      // always enabled
    assign  dprio_write     = ~count[6] & reset_n ;  // write for first 64 cycles
    assign  dprio_read      = 1'b0;
    assign  dprio_writedata = 16'd0;

    assign  int_ser_shift_load  = count[6] ? |count[2:1]  : 1'b1; 
    assign  int_mdio_dis        = count[6] ? ~count[2]    : 1'b1;
    assign  int_dprio_init_done = ~init_done_forever ? (count[6] ? &count[2:0]  : 1'b0)
                                                    : 1'b1;
    assign  int_atpgmode        = 0;
    assign  int_scanen          = 0;

    initial begin
        count             = 7'd0;
        init_done_forever = 0;
        mdio_dis          = 1'b1;
        ser_shift_load    = 1'b1;
        dprio_init_done   = 1'b0;
        scanen            = 1'b0;
        atpgmode          = 1'b0;
    end

    // reset synch.
    always @(posedge clk or negedge reset_n)
        if(!reset_n)  rst_n <= 2'b00;
        else          rst_n <= {rst_n[0],1'b1};

    // counter
    always @(posedge clk)
    begin
        if (!rst_n[1])
            init_done_forever <= 1'b0;
        else
        begin
        if (count[6] && &count[1:0])
            init_done_forever <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n[1])
    begin
        if(!rst_n[1])
        begin
            count <= 7'd0;
        end
        else if(~int_dprio_init_done) 
        begin
            count <= count + 7'd1;
        end
        else
        begin
            count <= count;
        end
    end

    // outputs
    always @(posedge clk) begin
        mdio_dis        <= int_mdio_dis;
        ser_shift_load  <= int_ser_shift_load;
        dprio_init_done <= int_dprio_init_done;
        atpgmode        <= int_atpgmode;
        scanen          <= int_scanen;
    end

endmodule
module dyn_phase_shift
#(
    parameter device_family       = "Stratix V"
) ( 

    input   wire        clk,
    input   wire        reset,
    input   wire        phase_done,
    input   wire        pll_start_valid,
    input   wire        dps_changed,
    input   wire        dprio_write_done,
    input   wire [15:0] usr_num_shifts,
    input   wire [4:0]  usr_cnt_sel,
    input   wire        usr_up_dn,
    input   wire        locked,

    //output
    output  wire        dps_done,
    output  reg         phase_en,
    output  wire        up_dn,
    output  wire        dps_changed_valid,
    output  wire [4:0]  cnt_sel);
    
	

    reg        first_phase_shift_d;
    reg        first_phase_shift_q;
    reg [15:0] phase_en_counter;
    reg [3:0]       dps_current_state;
    reg [3:0]       dps_next_state;
    localparam DPS_START = 4'd0, DPS_WAIT_PHASE_DONE = 4'd1, DPS_DONE = 4'd2, DPS_WAIT_PHASE_EN = 4'd3, DPS_WAIT_DPRIO_WRITING = 4'd4, DPS_CHANGED = 4'd5; 
    localparam PHASE_EN_WAIT_COUNTER = 5'd1;

    reg [15:0] shifts_done_counter;
    reg        phase_done_final;
	 wire 		gnd /*synthesis keep*/;
	 
    //fsm
    //always block controlling the state regs
    always @(posedge clk)
    begin
        if (reset)
        begin
            dps_current_state <= DPS_DONE;
        end
        else
        begin
            dps_current_state <= dps_next_state;
        end
    end
    //the combinational part. assigning the next state
    //this turns on the phase_done_final signal when phase_done does this:
    //_____         ______
    //      |______|
    always @(*)
    begin
        phase_done_final = 0;
        first_phase_shift_d = 0;
        phase_en = 0;
        dps_next_state = DPS_DONE;
        case (dps_current_state)
            DPS_START:
            begin
                phase_en = 1'b1;
                dps_next_state = DPS_WAIT_PHASE_EN;
            end
            DPS_WAIT_PHASE_EN:
            begin
                phase_en = 1'b1;
                if (first_phase_shift_q)
                begin
                    first_phase_shift_d = 1'b1;
                    dps_next_state = DPS_WAIT_PHASE_EN;
                end
                else
                begin
                    if (phase_en_counter == PHASE_EN_WAIT_COUNTER)
                        dps_next_state = DPS_WAIT_PHASE_DONE;
                    else dps_next_state = DPS_WAIT_PHASE_EN;
                end
            end
            DPS_WAIT_PHASE_DONE:
            begin
                if (!phase_done | !locked)
                begin
                    dps_next_state = DPS_WAIT_PHASE_DONE;
                end
                else
                begin
                    if ((usr_num_shifts != shifts_done_counter) & (usr_num_shifts != 0))
                    begin
                        dps_next_state = DPS_START;
                        phase_done_final = 1'b1;
                    end
                    else
                    begin
                        dps_next_state = DPS_DONE;
                    end

                end
            end
            DPS_DONE:
            begin
                phase_done_final = 0;            
                if (dps_changed) 
                    dps_next_state = DPS_CHANGED;
                else dps_next_state = DPS_DONE;

            end
			DPS_CHANGED:
            begin
                if (pll_start_valid)
                    dps_next_state = DPS_WAIT_DPRIO_WRITING;
                else
                    dps_next_state = DPS_CHANGED;
            end
            DPS_WAIT_DPRIO_WRITING:
            begin
                if (dprio_write_done)
                    dps_next_state = DPS_START;
                else
                    dps_next_state = DPS_WAIT_DPRIO_WRITING;
            end

            default: dps_next_state = 4'bxxxx;
        endcase
    
    
    end

    always @(posedge clk)
    begin

        
        if (dps_current_state == DPS_WAIT_PHASE_DONE)
            phase_en_counter <= 0;
        else if (dps_current_state == DPS_WAIT_PHASE_EN)
            phase_en_counter <= phase_en_counter + 1'b1;

        if (reset)
        begin
            phase_en_counter <= 0;
            shifts_done_counter <= 1'b1;
            first_phase_shift_q <= 1;
        end
        else
        begin
            if (first_phase_shift_d)
                first_phase_shift_q <= 0;
            if (dps_done)
            begin
                shifts_done_counter <= 1'b1;
            end
            else
            begin
                if (phase_done_final & (dps_next_state!= DPS_DONE))
                    shifts_done_counter <= shifts_done_counter + 1'b1;
                else
                    shifts_done_counter <= shifts_done_counter;
            end
        end
    end

    assign dps_changed_valid = (dps_current_state == DPS_CHANGED);
    assign dps_done =(dps_current_state == DPS_DONE) | (dps_current_state == DPS_CHANGED);
    assign up_dn = usr_up_dn;
	 assign gnd = 1'b0;
	
    //cnt select luts (5)
    generic_lcell_comb lcell_cnt_sel_0 (
        .dataa(usr_cnt_sel[0]),
        .datab(usr_cnt_sel[1]),
        .datac(usr_cnt_sel[2]),
        .datad(usr_cnt_sel[3]),
        .datae(usr_cnt_sel[4]),
        .dataf(gnd),
        .combout (cnt_sel[0]));
    defparam lcell_cnt_sel_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
    defparam lcell_cnt_sel_0.dont_touch = "on";
    defparam lcell_cnt_sel_0.family = device_family;
    generic_lcell_comb lcell_cnt_sel_1 (
        .dataa(usr_cnt_sel[0]),
        .datab(usr_cnt_sel[1]),
        .datac(usr_cnt_sel[2]),
        .datad(usr_cnt_sel[3]),
        .datae(usr_cnt_sel[4]),
        .dataf(gnd),
        .combout (cnt_sel[1]));
    defparam lcell_cnt_sel_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
    defparam lcell_cnt_sel_1.dont_touch = "on";
    defparam lcell_cnt_sel_1.family = device_family;
    generic_lcell_comb lcell_cnt_sel_2 (
        .dataa(usr_cnt_sel[0]),
        .datab(usr_cnt_sel[1]),
        .datac(usr_cnt_sel[2]),
        .datad(usr_cnt_sel[3]),
        .datae(usr_cnt_sel[4]),
        .dataf(gnd),
        .combout (cnt_sel[2]));
    defparam lcell_cnt_sel_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
    defparam lcell_cnt_sel_2.dont_touch = "on";
    defparam lcell_cnt_sel_2.family = device_family;
    generic_lcell_comb lcell_cnt_sel_3 (
        .dataa(usr_cnt_sel[0]),
        .datab(usr_cnt_sel[1]),
        .datac(usr_cnt_sel[2]),
        .datad(usr_cnt_sel[3]),
        .datae(usr_cnt_sel[4]),
        .dataf(gnd),
        .combout (cnt_sel[3]));
    defparam lcell_cnt_sel_3.lut_mask = 64'hFF00FF00FF00FF00;
    defparam lcell_cnt_sel_3.dont_touch = "on";
    defparam lcell_cnt_sel_3.family = device_family;
    generic_lcell_comb lcell_cnt_sel_4 (
        .dataa(usr_cnt_sel[0]),
        .datab(usr_cnt_sel[1]),
        .datac(usr_cnt_sel[2]),
        .datad(usr_cnt_sel[3]),
        .datae(usr_cnt_sel[4]),
        .dataf(gnd),
        .combout (cnt_sel[4]));
    defparam lcell_cnt_sel_4.lut_mask = 64'hFFFF0000FFFF0000;
    defparam lcell_cnt_sel_4.dont_touch = "on";
    defparam lcell_cnt_sel_4.family = device_family;
   
    
endmodule

module generic_lcell_comb
#(
    //parameter
    parameter family             = "Stratix V",
    parameter lut_mask           = 64'hAAAAAAAAAAAAAAAA,
    parameter dont_touch         = "on"
) ( 

    input    dataa,
    input    datab,
    input    datac,
    input    datad,
    input    datae,
    input    dataf,

    output   combout
);

    generate
        if (family == "Stratix V")
        begin
            stratixv_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(datae),
                    .dataf(dataf),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end
        else if (family == "Arria V")
        begin
            arriav_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(datae),
                    .dataf(dataf),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end
        else if (family == "Arria V GZ")
        begin
            arriavgz_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(datae),
                    .dataf(dataf),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end
        else if (family == "Cyclone V")
        begin
            cyclonev_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(datae),
                    .dataf(dataf),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end
        endgenerate
endmodule
