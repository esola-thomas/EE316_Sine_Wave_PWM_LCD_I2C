library IEEE;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity counter is
	generic(
		count_size 			: integer := 8; -- Output bus size
		max_count			: unsigned (31 downto 0) := X"000000FF";
		count_step_size 	: integer := 1;
		count_delay			: integer := 49999999 -- Clk cycles delay until next count
	);
	port(
		clk 		: in std_logic; 
		ireset		: in std_logic;
		direction 	: in std_logic; -- 1 Counts up, 0 counts down
		carry_in	: in std_logic;
		carry_out	: out std_logic := '0'; -- Works for both counting up and conting down
		count_out 	: out std_logic_vector (count_size-1 downto 0) := (others => '0')
	);
end counter;

architecture arch of counter is

	signal new_carry_in : std_logic := '0'; -- When carry data was read
	signal en : std_logic := '0';
	signal clk_en_count : integer := 0;
	signal count_int_reg: unsigned (31 downto 0) := (others => '0');

begin

	clk_enabler : process (clk) begin
		if (rising_edge(clk)) then
			if (clk_en_count = count_delay) then
				en <= '1';
				clk_en_count <= 0;
			else 
				en <= '0';
				clk_en_count <= clk_en_count + 1;
			end if;
		end if;
	end process clk_enabler;
	
	main_count : process (clk, en) begin
		if (ireset = '1') then -- Possible implementation, add if statement to reset to max or min value depending on the direction signal
			count_int_reg <= (others => '0');
			carry_out <= '0';
		elsif (carry_in = '1' and new_carry_in = '0') then
			new_carry_in <= '1';
			if (direction = '1') then
				count_int_reg <= count_int_reg + 1;
			elsif (direction = '0') then
				count_int_reg <= count_int_reg - 1;
			end if;
		elsif (rising_edge(clk) and en = '1') then
			new_carry_in <= '0';
			if (direction = '1') then -- Count up
				if (count_int_reg + unsigned(count_step_size, count_size) >= max_count) then
					count_int_reg <= unsigned(count_int_reg, count_size) + unsigned(count_step_size, count_size) - max_count;
					carry_out <= '1';
				elsif (count_int_reg + unsigned(count_step_size, count_size) <= max_count) then
					count_int_reg <= count_int_reg + unsigned(count_step_size, count_size);
					carry_out <= '0';
				end if;	

			elsif (direction = '0') then -- Count down
				if (count_int_reg - unsigned(count_step_size, count_size) < 0) then 
					count_int_reg <= count_int_reg - unsigned(count_step_size, count_size) + max_count;
					carry_out <= '1';
				elsif (count_int_reg - unsigned(count_step_size, count_size) >= 0) then
					count_int_reg <= count_int_reg - unsigned(count_step_size, count_size);
					carry_out <= '0';
				end if;
			end if;
		end if;
	end process main_count;

	count_out <= std_logic_vector(count_int_reg);
end arch;