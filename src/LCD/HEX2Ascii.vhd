library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HEX2Ascii is
    port (
        HEX  : in std_logic_vector(3 downto 0);
        ASCII  : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of HEX2Ascii is
begin

    process (HEX) is
    begin
        case HEX is      
        when "0000" => ASCII <= X"30"; -- 0
        when "0001" => ASCII <= X"31"; -- 1
        when "0010" => ASCII <= X"32"; -- 2
        when "0011" => ASCII <= X"33"; -- 3
        when "0100" => ASCII <= X"34"; -- 4
        when "0101" => ASCII <= X"35"; -- 5
        when "0110" => ASCII <= X"36"; -- 6
        when "0111" => ASCII <= X"37"; -- 7
        when "1000" => ASCII <= X"38"; -- 8
        when "1001" => ASCII <= X"39"; -- 9
        when "1010" => ASCII <= X"41"; -- A
        when "1011" => ASCII <= X"42"; -- B
        when "1100" => ASCII <= X"43"; -- C
        when "1101" => ASCII <= X"44"; -- D
        when "1110" => ASCII <= X"45"; -- E
        when "1111" => ASCII <= X"46"; -- F
	    when OTHERS => ASCII <= X"00"; --undefined state
        end case;
    end process;
end architecture; 