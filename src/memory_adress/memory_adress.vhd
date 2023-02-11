library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memory_adress is
    generic(
        address_bus: integer := 16;
        Max_Adress : std_logic_vector (15 downto 0) := X"00FF"
    );
    port(
        clk     : in std_logic;
        clk_en  : in std_logic;
        iReset  : in std_logic;
        address : out std_logic_vector(address_bus-1 downto 0)
    );

end memory_adress;

architecture arch of memory_adress is

    signal current_address : std_logic_vector (15 downto 0);
begin
    process (clk, iReset, clk_en) is begin
        if (iReset = '1') then  
        current_address <= (others => '0');
        elsif (rising_edge(clk) and clk_en = '1') then
            if (current_address = Max_Adress) then
                current_address <= (others => '0');
            else
                current_address <= current_address + '1';
            end if;
        end if;
    end process;

    address <= current_address (address_bus-1 downto 0);
end arch;