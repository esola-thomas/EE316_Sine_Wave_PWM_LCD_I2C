library IEEE;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity decimal_counter_tb is 
end decimal_counter_tb;

architecture tb of decimal_counter_tb is 

component decimal_counter
    generic(
		count_step_integer 	: integer := 5153; 	-- Whole part of delay 
		count_step_decimal 	: integer := 9607552;    -- Delay part of delay (.25) <= Based on size
		count_max_integer 	: integer := 15728640;
		count_max_decimal	: integer := 10000000;
        bus_size_integer    : integer := 24;
        bus_size_decimal    : integer := 24;
        count_delay         : integer := 5      -- Delay in clock cycles (delay do count up/down)
	);
    port(
		clk 	    : in std_logic; 
		ireset	    : in std_logic; -- Active high
        direction   : in std_logic;
        i,d         : out integer
	);
end component;

    signal clk, ireset : std_logic := '0';
    signal direction : std_logic := '1';
    signal i, d : integer := 0;
begin 

    DUT : decimal_counter port map (clk => clk, ireset => ireset, direction => direction, i => i, d => d);

    clk <= not clk after 20 ns;
    
    testbench : process begin

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;
        wait;
    end process testbench;
end tb;