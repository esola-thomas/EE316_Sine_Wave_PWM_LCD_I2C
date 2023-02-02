library IEEE;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
 
entity LCD_master is
    Generic (Constant CntMax : integer:= 49999);
    Port ( clock             : in std_logic; -- board clock
           iLCD_DATA         : in std_logic_vector(7 downto 0);
           iLCD_RS           : in std_logic;
           iReset_n          : in std_logic;
           resetDelay        : in std_logic;
           iEna              : in std_logic := '0';
           oBusy             : out std_logic;
           LCD_DATA          : out std_logic_vector(7 downto 0);
           LCD_EN,LCD_RS     : out std_logic
          );
end LCD_master;
 
architecture state_machine of LCD_master is
 
    type stateType is (Ready, Prepare, EnHigh, EnLow, Done);
    signal state    : stateType;      
    signal cnt      : integer range 0 to CntMax; --use CntMax
    signal clock_en : std_logic;
 
   
begin
 
Clock_Enable:
process(clock, iReset_n)
begin
  if iReset_n = '0' then
      cnt<=0;
      clock_en<='0';
  elsif rising_edge(clock) then
  if cnt = CntMax then      --Use CntMax
      clock_en <= '1';
      cnt <=0;
  else
      clock_en <= '0';
      cnt <= cnt+1;
  end if;
end if;
end process;
 
 
LCD_state_machine:
process(clock, iReset_n, clock_en)
begin
if (resetDelay = '0' or iReset_n = '0') then
    LCD_DATA      <= X"38";
    LCD_RS       <= '0';
    LCD_EN       <= '0';
    oBusy     <= '1';
    state     <= Ready;        
elsif rising_edge(clock) and clock_en = '1' then
    case state is
        when Ready =>
          if iEna = '0' then
            oBusy  <= '0';
            state <= Ready;
          else
            oBusy <= '1';
            LCD_EN   <= '0';
            LCD_RS  <= iLCD_RS;   --- Update RS
            LCD_DATA  <= iLCD_DATA;   --- Update DATA                                          
            state <= Prepare;
          end if;      
        when Prepare =>        
            LCD_EN   <= '0';
            state <= EnHigh;
        when EnHigh =>
            LCD_EN      <= '1';                            
            state    <= EnLow;          
       when EnLow =>
            LCD_EN      <= '0';                        
            state    <= Done;            
        when Done =>
            oBusy <= '0';
            LCD_EN <= '0';
            state <= Ready;            
        when others =>
            state <= Ready;
    end case;            
end if;
   
end process;
 
end state_machine;