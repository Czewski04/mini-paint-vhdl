library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Pakiet funkcji pomocniczych dla modułów mini-paint.
-- Ujednolica obliczanie adresu piksela oraz konwersje kolorów RGB332 <-> RGB888.
package paint_utils_pkg is
    -- Zwraca 19-bitowy liniowy adres piksela w buforze 640x480:
    -- addr = y * 640 + x.
    function framebuffer_addr(x : integer; y : integer) return std_logic_vector;

    -- Pakuje składowe 8-bitowe RGB do formatu RGB332:
    -- [7:5] = R[7:5], [4:2] = G[7:5], [1:0] = B[7:6].
    function pack_rgb332(
        r8 : unsigned(7 downto 0);
        g8 : unsigned(7 downto 0);
        b8 : unsigned(7 downto 0)
    ) return std_logic_vector;

    -- Rozpakowuje kanały RGB332 do 8 bitów przez replikację bitów
    -- (aproksymacja jasności kanałów bez mnożenia).
    function rgb332_to_r(pixel : std_logic_vector(7 downto 0)) return std_logic_vector;
    function rgb332_to_g(pixel : std_logic_vector(7 downto 0)) return std_logic_vector;
    function rgb332_to_b(pixel : std_logic_vector(7 downto 0)) return std_logic_vector;
end package;

package body paint_utils_pkg is
    -- Implementacja liniowego adresowania pamięci obrazu.
    function framebuffer_addr(x : integer; y : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned((y * 640) + x, 19));
    end function;

    -- Implementacja konwersji RGB888 -> RGB332.
    function pack_rgb332(
        r8 : unsigned(7 downto 0);
        g8 : unsigned(7 downto 0);
        b8 : unsigned(7 downto 0)
    ) return std_logic_vector is
    begin
        return std_logic_vector(r8(7 downto 5)) &
               std_logic_vector(g8(7 downto 5)) &
               std_logic_vector(b8(7 downto 6));
    end function;

    -- Implementacja konwersji kanału R z RGB332 do 8 bitów.
    function rgb332_to_r(pixel : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return pixel(7 downto 5) & pixel(7 downto 5) & pixel(7 downto 6);
    end function;

    -- Implementacja konwersji kanału G z RGB332 do 8 bitów.
    function rgb332_to_g(pixel : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return pixel(4 downto 2) & pixel(4 downto 2) & pixel(4 downto 3);
    end function;

    -- Implementacja konwersji kanału B z RGB332 do 8 bitów.
    function rgb332_to_b(pixel : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return pixel(1 downto 0) & pixel(1 downto 0) & pixel(1 downto 0) & pixel(1 downto 0);
    end function;
end package body;
