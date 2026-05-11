library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity paint_top is
    Port ( 
        i_clk_100mhz_p : in STD_LOGIC;
        i_clk_100mhz_n : in STD_LOGIC;
        i_reset_n : in STD_LOGIC;

        io_ps2_data : inout STD_LOGIC;
        io_ps2_clk : inout STD_LOGIC;

        i_rot_a        : in STD_LOGIC;
        i_rot_b        : in STD_LOGIC;
        i_sw_brush_en  : in STD_LOGIC;
        o_led_brush_en : out STD_LOGIC;

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
            clk_100Mhz : out STD_LOGIC;
            locked : out STD_LOGIC;
            clk_in1_p : in STD_LOGIC;
            clk_in1_n : in STD_LOGIC
        );
    end component;
    
    component blk_mem_gen_0
        port (
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
    end component;

    component RotaryEnc_wrap is
        Port (
            ROT_A : in std_logic;
            ROT_B : in std_logic;
            Clk   : in std_logic;
            RotL  : out std_logic;
            RotR  : out std_logic
        );
    end component;

    signal s_clk_25mhz   : STD_LOGIC;
    signal s_clk_125mhz  : STD_LOGIC;
    signal s_clk_100mhz  : STD_LOGIC;
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
    signal s_pixel_x_d1     : STD_LOGIC_VECTOR(9 downto 0);
    signal s_pixel_y_d1     : STD_LOGIC_VECTOR(9 downto 0);
    signal s_pixel_x_d2     : STD_LOGIC_VECTOR(9 downto 0);
    signal s_pixel_y_d2     : STD_LOGIC_VECTOR(9 downto 0);
    
    signal s_color_r     : STD_LOGIC_VECTOR(7 downto 0);
    signal s_color_g     : STD_LOGIC_VECTOR(7 downto 0);
    signal s_color_b     : STD_LOGIC_VECTOR(7 downto 0);
    
    signal s_write_addr  : STD_LOGIC_VECTOR(18 downto 0);
    signal s_write_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal s_read_addr   : STD_LOGIC_VECTOR(18 downto 0);
    signal s_read_data   : STD_LOGIC_VECTOR(7 downto 0);
    
    signal s_mouse_init_ok : STD_LOGIC;
    signal s_mouse_data_rdy : STD_LOGIC;
    signal s_mouse_status : STD_LOGIC_VECTOR(7 downto 0);
    signal s_mouse_dx : STD_LOGIC_VECTOR(7 downto 0);
    signal s_mouse_dy : STD_LOGIC_VECTOR(7 downto 0);
    signal s_cursor_x : unsigned(9 downto 0) := to_unsigned(320, 10);
    signal s_cursor_y : unsigned(9 downto 0) := to_unsigned(240, 10);
    signal s_mouse_data_rdy_last : STD_LOGIC := '0';
    signal s_mouse_reset : STD_LOGIC;
    
    signal s_fb_ena       : STD_LOGIC;
    signal s_fb_enb       : STD_LOGIC;
    signal s_fb_ina       : STD_LOGIC_VECTOR(0 downto 0);
    signal s_fb_inb       : STD_LOGIC_VECTOR(0 downto 0);
    signal s_fb_dinb      : STD_LOGIC_VECTOR(7 downto 0);
    signal s_init_in      : STD_LOGIC;
    signal s_init_addr    : STD_LOGIC_VECTOR(18 downto 0);
    signal s_init_data    : STD_LOGIC_VECTOR(7 downto 0);
    signal s_init_done    : STD_LOGIC;

    signal s_rot_l        : STD_LOGIC;
    signal s_rot_r        : STD_LOGIC;
    signal s_brush_size   : integer range 1 to 480 := 1;

    signal s_draw_x_offset : integer range 0 to 479 := 0;
    signal s_draw_y_offset : integer range 0 to 479 := 0;
    signal s_draw_we       : STD_LOGIC := '0';
    signal s_paint_addr_x  : integer;
    signal s_paint_addr_y  : integer;
    signal s_safe_we       : STD_LOGIC;
    signal s_write_addr_calc : STD_LOGIC_VECTOR(18 downto 0);

begin
    s_sys_reset_n <= s_pll_locked and not i_reset_n;
    s_mouse_reset <= not s_sys_reset_n;
    
    s_fb_ena <= '1';
    s_fb_enb <= '1';
    s_fb_inb <= (others => '0');
    s_fb_dinb <= (others => '0');

    s_read_addr <= std_logic_vector(resize(unsigned(s_pixel_y) * 640 + unsigned(s_pixel_x), 19));

    u_ps2_mouse: entity work.PS2_Mouse_wrap
        port map (
            Clk_100MHz => s_clk_100mhz,
            Reset      => s_mouse_reset,
            InitOK     => s_mouse_init_ok,
            B1_Status  => s_mouse_status,
            B2_X       => s_mouse_dx,
            B3_Y       => s_mouse_dy,
            Data_Rdy   => s_mouse_data_rdy,
            PS2_Data   => io_ps2_data,
            PS2_Clk    => io_ps2_clk
        );

    u_rotary_encoder: RotaryEnc_wrap
        port map (
            ROT_A => i_rot_a,
            ROT_B => i_rot_b,
            Clk   => s_clk_125mhz,
            RotL  => s_rot_l,
            RotR  => s_rot_r
        );

    process(s_clk_125mhz)
    begin
        if rising_edge(s_clk_125mhz) then
            if s_sys_reset_n = '0' then
                s_brush_size <= 1;
                o_led_brush_en <= '0';
            else
                o_led_brush_en <= i_sw_brush_en;

                if i_sw_brush_en = '1' then
                    if s_rot_l = '1' and s_brush_size > 1 then
                        s_brush_size <= s_brush_size - 1;
                    elsif s_rot_r = '1' and s_brush_size < 480 then
                        s_brush_size <= s_brush_size + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(s_clk_125mhz)
    begin
        if rising_edge(s_clk_125mhz) then
            if s_sys_reset_n = '0' then
                s_draw_x_offset <= 0;
                s_draw_y_offset <= 0;
                s_draw_we <= '0';
            else
                if s_mouse_init_ok = '1' and (s_mouse_status(0) = '1' or s_mouse_status(1) = '1') then
                    s_draw_we <= '1';

                    if s_draw_x_offset < s_brush_size - 1 then
                        s_draw_x_offset <= s_draw_x_offset + 1;
                    else
                        s_draw_x_offset <= 0;
                        if s_draw_y_offset < s_brush_size - 1 then
                            s_draw_y_offset <= s_draw_y_offset + 1;
                        else
                            s_draw_y_offset <= 0;
                        end if;
                    end if;
                else
                    s_draw_we <= '0';
                    s_draw_x_offset <= 0;
                    s_draw_y_offset <= 0;
                end if;
            end if;
        end if;
    end process;

    process(s_clk_125mhz)
        variable dx : integer;
        variable dy : integer;
        variable new_x : integer;
        variable new_y : integer;
    begin
        if rising_edge(s_clk_125mhz) then
            if s_sys_reset_n = '0' then
                s_cursor_x <= to_unsigned(320, s_cursor_x'length);
                s_cursor_y <= to_unsigned(240, s_cursor_y'length);
                s_mouse_data_rdy_last <= '0';
            else
                if s_mouse_init_ok = '1' and s_mouse_data_rdy = '1' and s_mouse_data_rdy_last = '0' then
                    dx := to_integer(signed(s_mouse_dx));
                    dy := to_integer(signed(s_mouse_dy));

                    new_x := to_integer(s_cursor_x) + dx;
                    new_y := to_integer(s_cursor_y) - dy;

                    if new_x < 0 then
                        new_x := 0;
                    elsif new_x > 639 then
                        new_x := 639;
                    end if;

                    if new_y < 0 then
                        new_y := 0;
                    elsif new_y > 479 then
                        new_y := 479;
                    end if;

                    s_cursor_x <= to_unsigned(new_x, s_cursor_x'length);
                    s_cursor_y <= to_unsigned(new_y, s_cursor_y'length);
                end if;
                s_mouse_data_rdy_last <= s_mouse_data_rdy;
            end if;
        end if;
    end process;
    
    u_clk_wiz_0: clk_wiz_0
        port map ( 
            -- Clock out ports  
            clk_25MHz => s_clk_25mhz,
            clk_125MHz => s_clk_125mhz,
            clk_100MHz => s_clk_100mhz,
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
            Clk      => s_clk_125mhz,
            RstN     => s_sys_reset_n,
            We       => s_init_in,
            Addr     => s_init_addr,
            Data     => s_init_data,
            InitDone => s_init_done
        );

    s_paint_addr_x <= to_integer(s_cursor_x) - (s_brush_size / 2) + s_draw_x_offset;
    s_paint_addr_y <= to_integer(s_cursor_y) - (s_brush_size / 2) + s_draw_y_offset;

    s_safe_we <= s_draw_we when (s_paint_addr_x >= 0 and s_paint_addr_x <= 639 and
                                 s_paint_addr_y >= 0 and s_paint_addr_y <= 479) else '0';

    process(s_paint_addr_x, s_paint_addr_y)
    begin
        if s_paint_addr_x >= 0 and s_paint_addr_x <= 639 and
           s_paint_addr_y >= 0 and s_paint_addr_y <= 479 then
            s_write_addr_calc <= std_logic_vector(to_unsigned(s_paint_addr_y * 640 + s_paint_addr_x, 19));
        else
            s_write_addr_calc <= (others => '0');
        end if;
    end process;

    s_fb_ina(0) <= s_init_in when s_init_done = '0' else s_safe_we;

    s_write_addr <= s_init_addr when s_init_done = '0' else s_write_addr_calc;

    s_write_data <= s_init_data when s_init_done = '0' else
                    "11111111" when s_mouse_status(1) = '1' else
                    "11100000";
        
    process(s_clk_25mhz)
    begin
        if rising_edge(s_clk_25mhz) then
            if s_sys_reset_n = '0' then
                s_video_de_d1 <= '0';     s_video_de_d2 <= '0';
                s_video_hsync_d1 <= '0';  s_video_hsync_d2 <= '0';
                s_video_vsync_d1 <= '0';  s_video_vsync_d2 <= '0';
                s_pixel_x_d1 <= (others => '0'); s_pixel_x_d2 <= (others => '0');
                s_pixel_y_d1 <= (others => '0'); s_pixel_y_d2 <= (others => '0');
            else
                s_video_de_d1 <= s_video_de;       s_video_de_d2 <= s_video_de_d1;
                s_video_hsync_d1 <= s_video_hsync; s_video_hsync_d2 <= s_video_hsync_d1;
                s_video_vsync_d1 <= s_video_vsync; s_video_vsync_d2 <= s_video_vsync_d1;
                s_pixel_x_d1 <= s_pixel_x;         s_pixel_x_d2 <= s_pixel_x_d1;
                s_pixel_y_d1 <= s_pixel_y;         s_pixel_y_d2 <= s_pixel_y_d1;
            end if;
        end if;
    end process;
    
    process(s_pixel_x_d2, s_pixel_y_d2, s_cursor_x, s_cursor_y, s_read_data, s_brush_size)
        variable px, py, cx, cy : integer;
        variable x_min, x_max, y_min, y_max : integer;
        variable r_bg, g_bg, b_bg : STD_LOGIC_VECTOR(7 downto 0);
    begin
        r_bg := s_read_data(7 downto 5) & s_read_data(7 downto 5) & s_read_data(7 downto 6);
        g_bg := s_read_data(4 downto 2) & s_read_data(4 downto 2) & s_read_data(4 downto 3);
        b_bg := s_read_data(1 downto 0) & s_read_data(1 downto 0) & s_read_data(1 downto 0) & s_read_data(1 downto 0);

        px := to_integer(unsigned(s_pixel_x_d2));
        py := to_integer(unsigned(s_pixel_y_d2));
        cx := to_integer(s_cursor_x);
        cy := to_integer(s_cursor_y);

        x_min := cx - (s_brush_size / 2);
        x_max := x_min + s_brush_size;

        y_min := cy - (s_brush_size / 2);
        y_max := y_min + s_brush_size;

        if (px >= x_min and px < x_max) and (py >= y_min and py < y_max) then
            s_color_r <= (others => '0');
            s_color_g <= (others => '0');
            s_color_b <= (others => '0');
        else
            s_color_r <= r_bg;
            s_color_g <= g_bg;
            s_color_b <= b_bg;
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
        port map (
            clka => s_clk_125mhz,
            ena => s_fb_ena,
            wea => s_fb_ina,
            addra => s_write_addr,
            dina => s_write_data,
            douta => open,
            clkb => s_clk_25mhz,
            enb => s_fb_enb,
            web => s_fb_inb,
            addrb => s_read_addr,
            dinb => s_fb_dinb,
            doutb => s_read_data
      );    

end structural;