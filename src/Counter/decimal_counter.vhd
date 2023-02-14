library IEEE;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity decimal_counter is
	generic(
        max_int_value : unsigned(31 downto 0) := (others => '1');
        max_deci_value: unsigned(31 downto 0) := (others => '1');
		count_step_integer 	: integer := 1; 	-- Whole part of delay 
		count_step_decimal 	: integer := 25;    -- Delay part of delay (.25) <= Based on size
		count_max_integer 	: integer := 10;
		count_max_decimal	: integer := 100;
        bus_size_integer    : integer := 32;
        bus_size_decimal    : integer := 32;
        count_delay         : integer := 3      -- Delay in clock cycles (delay do count up/down)
	);
    port(
		clk 	    : in std_logic; 
		ireset	    : in std_logic; -- Active high
        direction   : in std_logic;
        halt        : in std_logic;
        i,d         : out integer;
        MSB_8       : out std_logic_vector (19 downto 0) -- <= This is just for this project, as well as lines 63 and 64
	);
end decimal_counter;

architecture arch of decimal_counter is 

	component counter
    generic(
        count_size 			: integer; -- Output bus size
        max_count			: integer;
        count_step_size 	: integer;
        count_delay			: integer
    );
    port(
        clk 		: in std_logic; 
        ireset		: in std_logic;
        direction 	: in std_logic; -- 1 Counts up, 0 counts down
        halt		: in std_logic;
        carry_in	: in std_logic;
        carry_out	: out std_logic; -- Works for both counting up and conting down
        count_out 	: out std_logic_vector (count_size-1 downto 0)
    );
end component;

    -- TEST (60 Hz) 
    -- constant max_int_value : unsigned(31 downto 0) := "01111111011111111111111010111110";
    -- constant max_deci_value : unsigned(31 downto 0) := "00000000000000110011001001001100";

    signal en : std_logic := '0'; -- enable signal from clock enabler

    -- Signals for integer counter (int)
    signal int_carry_out   : std_logic := '0';
    signal int_count_out   : std_logic_vector (bus_size_integer-1 downto 0);
    signal int_count_reset : std_logic;
    -- Signals for decimal counter (deci)
    signal deci_carry_out   : std_logic := '0';
    signal deci_count_out   : std_logic_vector (bus_size_decimal-1 downto 0);
    signal deci_count_reset : std_logic;

    signal i_reg, d_reg : integer := 0;

begin

    int_count_reset <=  '1' when ireset = '1' else
                        '1' when (i_reg = to_integer(max_int_value) and d_reg = to_integer(max_deci_value)) else
                        '0';

    deci_count_reset <= '1' when ireset = '1' else
                        '1' when (i_reg = to_integer(max_int_value) and d_reg = to_integer(max_deci_value)) else
                        '0';

    int_counter : counter generic map (count_size => bus_size_integer, max_count => count_max_integer, count_step_size => count_step_integer, count_delay => count_delay)
    port map (clk => clk, ireset => int_count_reset, direction => direction, halt => halt, carry_in => deci_carry_out,count_out => int_count_out, carry_out => int_carry_out);

    deci_counter : counter generic map (count_size => bus_size_decimal, max_count => count_max_decimal, count_step_size => count_step_decimal, count_delay => count_delay)
    port map (clk => clk, ireset => deci_count_reset, direction => direction, halt => halt, carry_in => '0',count_out => deci_count_out, carry_out => deci_carry_out);

    i_reg <= to_integer(unsigned(int_count_out));
    d_reg <= to_integer(unsigned(deci_count_out));

    i <= i_reg;
    d <= d_reg;

    MSB_8 (7 downto 0) <= int_count_out (bus_size_integer-2 downto bus_size_integer-9);     -- <= Just for this project
    MSB_8 (19 downto 8) <= (others => '0');                 -- <= Just for this project
end arch;