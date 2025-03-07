--------------------------------------------------------------------------------
-- HDMI PLL Adjust
--------------------------------------------------------------------------------

-- Changes the HDMI PLL frequency according to the scaler suggestions.
--------------------------------------------
-- LLTUNE :
--  0   : Input Display Enable
--  1   : Input Vsync
--  2   : Input Interlaced mode
--  3   : Input Interlaced field
--  4   : Output Image frame
--  5   : 
--  6   : Input clock
--  7   : Output clock
  
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pll_hdmi_adj IS
  PORT (
    -- Scaler
    llena         : IN  std_logic; -- 0=Disabled 1=Enabled
    lltune        : IN  unsigned(15 DOWNTO 0); -- Outputs from scaler
    
    locked        : OUT std_logic;
    
    -- Signals from reconfig commands
    i_waitrequest : OUT std_logic;
    i_write       : IN  std_logic;
    i_address     : IN  unsigned(5 DOWNTO 0);
    i_writedata   : IN  unsigned(31 DOWNTO 0);

    -- Outputs to PLL_HDMI_CFG
    o_waitrequest : IN  std_logic;
    o_write       : OUT std_logic;
    o_address     : OUT unsigned(5 DOWNTO 0);
    o_writedata   : OUT unsigned(31 DOWNTO 0);
    
    ------------------------------------
    clk           : IN  std_logic;
    reset_na      : IN  std_logic
    );

BEGIN

  
END ENTITY pll_hdmi_adj;

--##############################################################################

ARCHITECTURE rtl OF pll_hdmi_adj IS

  SIGNAL i_clk,i_de,i_de2,i_vss,i_vss2,i_vss_delay,i_ce : std_logic;
  SIGNAL i_linecpt,i_line : natural RANGE 0 TO 2**12-1;
  SIGNAL i_delay : natural RANGE 0 TO 2**14-1;
  
  SIGNAL pwrite : std_logic;
  SIGNAL paddress : unsigned(5 DOWNTO 0);
  SIGNAL pdata    : unsigned(31 DOWNTO 0);
  TYPE enum_state IS (sIDLE,sW1,sW2,sW3,sW4,sW5,sW6);
  SIGNAL state : enum_state;
  SIGNAL tune_freq,tune_phase : unsigned(5 DOWNTO 0);
  SIGNAL lltune_sync,lltune_sync2,lltune_sync3 : unsigned(15 DOWNTO 0);
  SIGNAL mfrac,mfrac_mem,mfrac_ref,diff : unsigned(40 DOWNTO 0);
  SIGNAL mul : unsigned(15 DOWNTO 0);
  SIGNAL sign,sign_pre : std_logic;
  SIGNAL expand : boolean;
  SIGNAL up,modo,phm,dir : std_logic;
  SIGNAL cpt : natural RANGE 0 TO 3;
  SIGNAL col : natural RANGE 0 TO 15;
  
  SIGNAL icpt,ocpt,o2cpt,ssh,ofsize,ifsize : natural RANGE 0 TO 2**24-1;
  SIGNAL ivss,ivss2,itog : std_logic;
  SIGNAL ovss,ovss2,otog : std_logic;
  SIGNAL sync,pulse,los,lop : std_logic;
  SIGNAL osize,offset,osizep,offsetp : signed(23 DOWNTO 0);
  SIGNAL logcpt : natural RANGE 0 TO 31;
  SIGNAL udiff : integer RANGE -2**23 TO 2**23-1 :=0;
  
BEGIN
  
  ----------------------------------------------------------------------------
  -- 4 lines delay to input
  i_vss<=lltune(0);
  i_de <=lltune(1);
  i_ce <=lltune(5);
  i_clk<=lltune(6);
  
  Delay:PROCESS(i_clk) IS
  BEGIN
    IF rising_edge(i_clk) THEN
      IF i_ce='1' THEN
        -- Measure input line time.
        i_de2<=i_de;
        
        IF i_de='1' AND i_de2='0' THEN
          i_linecpt<=0;
          IF i_vss='1' THEN
            i_line<=i_linecpt;
          END IF;
        ELSE
          i_linecpt<=i_linecpt+1;
        END IF;
        
        -- Delay 4 lines
        i_vss2<=i_vss;
        IF i_vss/=i_vss2 THEN
          i_delay<=0;
        ELSIF i_delay=i_line * 4 THEN
          i_vss_delay<=i_vss;
        ELSE
          i_delay<=i_delay+1;
        END IF;
      END IF;
    END IF;
  END PROCESS Delay;
  
  ----------------------------------------------------------------------------
  -- Sample image sizes
  Sampler:PROCESS(clk,reset_na) IS
  BEGIN
    IF reset_na='0' THEN
--pragma synthesis_off
      otog<='0';
      itog<='0';
      ivss<='0';
      ivss2<='0';
      ovss<='0';
      ovss2<='0';
--pragma synthesis_on
      
    ELSIF rising_edge(clk) THEN
      -- Clock domain crossing
      
      ivss<=i_vss_delay; -- <ASYNC>
      ivss2<=ivss;
      
      ovss<=lltune(4); -- <ASYNC>
      ovss2<=ovss;
      
      otog<=otog XOR (ovss AND NOT ovss2);
      
      -- Measure output frame time
      IF ovss='1' AND ovss2='0' AND otog='1' THEN
        ocpt<=0;
        osizep<=to_signed(ocpt,24);
      ELSE
        ocpt<=ocpt+1;
      END IF;
      IF ovss='0' AND ovss2='1' AND otog='0' THEN
        o2cpt<=0;
      ELSE
        o2cpt<=o2cpt+1;
      END IF;
      
      -- Measure output image time
      IF ovss='0' AND ovss2='1' AND otog='0' THEN
        ofsize<=ocpt;
      END IF;
      
      itog<=itog XOR (ivss AND NOT ivss2);

      -- Measure input frame time
      IF ivss='1' AND ivss2='0' AND itog='1' THEN
        icpt<=0;
        osize<=osizep;
        udiff<=integer(to_integer(osizep)) - integer(icpt);
        sync<='1';
      ELSE
        icpt<=icpt+1;
        sync<='0';
      END IF;

      -- Measure input image time
      IF ivss='0' AND ivss2='1' AND itog='0' THEN
        ifsize<=icpt;
      END IF;
      
      expand<=(ofsize>=ifsize);
      -- IN  |  #########       | EXPAND = 1
      -- OUT |   #############  |

      -- IN  |  #########       | EXPAND = 0
      -- OUT |      ######      |
      
      IF expand THEN
        IF ivss='1' AND ivss2='0' AND itog='1' THEN
          offset<=to_signed(ocpt,24);
        END IF;
      ELSE
        IF ivss='0' AND ivss2='1' AND itog='0' THEN
          offset<=to_signed(o2cpt,24);
        END IF;
      END IF;
      
      --------------------------------------------
      pulse<='0';
      IF sync='1' THEN
        logcpt<=0;
        ssh<=to_integer(osize);
        los<='0';
        lop<='0';
        
      ELSIF logcpt<24 THEN
        -- Frequency difference
        IF udiff>0 AND ssh<udiff AND los='0' THEN
          tune_freq<='0' & to_unsigned(logcpt,5);
          los<='1';
        ELSIF udiff<=0 AND ssh<-udiff AND los='0' THEN
          tune_freq<='1' & to_unsigned(logcpt,5);
          los<='1';
        END IF;
        -- Phase difference
        IF offset<osize/2 AND ssh<offset AND lop='0' THEN
          tune_phase<='0' & to_unsigned(logcpt,5);
          lop<='1';
        ELSIF offset>=osize/2 AND ssh<(osize-offset) AND lop='0' THEN
          tune_phase<='1' & to_unsigned(logcpt,5);
          lop<='1';
        END IF;
        ssh<=ssh/2;
        logcpt<=logcpt+1;
        
      ELSIF logcpt=24 THEN
        pulse<='1';
        ssh<=ssh/2;
        logcpt<=logcpt+1;
      END IF;

    END IF;
  END PROCESS Sampler;
  
    ----------------------------------------------------------------------------
  -- 000010 : Start reg "Write either 0 or 1 to start fractional PLL reconf.
  -- 000100 : M counter
  -- 000111 : M counter Fractional Value K
  
  Comb:PROCESS(i_write,i_address,
               i_writedata,pwrite,paddress,pdata) IS
  BEGIN
    IF i_write='1' THEN
      o_write      <=i_write;
      o_address    <=i_address;
      o_writedata  <=i_writedata;
    ELSE
      o_write    <=pwrite;
      o_address  <=paddress;
      o_writedata<=pdata;
    END IF;
  END PROCESS Comb;
  
  i_waitrequest<=o_waitrequest WHEN state=sIDLE ELSE '0';
    
  ----------------------------------------------------------------------------
  Schmurtz:PROCESS(clk,reset_na) IS
    VARIABLE off_v,ofp_v : natural RANGE 0 TO 63;
    VARIABLE diff_v : unsigned(40 DOWNTO 0);
    VARIABLE mulco : unsigned(15 DOWNTO 0);
    VARIABLE up_v,sign_v : std_logic;
  BEGIN
    IF reset_na='0' THEN
      modo<='0';
      state<=sIDLE;
    ELSIF rising_edge(clk) THEN
      ------------------------------------------------------
      -- Snoop accesses to PLL reconfiguration
      IF i_address="000100" AND i_write='1' THEN
        mfrac    (40 DOWNTO 32)<=('0' & i_writedata(15 DOWNTO 8)) +
                                 ('0' & i_writedata(7  DOWNTO 0));
        mfrac_ref(40 DOWNTO 32)<=('0' & i_writedata(15 DOWNTO 8)) +
                                 ('0' & i_writedata(7  DOWNTO 0));
        mfrac_mem(40 DOWNTO 32)<=('0' & i_writedata(15 DOWNTO 8)) +
                                 ('0' & i_writedata(7  DOWNTO 0));
        mul<=i_writedata(15 DOWNTO 0);
        modo<='1';
      END IF;
      
      IF i_address="000111" AND i_write='1' THEN
        mfrac    (31 DOWNTO 0)<=i_writedata;
        mfrac_ref(31 DOWNTO 0)<=i_writedata;
        mfrac_mem(31 DOWNTO 0)<=i_writedata;
        modo<='1';
      END IF;
      
      ------------------------------------------------------
      -- Tuning
      off_v:=to_integer('0' & tune_freq(4 DOWNTO 0));
      ofp_v:=to_integer('0' & tune_phase(4 DOWNTO 0));
      --IF off_v<8 THEN off_v:=8; END IF;
      --IF ofp_v<7 THEN ofp_v:=7; END IF;
      IF off_v<4 THEN off_v:=4; END IF;
      IF ofp_v<4 THEN ofp_v:=4; END IF;
      
      IF off_v>=18 AND ofp_v>=18 THEN
        locked<=llena;
      ELSE
        locked<='0';
      END IF;
      
      up_v:='0';
      IF pulse='1' THEN
        cpt<=(cpt+1) MOD 4;
        IF llena='0' THEN 
          -- Recover original freq when disabling low lag mode
          cpt<=0;
          col<=0;
          IF modo='1' THEN
            mfrac<=mfrac_mem;
            mfrac_ref<=mfrac_mem;
            up<='1';
            modo<='0';
          END IF;
          
        ELSIF phm='0' AND cpt=0 THEN
          -- Frequency adjust
          sign_v:=tune_freq(5);
          IF col<10 THEN col<=col+1; END IF;
          IF off_v>=16 AND col>=10 THEN
            phm<='1';
            col<=0;
          ELSE
            off_v:=off_v+1;
            IF off_v>17 THEN
              off_v:=off_v + 3;
            END IF;
            up_v:='1';
            up<='1';
          END IF;
          
        ELSIF cpt=0 THEN
          -- Phase adjust
          sign_v:=NOT tune_phase(5);
          col<=col+1;
          IF col>=10 THEN
            phm<='0';
            up_v:='1';
            off_v:=31;
            col<=0;
          ELSE
            off_v:=ofp_v + 1;
            IF ofp_v>7 THEN
              off_v:=off_v + 1;
            END IF;
            IF ofp_v>14 THEN
              off_v:=off_v + 2;
            END IF;
            IF ofp_v>17 THEN
              off_v:=off_v + 3;
            END IF;
            up_v:='1';
          END IF;
          up<='1';
        END IF;
      END IF;
      
      diff_v:=shift_right(mfrac_ref,off_v);
      IF sign_v='0' THEN
        diff_v:=mfrac_ref + diff_v;
      ELSE
        diff_v:=mfrac_ref - diff_v;
      END IF;
      
      IF up_v='1' THEN
        mfrac<=diff_v;
      END IF;
      
      IF up_v='1' AND phm='0' THEN
        mfrac_ref<=diff_v;
      END IF;
      
      ------------------------------------------------------
      -- Update PLL registers
      mulco:=mfrac(40 DOWNTO 33) & (mfrac(40 DOWNTO 33) + ('0' & mfrac(32)));
      
      CASE state IS
        WHEN sIDLE =>
          pwrite<='0';
          IF up='1' THEN
            up<='0';
            IF mulco/=mul THEN
              state<=sW1;
            ELSE
              state<=sW3;
            END IF;
          END IF;
          
        WHEN sW1 => -- Change M multiplier
          mul<=mulco;
          pdata<=x"0000" & mulco;
          paddress<="000100";
          pwrite<='1';
          state<=sW2;
          
        WHEN sW2 =>
          IF pwrite='1' AND o_waitrequest='0' THEN
            state<=sW3;
            pwrite<='0';
          END IF;
          
        WHEN sW3 => -- Change M fractional value
          pdata<=mfrac(31 DOWNTO 0);
          paddress<="000111";
          pwrite<='1';
          state<=sW4;
          
        WHEN sW4 =>
          IF pwrite='1' AND o_waitrequest='0' THEN
            state<=sW5;
            pwrite<='0';
          END IF;
          
        WHEN sW5 =>
          pdata<=x"0000_0001";
          paddress<="000010";
          pwrite<='1';
          state<=sW6;
          
        WHEN sW6 =>
          IF pwrite='1' AND o_waitrequest='0' THEN
            pwrite<='0';
            state<=sIDLE;
          END IF;
      END CASE;

    END IF;
  END PROCESS Schmurtz;
  
  ----------------------------------------------------------------------------
  
END ARCHITECTURE rtl;

