library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity system_state is
port(
	clk 	: in std_logic;
	iReset 	: in std_logic
	);
end system_state;

architecture arch of system_state is 

type system_state is (
	init,
	global_reset,
	Test_Mode,
	Pause_Mode,
	PWM
);

signal current_state : system_state := init;

begin

end;