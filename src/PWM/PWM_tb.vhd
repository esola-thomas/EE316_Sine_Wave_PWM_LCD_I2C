library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_tb is
end entity;

architecture behavior of PWM_tb is

-- Component Declaration
component PWM_File is
generic( N: integer := 16);
port(
clk : in std_logic;
reset : in std_logic;
Max_Number : in std_logic_vector((N - 1) downto 0);
sram_data : in std_logic_vector((N - 1) downto 0);
enable : in std_logic;
PWM_Output : out std_logic
--MaxTick : out std_logic
);
end component;

-- Input Signals
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal Max_Number : std_logic_vector(15 downto 0) := x"7FFF"; --32767
signal sram_data : std_logic_vector(15 downto 0) := x"61A8"; --25000
signal enable : std_logic := '1';

-- Output Signals
signal PWM_Output : std_logic;
--signal MaxTick : std_logic;

begin

-- Component Instantiation
UUT : PWM_File
generic map(16)
port map(
clk => clk,
reset => reset,
Max_Number => Max_Number,
sram_data => sram_data,
enable => enable,
PWM_Output => PWM_Output
);

-- Simulation Process
clk <= not clk after 10ns;
sim_process : process
begin

-- Reset Assertion
reset <= '1';
wait for 5 ns;
reset <= '0';

-- Stimulus Generation
wait for 50 ns;

-- Resetting
reset <= '1';
wait for 5 ns;
reset <= '0';
wait;
end process;

end architecture;