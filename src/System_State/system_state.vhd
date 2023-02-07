library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity system_state is
port(
	clk 	: in std_logic;
	sw_mode : in std_logic; -- Active low
	iReset 	: in std_logic;
	PWM_en 		: out std_logic;
	clk_en 		: out std_logic;
	o_global_reset : out std_logic;
	o_state_message : out std_logic_vector (127 downto 0) 
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

signal en : std_logic := '0';
signal halt_clk_en : std_logic := '0';
signal count : integer := 0;
signal delay : integer := 49999999;

signal sw_mode_press, sw_mode_release : std_logic := '0';

signal state_message : string(1 to 16);

begin

	sw_mode_rising_edge : process (clk) begin
		if (rising_edge(clk)) then 
			if (sw_mode = '1' and sw_mode_press = '0') then
				sw_mode_release <= '1';
			else 
				sw_mode_release <= '0';
			end if;
			sw_mode_press <= sw_mode;
		end if;
	end process sw_mode_rising_edge; 

	select_state : process (clk, iReset) begin
		if (iReset = '1') then
			current_state <= global_reset;
		elsif (current_state = global_reset and iReset = '0') then
			current_state <= init;
		elsif (current_state = init) then
			-- Some sort of counter to keep track of SRAM init from ROM
			current_state <= Test_Mode;
		elsif (current_state = global_reset) then 
			if (iReset = '1') then 
				current_state <= init;
			else 
				current_state <= global_reset;
			end if;
		elsif (current_state = Test_Mode) then
			if (sw_mode_release = '1') then
				current_state <= Pause_Mode;
			end if;
		elsif (current_state = Pause_Mode) then
			if (sw_mode_release = '1') then
				current_state <= Test_Mode;
			end if;
		elsif (current_state = PWM) then
			PWM_en <= '1'; 
		end if;
	end process select_state;


	system_state_process : process (clk, current_state) begin
		if (rising_edge(clk)) then  
			if (current_state = init) then
				o_global_reset <= '0';
				halt_clk_en <= '0';
				state_message <= "Init SRAM...    ";
			elsif (current_state = global_reset) then
			o_global_reset <= '1';
				halt_clk_en <= '1';
				delay <= 49999999; -- Change this one after testing
				state_message <= "Global Reset    ";
			elsif (current_state = Test_Mode) then
				o_global_reset <= '0';
				halt_clk_en <= '0';
				delay <= 49999999;
				state_message <= "Test Mode       ";
			elsif (current_state = Pause_Mode) then
				o_global_reset <= '0';
				halt_clk_en <= '1';
				state_message <= "Paused Mode     ";
			elsif (current_state = PWM) then
				o_global_reset <= '0';
				halt_clk_en <= '0';
				state_message <= "PWM Generation  ";
			end if;
		end if;
	end process system_state_process;

	clk_enabler : process (clk) begin
		if (count = delay and halt_clk_en = '0') then
			en <= '1';
			count <= 0;
		elsif (count < delay and halt_clk_en = '0') then
			en <= '0';
			count <= count + 1;
		elsif (iReset = '1') then
			en <= '0';
			count <= 0;
		end if;
	end process clk_enabler;
	clk_en <= en;
	o_state_message (127 downto 120) <= std_logic_vector(to_unsigned(character'pos(state_message(1)), 8));
	o_state_message (119 downto 112) <= std_logic_vector(to_unsigned(character'pos(state_message(2)), 8));
	o_state_message (111 downto 104) <= std_logic_vector(to_unsigned(character'pos(state_message(3)), 8));
	o_state_message (103 downto 96) <= std_logic_vector(to_unsigned(character'pos(state_message(4)), 8));
	o_state_message (95 downto 88) <= std_logic_vector(to_unsigned(character'pos(state_message(5)), 8));
	o_state_message (87 downto 80) <= std_logic_vector(to_unsigned(character'pos(state_message(6)), 8));
	o_state_message (79 downto 72) <= std_logic_vector(to_unsigned(character'pos(state_message(7)), 8));
	o_state_message (71 downto 64) <= std_logic_vector(to_unsigned(character'pos(state_message(8)), 8));
	o_state_message (63 downto 56) <= std_logic_vector(to_unsigned(character'pos(state_message(9)), 8));
	o_state_message (55 downto 48) <= std_logic_vector(to_unsigned(character'pos(state_message(10)), 8));
	o_state_message (47 downto 40) <= std_logic_vector(to_unsigned(character'pos(state_message(11)), 8));
	o_state_message (39 downto 32) <= std_logic_vector(to_unsigned(character'pos(state_message(12)), 8));
	o_state_message (31 downto 24) <= std_logic_vector(to_unsigned(character'pos(state_message(13)), 8));
	o_state_message (23 downto 16) <= std_logic_vector(to_unsigned(character'pos(state_message(14)), 8));
	o_state_message (15 downto 8) <= std_logic_vector(to_unsigned(character'pos(state_message(15)), 8));
	o_state_message (7 downto 0) <= std_logic_vector(to_unsigned(character'pos(state_message(16)), 8));
end;