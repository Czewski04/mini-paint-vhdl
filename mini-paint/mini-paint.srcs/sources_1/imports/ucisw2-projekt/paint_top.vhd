library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity paint_top is
    Port ( 
        i_clk_100mhz_p : in STD_LOGIC;
        i_clk_100mhz_n : in STD_LOGIC;
        i_reset_n    : in STD_LOGIC;

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
    component clk_wiz_0
        port (
            clk_25MHz : out STD_LOGIC;
            clk_125MHz : out STD_LOGIC;
            locked : out STD_LOGIC;
            clk_in1_p : in STD_LOGIC;
            clk_in1_n : in STD_LOGIC
        );
    end component;
    
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
      );
    END COMPONENT;

    signal s_clk_25mhz   : STD_LOGIC;
    signal s_clk_125mhz  : STD_LOGIC;
    signal s_pll_locked  : STD_LOGIC;
    signal s_sys_reset_n : STD_LOGIC;
    
    signal s_video_de    : STD_LOGIC;
    signal s_video_hsync : STD_LOGIC;
    signal s_video_vsync : STD_LOGIC;
    signal s_video_de_d1 : STD_LOGIC;
    signal s_video_de_d2 : STD_LOGIC;
    signal s_video_hsync_d1 : STD_LOGIC;
    signal s_video_hsync_d2 : STD_LOGIC;
    signal s_video_vsync_d1 : STD_LOGIC;
    signal s_video_vsync_d2 : STD_LOGIC;
    signal s_pixel_x     : STD_LOGIC_VECTOR(9 downto 0);
    signal s_pixel_y     : STD_LOGIC_VECTOR(9 downto 0);
    
    signal s_color_r     : STD_LOGIC_VECTOR(7 downto 0);
    signal s_color_g     : STD_LOGIC_VECTOR(7 downto 0);
    signal s_color_b     : STD_LOGIC_VECTOR(7 downto 0);


    signal s_mouse_we    : STD_LOGIC;
    signal s_write_addr  : STD_LOGIC_VECTOR(18 downto 0);
    signal s_write_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal s_read_addr   : STD_LOGIC_VECTOR(18 downto 0);
    signal s_read_data   : STD_LOGIC_VECTOR(7 downto 0);

    signal s_fb_ena       : STD_LOGIC;
    signal s_fb_enb       : STD_LOGIC;
    signal s_fb_wea       : STD_LOGIC_VECTOR(0 downto 0);
    signal s_fb_web       : STD_LOGIC_VECTOR(0 downto 0);
    signal s_fb_dinb      : STD_LOGIC_VECTOR(7 downto 0);
begin
    s_sys_reset_n <= s_pll_locked and not i_reset_n;

    s_fb_ena <= '1';
    s_fb_enb <= '1';
    s_fb_wea(0) <= s_mouse_we;
    s_fb_web <= (others => '0');
    s_fb_dinb <= (others => '0');

    s_read_addr <= std_logic_vector(resize(unsigned(s_pixel_y) * 640 + unsigned(s_pixel_x), 19));

    s_color_r <= s_read_data(7 downto 5) & s_read_data(7 downto 5) & s_read_data(7 downto 6);
    s_color_g <= s_read_data(4 downto 2) & s_read_data(4 downto 2) & s_read_data(4 downto 3);
    s_color_b <= s_read_data(1 downto 0) & s_read_data(1 downto 0) & s_read_data(1 downto 0) & s_read_data(1 downto 0);
    
    u_clk_wiz_0: clk_wiz_0
        port map ( 
            -- Clock out ports  
            clk_25MHz => s_clk_25mhz,
            clk_125MHz => s_clk_125mhz,
            -- Status and control signals                
            locked => s_pll_locked,
            -- Clock in ports
            clk_in1_p => i_clk_100mhz_p,
            clk_in1_n => i_clk_100mhz_n
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
            Clk  => s_clk_125mhz,
            RstN => s_sys_reset_n,
            We   => s_mouse_we,
            Addr => s_write_addr,
            Data => s_write_data
        );

    process(s_clk_25mhz)
    begin
        if rising_edge(s_clk_25mhz) then
            if s_sys_reset_n = '0' then
                s_video_de_d1 <= '0';
                s_video_de_d2 <= '0';
                s_video_hsync_d1 <= '0';
                s_video_hsync_d2 <= '0';
                s_video_vsync_d1 <= '0';
                s_video_vsync_d2 <= '0';
            else
                s_video_de_d1 <= s_video_de;
                s_video_de_d2 <= s_video_de_d1;
                s_video_hsync_d1 <= s_video_hsync;
                s_video_hsync_d2 <= s_video_hsync_d1;
                s_video_vsync_d1 <= s_video_vsync;
                s_video_vsync_d2 <= s_video_vsync_d1;
            end if;
        end if;
    end process;

    u_hdmi_tx: entity work.HDMI_TX_wrap
        port map (
            pxClk      => s_clk_25mhz,
            pxClkX5    => s_clk_125mhz,
            ResetN     => s_sys_reset_n,
            DE         => s_video_de_d2,
            HSync      => s_video_hsync_d2,
            VSync      => s_video_vsync_d2,
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
        
    u_framebuffer : blk_mem_gen_0
      PORT MAP (
                clka => s_clk_125mhz,
                ena => s_fb_ena,
                wea => s_fb_wea,
                addra => s_write_addr,
                dina => s_write_data,
                douta => open,
                clkb => s_clk_25mhz,
                enb => s_fb_enb,
                web => s_fb_web,
                addrb => s_read_addr,
                dinb => s_fb_dinb,
                doutb => s_read_data
      );

end structural;