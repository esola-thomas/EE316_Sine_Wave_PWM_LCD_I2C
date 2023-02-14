library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_File is
    generic(
	 N: integer := 16; 
	 Max_Number : integer := 127); -- number of bits of PWM counter

    port(
        clk             : in std_logic;
        reset           : in std_logic;
        sram_data       : in std_logic_vector((N- 1) downto 0);
        enable          : in std_logic;
        PWM_Output      : out std_logic--;

    );
end PWM_File;

architecture behavior of PWM_File is

    signal sram_info 		 : unsigned(N - 1 downto 0) := (others => '0');
    signal PWM_COUNTER_MAX  : unsigned(N - 1 downto 0) := (others => '0');
    signal Counter          : unsigned(N - 1 downto 0) := (others => '0');
    signal truncated_in     : std_logic_vector (7 downto 0);
    
begin


    process(clk)
    begin
	 
	 	-- sram_info	    <= unsigned(sram_data); 
		PWM_COUNTER_MAX <= to_unsigned(Max_Number, 16);

	
        if reset = '1' then
        
            Counter <= to_unsigned(0, Counter'length);
        
        elsif rising_edge(clk) and enable = '1' then
        
  
            if Counter <= PWM_COUNTER_MAX then
                Counter <= Counter + to_unsigned(1, Counter'length);
                
            else
                

                Counter <=to_unsigned(0, Counter'length);
                
            end if;
            
        end if;
    
    end process;
    
    truncated_in <= sram_data(N-1 downto n-8);

    PWM_Output <=   '0' when reset = '1' else
                    '0' when (enable = '0') else
                    '0' when (std_logic_vector(Counter) > truncated_in) else
                    '1' when (std_logic_vector(Counter) < truncated_in);
                    
                    
                    


end behavior;