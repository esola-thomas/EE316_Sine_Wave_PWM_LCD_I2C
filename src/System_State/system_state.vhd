library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity system_state is
port(
	clk 	: in std_logic;
	sw_mode : in std_logic; -- Active low
	PWM_tog	: in std_logic;
	iReset 	: in std_logic;
	PWM_en 		: out std_logic;
	clk_en 		: out std_logic;
	direction	: out std_logic;
	o_global_reset 	: out std_logic;
	void			: out std_logic_vector (1 downto 0);
	init_signal     : out std_logic;
	SRAM_R_W		: out std_logic;
	SRMA_clk_en		: out std_logic;
	rst_dec_count	: out std_logic := '0';
	LCD_line1		: out std_logic_vector (127 downto 0);
	LCD_line2		: out std_logic_vector (127 downto 0)
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

-- Boot Reset delay signal
signal boot_reset	: std_logic := '1';
signal reset_delay	: std_logic_vector(7 downto 0) := (others => '0');

-- LCD data buffer
signal state_message : string(1 to 16);
signal state_message2 : string(1 to 16);

-- mode btn debouncer / endge detector registers
signal mode_sw_signal : std_logic := '0';
signal mode_btn_state : std_logic_vector (1 downto 0) := "00"; 
signal btn_debounce_count : integer := 0;
constant btn_debounce_delay : integer := 49999;

signal pwm_or_pause : std_logic := '0';
-- For PWM 
signal mode_sw_signal2 : std_logic := '0';
signal mode_btn_state2 : std_logic_vector (1 downto 0) := "00"; 

-- This might nee to be removed ~~~
signal toggle_state, toggle_state_reg : std_logic := '0';

begin

	system_start : process (clk)
	begin
		if (rising_edge(clk)) then 
			if (reset_delay < X"FF") then
				boot_reset <= '1';	
				reset_delay <= reset_delay + 1;
			else
				boot_reset <= '0';
			end if;
		end if;
	end process system_start;

	system_State_machine : process (clk, iReset) begin
		if (rising_edge (clk)) then
			if (iReset = '1' or boot_reset = '1') then
				current_state <= global_reset;
			else 
				case current_state is
					when init =>
					
						if (init_state = init_complete) then
							current_state <= Test_Mode;
						else 
							current_state <= init;
						end if;
						
					when Test_Mode =>
						if (mode_sw_signal = '1' and pwm_or_pause = '1') then
							current_state <= Pause_Mode;
						elsif (mode_sw_signal = '1' and pwm_or_pause = '0') then
							current_state <= PWM;
						elsif (mode_sw_signal2 = '1') then
							current_state <= Test_Mode;
						end if;
					
					when Pause_Mode => 
						if (mode_sw_signal = '0') then
							current_state <= Test_Mode;
						else
							current_state <= Pause_Mode;
						end if;

					when PWM => 
						if (mode_sw_signal = '0') then
							current_state <= Test_Mode;
						else
							current_state <= PWM;
						end if; 

					when global_reset =>
						current_state <= init;
				end case;			
			end if; -- current state when not reset

			case current_state is
				when init =>
					state_message <= "Init SRAM...    ";
					clk_en_delay <= 100000; -- Load Values to SRAM at a faster Rate
					case init_state is 
						when init_reset => -- Send global reset signal for 10 clk cycles
							if (init_count < 49999999) then 
								state_message2 <= "init_reset~~~~~~";
								init_count <= init_count + 1;
								o_global_reset <= '1';
								halt_clk_en <= '1'; -- Halt clk_en (this resets its counter)
							else
								state_message2 <= "load_SRAM~~~~~~~";
								halt_clk_en <= '0';
								o_global_reset <= '0';
								init_count <= 0; -- After reseting all the system start clk_en
								init_state <= load_SRAM;
							end if;
						when load_SRAM => -- After reseting all system load SRAM (256 values)
							state_message2 <= "loading_SRAM~~~~";
							o_global_reset <= '0';
							SRAM_R_W <= '0'; -- Set SRAM to Write mode
							if (init_count <= 256 and en = '1') then
								init_count <= init_count + 1;
								SRMA_clk_en <= '1';
								halt_clk_en <= '0';
							elsif (init_count > 255) then -- 255 Values loaded to SRAM 
								halt_clk_en <= '1'; -- resets clk_en counter
								init_state <= init_complete;  
								SRMA_clk_en <= '0';
							else
								SRMA_clk_en <= '0';
								halt_clk_en <= '0';
							end if;
						when init_complete =>
							o_global_reset <= '0';
							init_state <= init_complete; 
					end case;
				when global_reset =>
					state_message <= "~Global Reset   ";
					state_message2 <= "Global Reset    ";
					init_state <= init_reset;
					o_global_reset <= '1';
					halt_clk_en <= '1';
					btn_debounce_count <= 0;
					mode_btn_state <= "00";
					mode_sw_signal <= '0';
					PWM_en <= '1';

				when Test_Mode =>
					SRAM_R_W <= '1'; -- Set SRAM controller to Read Mode
					SRMA_clk_en <= en;
					o_global_reset <= '0';
					clk_en_delay <= 49999999; -- Set counter speed to 1
					state_message <= "~~~Test__Mode~~~";

					if (sw_mode = '0') then
						pwm_or_pause <= '1';
					elsif (PWM_tog = '0') then
						pwm_or_pause <= '0';
					end if;

					if (mode_btn_state = "00" and sw_mode = '1' and PWM_tog = '1') then
						halt_clk_en <= '0';
						state_message2 <= "KEY[1] not press"; 
					elsif ((sw_mode = '0' or PWM_tog = '0') and btn_debounce_count < btn_debounce_delay and mode_btn_state= "00") then -- Swich mode btn is pressed and is being debounced
						btn_debounce_count <= btn_debounce_count + 1;
						halt_clk_en <= '1';
					elsif ((sw_mode = '0' or PWM_tog = '0') and btn_debounce_count = btn_debounce_delay and mode_btn_state= "00") then
						btn_debounce_count <= 0;
						mode_btn_state <= "01"; -- Butn is pressed and debouced
					elsif ((sw_mode = '0' or PWM_tog = '0') and mode_btn_state= "01") then -- Btn is pressed and debounced, wait for release
						btn_debounce_count <= 0;
						mode_btn_state <= "01"; -- Butn is pressed and debouced
						state_message2 <= "KEY[1] press&deb";
					elsif (sw_mode = '1' and PWM_tog = '1') then
						mode_btn_state <= "11";
						mode_sw_signal <= '1';
					else 
						mode_btn_state <= "00";
						btn_debounce_count <= 0;
					end if;

				when Pause_Mode => 
					if (mode_btn_state = "11" and sw_mode = '1') then
						PWM_en <= '1';
						halt_clk_en <= '1';
						state_message <= "PAUSE MODE      "; 
						state_message2 <= "KEY[1] not press"; 
					elsif (sw_mode = '0' and btn_debounce_count < btn_debounce_delay and mode_btn_state= "11") then -- Swich mode btn is pressed and is being debounced
						PWM_en <= '0';
						btn_debounce_count <= btn_debounce_count + 1;
						halt_clk_en <= '1';
					elsif (sw_mode = '0' and btn_debounce_count = btn_debounce_delay and mode_btn_state= "11") then
						btn_debounce_count <= 0;
						mode_btn_state <= "01"; -- Butn is pressed and debouced
					elsif (sw_mode = '0' and mode_btn_state= "01") then -- Btn is pressed and debounced, wait for release
						btn_debounce_count <= 0;
						mode_btn_state <= "01"; -- Butn is pressed and debouced
						state_message2 <= "KEY[1] press&deb"; 
					elsif (sw_mode = '1') then
						mode_btn_state <= "00";
						mode_sw_signal <= '0';
					else 
						mode_btn_state <= "00";
						btn_debounce_count <= 0;
					end if;

				when PWM =>
					if (mode_btn_state = "11" and PWM_tog = '1') then
						halt_clk_en <= '1';
						state_message <= "PWM   MODE      "; 
						state_message2 <= "KEY[1] not press"; 
					elsif (PWM_tog = '0' and btn_debounce_count < btn_debounce_delay and mode_btn_state= "11") then -- Swich mode btn is pressed and is being debounced
						btn_debounce_count <= btn_debounce_count + 1;
						halt_clk_en <= '1';
					elsif (PWM_tog = '0' and btn_debounce_count = btn_debounce_delay and mode_btn_state= "11") then
						btn_debounce_count <= 0;
						mode_btn_state <= "01"; -- Butn is pressed and debouced
					elsif (PWM_tog = '0' and mode_btn_state= "01") then -- Btn is pressed and debounced, wait for release
						btn_debounce_count <= 0;
						mode_btn_state <= "01"; -- Butn is pressed and debouced
						state_message2 <= "KEY[1] press&deb"; 
					elsif (PWM_tog = '1') then
						mode_btn_state <= "00";
						mode_sw_signal <= '0';
					else 
						mode_btn_state <= "00";
						btn_debounce_count <= 0;
					end if;

			end case;
		end if;
	end process system_State_machine;

	clk_enabler : process (clk) begin
		if rising_edge(clk) then
			if (clk_en_count = clk_en_delay and halt_clk_en = '0') then
				en <= '1';
				clk_en_count <= 0;
			elsif (halt_clk_en = '0') then
				en <= '0';
				clk_en_count <= clk_en_count + 1;
			elsif (iReset = '1' or halt_clk_en = '1') then
				en <= '0';
				clk_en_count <= 0;
			end if;
		end if;
	end process clk_enabler;

	clk_en <= en;
	LCD_line1 (127 downto 120) <= std_logic_vector(to_unsigned(character'pos(state_message(1)), 8));
	LCD_line1 (119 downto 112) <= std_logic_vector(to_unsigned(character'pos(state_message(2)), 8));
	LCD_line1 (111 downto 104) <= std_logic_vector(to_unsigned(character'pos(state_message(3)), 8));
	LCD_line1 (103 downto 96) <= std_logic_vector(to_unsigned(character'pos(state_message(4)), 8));
	LCD_line1 (95 downto 88) <= std_logic_vector(to_unsigned(character'pos(state_message(5)), 8));
	LCD_line1 (87 downto 80) <= std_logic_vector(to_unsigned(character'pos(state_message(6)), 8));
	LCD_line1 (79 downto 72) <= std_logic_vector(to_unsigned(character'pos(state_message(7)), 8));
	LCD_line1 (71 downto 64) <= std_logic_vector(to_unsigned(character'pos(state_message(8)), 8));
	LCD_line1 (63 downto 56) <= std_logic_vector(to_unsigned(character'pos(state_message(9)), 8));
	LCD_line1 (55 downto 48) <= std_logic_vector(to_unsigned(character'pos(state_message(10)), 8));
	LCD_line1 (47 downto 40) <= std_logic_vector(to_unsigned(character'pos(state_message(11)), 8));
	LCD_line1 (39 downto 32) <= std_logic_vector(to_unsigned(character'pos(state_message(12)), 8));
	LCD_line1 (31 downto 24) <= std_logic_vector(to_unsigned(character'pos(state_message(13)), 8));
	LCD_line1 (23 downto 16) <= std_logic_vector(to_unsigned(character'pos(state_message(14)), 8));
	LCD_line1 (15 downto 8) <= std_logic_vector(to_unsigned(character'pos(state_message(15)), 8));
	LCD_line1 (7 downto 0) <= std_logic_vector(to_unsigned(character'pos(state_message(16)), 8));
	-- LCD_line1 <= X"41414141414141414141414141414141";

	LCD_line2 (127 downto 120) <= std_logic_vector(to_unsigned(character'pos(state_message2(1)), 8));
	LCD_line2 (119 downto 112) <= std_logic_vector(to_unsigned(character'pos(state_message2(2)), 8));
	LCD_line2 (111 downto 104) <= std_logic_vector(to_unsigned(character'pos(state_message2(3)), 8));
	LCD_line2 (103 downto 96) <= std_logic_vector(to_unsigned(character'pos(state_message2(4)), 8));
	LCD_line2 (95 downto 88) <= std_logic_vector(to_unsigned(character'pos(state_message2(5)), 8));
	LCD_line2 (87 downto 80) <= std_logic_vector(to_unsigned(character'pos(state_message2(6)), 8));
	LCD_line2 (79 downto 72) <= std_logic_vector(to_unsigned(character'pos(state_message2(7)), 8));
	LCD_line2 (71 downto 64) <= std_logic_vector(to_unsigned(character'pos(state_message2(8)), 8));
	LCD_line2 (63 downto 56) <= std_logic_vector(to_unsigned(character'pos(state_message2(9)), 8));
	LCD_line2 (55 downto 48) <= std_logic_vector(to_unsigned(character'pos(state_message2(10)), 8));
	LCD_line2 (47 downto 40) <= std_logic_vector(to_unsigned(character'pos(state_message2(11)), 8));
	LCD_line2 (39 downto 32) <= std_logic_vector(to_unsigned(character'pos(state_message2(12)), 8));
	LCD_line2 (31 downto 24) <= std_logic_vector(to_unsigned(character'pos(state_message2(13)), 8));
	LCD_line2 (23 downto 16) <= std_logic_vector(to_unsigned(character'pos(state_message2(14)), 8));
	LCD_line2 (15 downto 8) <= std_logic_vector(to_unsigned(character'pos(state_message2(15)), 8));
	LCD_line2 (7 downto 0) <= std_logic_vector(to_unsigned(character'pos(state_message2(16)), 8));
	-- LCD_line2 <= X"41414141414141414141414141414141";

	direction <= '1';
	init_signal <= '0' when (current_state = init) else '1';
	void <= '1' & mode_sw_signal;
end;