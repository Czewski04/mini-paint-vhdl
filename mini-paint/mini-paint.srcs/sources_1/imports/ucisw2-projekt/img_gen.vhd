library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generator obrazu startowego.
-- Po resecie jednokrotnie wypełnia całą pamięć ramki kolorem białym.
entity img_gen is
    Port (
           Clk  : in STD_LOGIC;
           RstN : in STD_LOGIC;
           We   : out STD_LOGIC;
           Addr : out STD_LOGIC_VECTOR (18 downto 0);
           Data : out STD_LOGIC_VECTOR (7 downto 0);
           InitDone : out STD_LOGIC
		);
end img_gen;


architecture Behavioral of img_gen is

    -- Parametry przestrzeni obrazu (640x480 pikseli).
    constant MODE_WIDTH  : integer := 640;
    constant MODE_HEIGHT : integer := 480;
    -- Liczniki współrzędnych piksela podczas inicjalizacji pamięci.
    signal x_cnt : unsigned(9 downto 0) := (others => '0');
    signal y_cnt : unsigned(9 downto 0) := (others => '0');
    -- Flaga zakończenia inicjalizacji całej ramki.
    signal done  : std_logic := '0';

    -- Liniowy adres aktualnie inicjalizowanego piksela.
    signal addr_calc : unsigned(18 downto 0);

begin

    addr_calc <= resize(y_cnt * MODE_WIDTH + x_cnt, 19);
    Addr <= std_logic_vector(addr_calc);
    
    -- Tło początkowe: białe (RGB332 = 0xFF).
    Data <= x"FF";

    We <= not done;
    InitDone <= done;

    -- Sekwencyjne przejście po wszystkich pikselach:
    -- najpierw rośnie X, a po dojściu do końca linii inkrementowane jest Y.
    process(Clk)
    begin
        if rising_edge(Clk) then
            if RstN = '0' then
                x_cnt <= (others => '0');
                y_cnt <= (others => '0');
                done <= '0';
            elsif done = '0' then
                if x_cnt = to_unsigned(MODE_WIDTH - 1, x_cnt'length) then
                    x_cnt <= (others => '0');
                    if y_cnt = to_unsigned(MODE_HEIGHT - 1, y_cnt'length) then
                        done <= '1';
                    else
                        y_cnt <= y_cnt + 1;
                    end if;
                else
                    x_cnt <= x_cnt + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;