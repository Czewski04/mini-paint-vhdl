library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HDMI_TX_wrap is
    Port (
        pxClk     : in  STD_LOGIC;
        pxClkX5   : in  STD_LOGIC;
        ResetN    : in  STD_LOGIC;
        DE        : in  STD_LOGIC;
        HSync     : in  STD_LOGIC;
        VSync     : in  STD_LOGIC;
        R         : in  STD_LOGIC_VECTOR( 7 downto 0 );
        G         : in  STD_LOGIC_VECTOR( 7 downto 0 );
        B         : in  STD_LOGIC_VECTOR( 7 downto 0 );
        HDMI_D0_P : out STD_LOGIC;
        HDMI_D0_N : out STD_LOGIC;
        HDMI_D1_P : out STD_LOGIC;
        HDMI_D1_N : out STD_LOGIC;
        HDMI_D2_P : out STD_LOGIC;
        HDMI_D2_N : out STD_LOGIC;
        HDMI_CK_P : out STD_LOGIC;
        HDMI_CK_N : out STD_LOGIC
        );
end HDMI_TX_wrap;

architecture RTL of HDMI_TX_wrap is

    component HDMI_TX is
        Port ( 
            pxClk     : in  STD_LOGIC;
            pxClkX5   : in  STD_LOGIC;
            ResetN    : in  STD_LOGIC;
            DE        : in  STD_LOGIC;
            HSync     : in  STD_LOGIC;
            VSync     : in  STD_LOGIC;
            R         : in  STD_LOGIC_VECTOR( 7 downto 0 );
            G         : in  STD_LOGIC_VECTOR( 7 downto 0 );
            B         : in  STD_LOGIC_VECTOR( 7 downto 0 );
            HDMI_D0_P : out STD_LOGIC;
            HDMI_D0_N : out STD_LOGIC;
            HDMI_D1_P : out STD_LOGIC;
            HDMI_D1_N : out STD_LOGIC;
            HDMI_D2_P : out STD_LOGIC;
            HDMI_D2_N : out STD_LOGIC;
            HDMI_CK_P : out STD_LOGIC;
            HDMI_CK_N : out STD_LOGIC
           );
    end component;
  
begin

    i_wrap: HDMI_TX port map( 
               pxClk     => pxClk,  
               pxClkX5   => pxClkX5,
               ResetN    => ResetN,
               DE        => DE,
               HSync     => HSync,
               VSync     => VSync,
               R         => R,
               G         => G,
               B         => B,
               HDMI_D0_P => HDMI_D0_P,
               HDMI_D0_N => HDMI_D0_N,
               HDMI_D1_P => HDMI_D1_P,
               HDMI_D1_N => HDMI_D1_N,
               HDMI_D2_P => HDMI_D2_P,
               HDMI_D2_N => HDMI_D2_N,
               HDMI_CK_P => HDMI_CK_P,
               HDMI_CK_N => HDMI_CK_N
               );

end RTL;

