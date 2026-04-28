library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2_Mouse_wrap is
    Port (
        Clk_100MHz : in   STD_LOGIC;
        Reset      : in   STD_LOGIC;
        InitOK     : out  STD_LOGIC;
        B1_Status  : out  STD_LOGIC_VECTOR (7 downto 0);
        B2_X       : out  STD_LOGIC_VECTOR (7 downto 0);
        B3_Y       : out  STD_LOGIC_VECTOR (7 downto 0);
        Data_Rdy   : out  STD_LOGIC;
        PS2_Data   : inout  STD_LOGIC;
        PS2_Clk    : inout  STD_LOGIC
        );
end PS2_Mouse_wrap;

architecture wrapper of PS2_Mouse_wrap is

    component PS2_Mouse is
        Port ( 
            Clk_100MHz : in   STD_LOGIC;
            Reset      : in   STD_LOGIC;
            InitOK     : out  STD_LOGIC;
            B1_Status  : out  STD_LOGIC_VECTOR (7 downto 0);
            B2_X       : out  STD_LOGIC_VECTOR (7 downto 0);
            B3_Y       : out  STD_LOGIC_VECTOR (7 downto 0);
            Data_Rdy   : out  STD_LOGIC;
            PS2_Data   : inout  STD_LOGIC;
            PS2_Clk    : inout  STD_LOGIC
            );
    end component;

begin

i_wrap:PS2_Mouse port map (
        Clk_100MHz => Clk_100MHz,
        Reset      => Reset,
        InitOK     => InitOK,
        B1_Status  => B1_Status,
        B2_X       => B2_X,
        B3_Y       => B3_Y,
        Data_Rdy   => Data_Rdy,
        PS2_Data   => PS2_Data,
        PS2_Clk    => PS2_Clk 
        );

end wrapper;

