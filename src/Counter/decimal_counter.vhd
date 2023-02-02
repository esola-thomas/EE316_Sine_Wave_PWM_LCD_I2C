library IEEE;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity decimal_counter is

	port(
		clk 	: in std_logic; 
		ireset	: in std_logic -- Active high
	);
	generic(
		count_rate_whole 	: integer := 0; 	-- Whole part of delay 
		count_rate_decimal 	: integer := 5;		-- Delay part of delay
		count_max_whole 	: integer := 10;
		count_max_decimal	: integer := 5;
	);
end decimal_counter;

-- signal input_1   : integer;
-- signal output_1a : std_logic_vector(3 downto 0);
-- signal output_1b : std_logic_vector(3 downto 0);
   
-- -- This line demonstrates how to convert positive integers
-- output_1a <= std_logic_vector(to_unsigned(input_1, output_1a'length));
 
-- -- This line demonstrates how to convert positive or negative integers
-- output_1b <= std_logic_vector(to_signed(input_1, output_1b'length));

architecture arch of decimal_counter is 

	signal int : integer := 0;
	signal deci: integer := 0;
	signal decimal_count : std_logic_vector(19 downto 0) := (others => '0'); -- Whole part is (19 down to 10) / Decimal part is (9 down to 0)
	
	signal clk_en_signal : std_logic := '0';
	component clk_en is
		generic(
			delay : integer := 49999999);
		port(
			clk 	: in std_logic;
			en		: out std_logic := '0');
	end component;

begin

	enabler : clk_en
		generic map (delay => 49999999);
		port map (clk => clk, en => clk_en_signal);

	count : process(clk, clk_en_signal, ireset) is begin

		if (ireset = '1') then
			int = 0;
			deco = 0;
		elsif(rising_edge(clk_en_signal)) then
			-- Counted up to the limit
			if (int = count_max_whole and deci = count_max_decimal) then
				-- Reset counter to 0
			elsif (int < count_rate_whole) then 
				-- Add to decimal part if 

				-- Verify not over limit

				-- Add to integer

				-- Verify not over limit
			end if;
		end if;
	end process count;

end arch;