library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RotaryEnc_wrap is
    Port (  ROT_A : in  std_logic;
            ROT_B : in  std_logic;
            Clk   : in  std_logic;
            RotL  : out std_logic;
            RotR  : out std_logic
          );
end RotaryEnc_wrap;


architecture wrap of RotaryEnc_wrap is

    component RotaryEnc is
        Port (  ROT_A : in  std_logic;
                ROT_B : in  std_logic;
                Clk   : in  std_logic;
                RotL  : out std_logic;
                RotR  : out std_logic
              );
    end component;

begin

    i_wrap: RotaryEnc port map(
        ROT_A => ROT_A,
        ROT_B => ROT_B,
        Clk   => Clk,
        RotL  => RotL, 
        RotR  => RotR
        );

end wrap;
