-----------------------------------------------------------------------------
--
--   Basic Video Timing Generator
--   J.Sugier, PWr Edu PL
--
-----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity video_timing is
    Port ( pixClk : in  STD_LOGIC;
           ResetN : in  STD_LOGIC;
           DE     : out  STD_LOGIC;
           HSync  : out  STD_LOGIC;
           VSync  : out  STD_LOGIC;
           PosX   : out  STD_LOGIC_VECTOR (9 downto 0);
           PosY   : out  STD_LOGIC_VECTOR (9 downto 0)
		);
end video_timing;


architecture Behavioral of video_timing is

    -- Mode definition: 640x480 @ 60Hz adjusted for 25.000MHz pixel clock
    constant H_VISIBLE_PIXELS : integer := 640;
    constant H_FRONT_PORCH    : integer :=  16;
    constant H_SYNC_PULSE     : integer :=  96;
    constant H_BACK_PORCH     : integer :=  48;     -- total pixels: 800
    constant V_VISIBLE_LINES  : integer := 480;
    constant V_FRONT_PORCH    : integer :=  10;
    constant V_SYNC_PULSE     : integer :=   2;
    constant V_BACK_PORCH     : integer :=  29;     -- total lines: 521, b.porch length reduced for 25.000MHz
    constant H_SYNC_VALUE     : std_logic := '0';   -- negative pulse
    constant V_SYNC_VALUE     : std_logic := '0';   -- negative pulse
    
    -- Timing params calculated from mode definition
    constant LAST_VISIBLE_PX  : integer := H_VISIBLE_PIXELS - 1;            -- counted from 0
    constant LAST_FPORCH_PX   : integer := LAST_VISIBLE_PX + H_FRONT_PORCH;
    constant LAST_HSYNC_PX    : integer := LAST_FPORCH_PX + H_SYNC_PULSE;
    constant LAST_BPORCH_PX   : integer := LAST_HSYNC_PX + H_BACK_PORCH;    -- = total pixels - 1
    constant LAST_VISIBLE_LN  : integer := V_VISIBLE_LINES - 1;
    constant LAST_FPORCH_LN   : integer := LAST_VISIBLE_LN + V_FRONT_PORCH;
    constant LAST_VSYNC_LN    : integer := LAST_FPORCH_LN + V_SYNC_PULSE;
    constant LAST_BPORCH_LN   : integer := LAST_VSYNC_LN + V_BACK_PORCH;    -- = total lines - 1

	-- Counters: pixels (X) and lines (Y)
	-- counting sequence: display area -> front porch -> sync pulse -> back porch
	signal cntX : unsigned( 9 downto 0 ) := ( others => '0' );
	signal cntY : unsigned( 9 downto 0 ) := ( others => '0' );
	-- terminal count signals
	signal cntX_TC, cntY_TC : std_logic;
	
	-- Display enable signals (visible area)
	signal DE_X, DE_Y : std_logic := '1';

begin

	-- Horizontal counter cntX
	cntX_TC <= '1' when cntX = LAST_BPORCH_PX  else '0';
	process( pixClk )
	begin
		if rising_edge( pixClk ) then
			if ResetN = '0' or cntX_TC = '1' then
				cntX <= ( others => '0' );
			else
				cntX <= cntX + 1;
			end if;
		end if;
	end process;

	-- Vertical counter cntY; cntX_TC as clock enable
	cntY_TC <= '1' when cntX_TC = '1' and cntY = LAST_BPORCH_LN  else '0';
	process( pixClk )
	begin
		if rising_edge( pixClk ) then
			if ResetN = '0' or cntY_TC = '1' then
				cntY <= ( others => '0' );
			elsif cntX_TC = '1' then
				cntY <= cntY + 1;
			end if;
		end if;
	end process;

	-- Sync pulses, as flip-flops
	process( pixClk )
	begin
		if rising_edge( pixClk ) then
			if ResetN = '0' or cntX = LAST_HSYNC_PX then
				HSync <= not H_SYNC_VALUE;
			elsif cntX = LAST_FPORCH_PX then
				HSync <= H_SYNC_VALUE;
			end if;
		end if;
	end process;
	
	process( pixClk )
	begin
		if rising_edge( pixClk ) then
			if ResetN = '0' or ( cntY = LAST_VSYNC_LN and cntX_TC = '1' ) then
				VSync <= not V_SYNC_VALUE;
			elsif cntY = LAST_FPORCH_LN and cntX_TC = '1' then
				VSync <= V_SYNC_VALUE;
			end if;
		end if;
	end process;

	-- Display enable signals, as flip-flops
	process( pixClk )
	begin
		if rising_edge( pixClk ) then
			if ResetN = '0' or cntX = LAST_VISIBLE_PX then
				DE_X <= '0';
			elsif cntX_TC = '1' then
				DE_X <= '1';
			end if;
		end if;
	end process;
	
	process( pixClk )
	begin
		if rising_edge( pixClk ) then
			if ResetN = '0' or ( cntY = LAST_VISIBLE_LN and cntX_TC = '1' ) then
				DE_Y <= '0';
			elsif cntY_TC = '1' then
				DE_Y <= '1';
			end if;
		end if;
	end process;
	-- Output port
	DE <= DE_X and DE_Y;
	
	-- Outputs to the pixel generator (current pixel position)
	PosX <= std_logic_vector( cntX );
	PosY <= std_logic_vector( cntY );

end Behavioral;