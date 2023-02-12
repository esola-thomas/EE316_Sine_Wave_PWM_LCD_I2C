LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity tb_I2C_Controller is
end tb_I2C_Controller;

architecture tb of tb_I2C_Controller is

	component i2c_controller is
	port( 	
				clk			: in std_logic;
				reset		: in std_logic;
				i_data		: in std_logic_vector(15 downto 0);
				address		: in std_logic_vector(6 downto 0);
				sda			: inout std_logic;
				scl			: inout std_logic
	);
	end component;
	
	signal testing_clk 						: std_logic := '0';
	signal testing_reset						: std_logic;
	signal testing_i_data					: std_logic_vector(15 downto 0);
	signal testing_address					: std_logic_vector(6 downto 0);
	signal testing_sda						: std_logic;
	signal testing_scl						: std_logic;

begin

	DUT: i2c_controller
		port map(
			clk => testing_clk,
			reset => testing_reset,
			i_data => testing_i_data, 
			address => testing_address,
			sda => testing_sda,
			scl => testing_scl
		);
	
	testing_clk <= not testing_clk after 10 ns;
		
	process
	begin
		testing_reset <= '1';
		testing_i_data <= X"ABCD"; -- testing address
		testing_address <= "1110001"; -- subordinate address, 0x71
		wait for 100 ns;
		testing_reset <= '0';
		wait;
	
	end process;

end tb;