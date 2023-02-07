library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter_tb is 
end counter_tb;

architecture arch_tb of counter_tb is

constant count_out_size : integer := 8;
component counter
    generic(
        count_size 			: integer := 8; -- Output bus size
        max_count			: integer := 15;
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
end component;

    signal clk, ireset, carry_out, carry_in : std_logic := '0';
    signal direction                        : std_logic := '1';
    signal count_out                        : std_logic_vector (count_out_size-1 downto 0);
begin

    -- c : counter 
    -- generic map (count_size => 4, max_count => 5, count_step_size => 1 count_delay => 5); 
    -- port map (clk => clk, ireset => ireset, direction => direction, count_out => count_out, carry_out => carry_out);

    c : counter generic map (count_size => count_out_size, max_count => 10, count_step_size => 1, count_delay => 2)
        port map (clk => clk, ireset => ireset, direction => direction, carry_in => carry_in, count_out => count_out, carry_out => carry_out);

    clk <= not clk after 10 ns;

    testbench : process begin 
        -- 0
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 1
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 2
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 3
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 4
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 5
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 0
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 1
        ireset      <= '0';
        direction   <= '1';
        wait for 100 ns;

        -- 0
        ireset      <= '0';
        direction   <= '0';
        wait for 100 ns;

        -- 5
        ireset      <= '0';
        direction   <= '0';
        wait for 100 ns;

        -- 5
        ireset      <= '0';
        direction   <= '0';
        wait for 100 ns;

        -- 5
        ireset      <= '0';
        direction   <= '0';
        wait for 100 ns;

        wait;
    end process testbench;
end arch_tb;