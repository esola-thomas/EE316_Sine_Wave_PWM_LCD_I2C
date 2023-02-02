library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clk_en is 
	port(
		clk 	: in std_logic;
		en		: out std_logic := '0');
	generic(
		delay : integer := 49999999);
end clk_en;

architecture arch of clk_en

signal count : integer := 0;

begin

	clk_enabler : process (clk) begin
		if (count = delay) then
			en = '1';
			count = 0;
		else 
			en = '0';
			count = count + 1;
		end if
	end process clk_enabler;
end arch;