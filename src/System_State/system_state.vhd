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
	direction	: out std_logic;
	o_global_reset : out std_logic;
	o_state_message : out std_logic_vector (127 downto 0);
	init_signal     : out std_logic;
	SRAM_R_W		: out std_logic;
	SRMA_clk_en		: out std_logic;
	rst_dec_count	: out std_logic := '0'
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

type init_sequence is (
	init_reset,
	load_SRAM,
	init_complete
);

signal current_state : system_state := init;
signal init_state : init_sequence := init_reset;

signal en : std_logic := '0';
signal halt_clk_en 	: std_logic := '0';
signal init_count	: integer := 0;
signal clk_en_count : integer := 0;
signal clk_en_delay : integer := 49999999;

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
		else 
			case current_state is
				when init =>
					if (init_state = init_complete) then
						current_state <= Test_Mode;
					else 
						current_state <= init;
					end if;
				when Test_Mode =>
					if (sw_mode_release = '1') then
						current_state <= Pause_Mode;
					end if;
				when Pause_Mode => 
					if (sw_mode_release = '1') then
						current_state <= Test_Mode;
					end if;
				when PWM => 
					PWM_en <= '1'; 
			end case;			
		end if;
	end process select_state;


	system_state_process : process (clk, current_state) begin
		if (rising_edge(clk)) then  
			if (current_state = init) then
				case init_state is 
					when init_reset => -- Send global reset signal for 10 clk cycles
						if (init_count < 10) then 
							init_count <= init_count + 1;
							o_global_reset <= '1';
							halt_clk_en <= '1'; -- Halt clk_en (this resets its counter)
						else
							o_global_reset <= '0';
							init_count <= 0; -- After reseting all the system start clk_en
							init_state <= load_SRAM;
						end if;
					when load_SRAM => -- After reseting all system load SRAM (256 values)
						o_global_reset <= '0';
						SRAM_R_W <= '0'; -- Set SRAM to Write mode
						if (init_count <= 255 and en = '1') then
							init_count <= init_count + 1;
							SRMA_clk_en <= '1';
						elsif (init_count > 255) then -- 255 Values loaded to SRAM 
							halt_clk_en <= '1'; -- resets clk_en counter
							init_state <= init_complete;  
							SRMA_clk_en <= '0';
						end if;
					when init_complete =>
						o_global_reset <= '0';
						init_state <= init_complete; 
				end case;
				clk_en_delay <= 49999999; -- Load Values to SRAM at a faster Rate
				state_message <= "Init SRAM...    ";
			elsif (current_state = global_reset) then
				init_state <= init_reset;
				o_global_reset <= '1';
				halt_clk_en <= '1';
				state_message <= "Global Reset    ";
			elsif (current_state = Test_Mode) then
				SRAM_R_W <= '1'; -- Set SRAM controller to Read Mode
				SRMA_clk_en <= en;
				o_global_reset <= '0';
				halt_clk_en <= '0';
				clk_en_delay <= 49999999; -- Set counter speed to 1
				state_message <= "~~ Test  Mode ~~";
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
		if (clk_en_count = clk_en_delay and halt_clk_en = '0') then
			en <= '1';
			clk_en_count <= 0;
		elsif (clk_en_count < clk_en_delay and halt_clk_en = '0') then
			en <= '0';
			clk_en_count <= clk_en_count + 1;
		elsif (iReset = '1' or halt_clk_en = '1') then
			en <= '0';
			clk_en_count <= 0;
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
	-- o_state_message <= X"41414141414141414141414141414141";

	direction <= '1';
	init_signal <= '1' when (current_state = init) else '0';
end;