library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity system_state_tb is 
end system_state_tb;

architecture tb of system_state_tb is 

signal clk, sw_mode, iReset, PWM_en, clk_en, direction, o_global_reset, init_signal : std_logic := '0';
signal o_state_message : std_logic_vector (127 downto 0) := (others => '0');
component system_state 
port(
	clk 	: in std_logic;
	sw_mode : in std_logic; -- Active low
	iReset 	: in std_logic;
	PWM_en 		: out std_logic;
	clk_en 		: out std_logic;
	direction	: out std_logic;
	o_global_reset : out std_logic;
	o_state_message : out std_logic_vector (127 downto 0);
    init_signal     : out std_logic;
	);
end component;

begin

    DUT : system_state port map(
        clk => clk, 
        sw_mode => sw_mode, 
        iReset => iReset,
        PWM_en => PWM_en,
        clk_en => clk_en,
        direction => direction,
        o_global_reset => o_global_reset,
        o_state_message => o_state_message
        init_signal => init_signal;
        );

    clk <= not clk after 20 ns;
    
    testbench : process begin
    sw_mode <= '0';
    iReset  <= '0';

    wait for 100 ns;
    wait;
    end process testbench;
end tb;