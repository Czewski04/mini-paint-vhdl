library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity paint_top is
    Port ( 
        i_clk_100mhz : in STD_LOGIC;
        i_reset_n    : in STD_LOGIC; -- Fizyczny przycisk reset na płycie (aktywny stanem niskim)

        o_hdmi_d0_p  : out STD_LOGIC;
        o_hdmi_d0_n  : out STD_LOGIC;
        o_hdmi_d1_p  : out STD_LOGIC;
        o_hdmi_d1_n  : out STD_LOGIC;
        o_hdmi_d2_p  : out STD_LOGIC;
        o_hdmi_d2_n  : out STD_LOGIC;
        o_hdmi_clk_p : out STD_LOGIC;
        o_hdmi_clk_n : out STD_LOGIC
    );
end paint_top;

architecture structural of paint_top is
    signal s_clk_25mhz   : STD_LOGIC;
    signal s_clk_125mhz  : STD_LOGIC;
    signal s_pll_locked  : STD_LOGIC;
    signal s_sys_reset_n : STD_LOGIC;
    
    signal s_video_de    : STD_LOGIC;
    signal s_video_hsync : STD_LOGIC;
    signal s_video_vsync : STD_LOGIC;
    signal s_pixel_x     : STD_LOGIC_VECTOR(9 downto 0);
    signal s_pixel_y     : STD_LOGIC_VECTOR(9 downto 0);
    
    signal s_color_r     : STD_LOGIC_VECTOR(7 downto 0);
    signal s_color_g     : STD_LOGIC_VECTOR(7 downto 0);
    signal s_color_b     : STD_LOGIC_VECTOR(7 downto 0);

begin
    s_sys_reset_n <= i_reset_n and s_pll_locked;

    u_clk_wiz: entity work.clk_wiz
        port map (
            clk_in1    => i_clk_100mhz,
            clk_25MHz  => s_clk_25mhz,
            clk_125MHz => s_clk_125mhz,
            locked     => s_pll_locked
        );

    u_video_timing: entity work.video_timing
        port map (
            pixClk     => s_clk_25mhz,
            ResetN     => s_sys_reset_n,
            DE         => s_video_de,
            HSync      => s_video_hsync,
            VSync      => s_video_vsync,
            PosX       => s_pixel_x,
            PosY       => s_pixel_y
        );

    u_img_gen: entity work.img_gen
        port map (
            Clk      => s_clk_25mhz,
            RstN  => s_sys_reset_n,
            PosX  => s_pixel_x,
            PosY  => s_pixel_y,
            R  => s_color_r,
            G  => s_color_g,
            B  => s_color_b
        );

    u_hdmi_tx: entity work.HDMI_TX_wrap
        port map (
            pxClk      => s_clk_25mhz,
            pxClkX5    => s_clk_125mhz,
            ResetN     => s_sys_reset_n,
            DE         => s_video_de,
            HSync      => s_video_hsync,
            VSync      => s_video_vsync,
            R          => s_color_r,
            G          => s_color_g,
            B          => s_color_b,
            HDMI_D0_P  => o_hdmi_d0_p,
            HDMI_D0_N  => o_hdmi_d0_n,
            HDMI_D1_P  => o_hdmi_d1_p,
            HDMI_D1_N  => o_hdmi_d1_n,
            HDMI_D2_P  => o_hdmi_d2_p,
            HDMI_D2_N  => o_hdmi_d2_n,
            HDMI_CK_P  => o_hdmi_clk_p,
            HDMI_CK_N  => o_hdmi_clk_n
        );

end structural;