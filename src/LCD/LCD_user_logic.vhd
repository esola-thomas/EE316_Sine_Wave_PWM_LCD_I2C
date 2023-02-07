LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--USE ieee.std_logic_unsigned.all;
 
ENTITY LCD_user_logic IS
  GENERIC (
    CONSTANT CntMax : integer := 49999);
  PORT(
    clk         : IN     STD_LOGIC;                
    iReset_n    : IN     STD_LOGIC;
    LCD_message : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);
    LCD_DATA  : OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);
    LCD_EN  : OUT     STD_LOGIC;
    LCD_RS  : OUT    STD_LOGIC);                    
END LCD_user_logic;
 
ARCHITECTURE user_logic OF LCD_user_logic IS
 
TYPE state_type IS(start, ready, data_valid, busy_high, repeat); --needed states
signal state      : state_type;                   --state machine
signal pwrReset    : STD_LOGIC;                    -- reset delay
signal ena        : STD_LOGIC;                    --latch in data
signal temp_LCD_DATA       : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write
signal LCD_DATA_wr    : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write
signal temp_LCD_RS       : STD_LOGIC; --data to write
signal LCD_RS_wr    : STD_LOGIC; --data to write
signal busy       : STD_LOGIC;                    --indicates transaction in
signal count    : unsigned(27 DOWNTO 0):=X"000000F";
signal byteSel      : integer range 0 to 41:=0;
signal sig_LCD_DATA : std_logic_vector(7 DOWNTO 0);
signal sig_LCD_EN, sig_LCD_RS     : std_logic;
 
COMPONENT LCD_master is
  Generic (Constant CntMax : integer:= 49999);  -- (125 MHz/500 KHz) - 1 = 249
  Port ( clock             : in std_logic; -- board clock    
          iLCD_Data        : in std_logic_vector(7 downto 0);
          iLCD_RS          : in std_logic;
          resetDelay       : in std_logic;
          iReset_n         : in std_logic;  
         iEna              : in std_logic;
         oBusy             : out std_logic;        
         LCD_DATA          : out std_logic_vector(7 downto 0);
         LCD_EN, LCD_RS    : out std_logic
        );
end COMPONENT;

COMPONENT HEX2Ascii is 
   port (
        HEX  : in std_logic_vector(3 downto 0);
        ASCII  : out std_logic_vector(7 downto 0)
    );
end Component;
 
BEGIN
LCD_DATA <=Sig_LCD_DATA;
LCD_RS <= Sig_LCD_RS;
LCD_EN <= Sig_LCD_EN;
process(byteSel)
 begin
    case byteSel is
      when 0  =>  temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';
      when 1  =>  temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';
      when 2  =>  temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';    
      when 3  =>  temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';
      when 4  =>  temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';
      when 5  =>  temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';
      when 6  =>  temp_LCD_DATA <= X"01";
                  temp_LCD_RS <= '0';
      when 7  =>  temp_LCD_DATA <= X"0C";
                  temp_LCD_RS <= '0';
      when 8  =>  temp_LCD_DATA <= X"06";
                  temp_LCD_RS <= '0';
      when 9  =>  temp_LCD_DATA <= X"80";
                  temp_LCD_RS <= '0';
      when 10  => temp_LCD_DATA <= X"53";
                  temp_LCD_RS <= '1';
      when 11  => temp_LCD_DATA <= X"79";
                  temp_LCD_RS <= '1';    
      when 12  => temp_LCD_DATA <= X"73";
                  temp_LCD_RS <= '1';
      when 13  => temp_LCD_DATA <= X"74";
                  temp_LCD_RS <= '1';
      when 14  => temp_LCD_DATA <= X"65";
                  temp_LCD_RS <= '1';
      when 15  => temp_LCD_DATA <= X"6D";
                  temp_LCD_RS <= '1';
      when 16  => temp_LCD_DATA <= X"FE";
                  temp_LCD_RS <= '1';
      when 17  => temp_LCD_DATA <= X"52";
                  temp_LCD_RS <= '1';
      when 18  => temp_LCD_DATA <= X"65";
                  temp_LCD_RS <= '1';
      when 19  => temp_LCD_DATA <= X"61";
                  temp_LCD_RS <= '1';
      when 20  => temp_LCD_DATA <= X"64";    
                  temp_LCD_RS <= '1';
      when 21  => temp_LCD_DATA <= X"79";  
                  temp_LCD_RS <= '1';
      when 22  => temp_LCD_DATA <= X"c0";    --repeat
                  temp_LCD_RS <= '0';
      when 23  => temp_LCD_DATA <= X"3D";
                  temp_LCD_RS <= '1';
      when 24  => temp_LCD_DATA <= X"3D";
                  temp_LCD_RS <= '1';
      when 25  => temp_LCD_DATA <= X"3E";
                  temp_LCD_RS <= '1';
      when 26  => temp_LCD_DATA <= X"30";   -- 1
                  temp_LCD_RS <= '1';
      when 27  => temp_LCD_DATA <= X"31";   -- 2
                  temp_LCD_RS <= '1';
      when 28  => temp_LCD_DATA <= x"32";   -- 3
                  temp_LCD_RS <= '1';
      when 29  => temp_LCD_DATA <= x"33";   -- 4
                  temp_LCD_RS <= '1';
      when 30  => temp_LCD_DATA <= x"34";   -- 5
                  temp_LCD_RS <= '1';
      when 31  => temp_LCD_DATA <= x"35";   -- 6
                  temp_LCD_RS <= '1';
      when 32  => temp_LCD_DATA <= x"36";   -- 7
                  temp_LCD_RS <= '1';
      when 33  => temp_LCD_DATA <= x"37";   -- 8
                  temp_LCD_RS <= '1';
      when 34  => temp_LCD_DATA <= x"38";   -- 9
                  temp_LCD_RS <= '1';
      when 35  => temp_LCD_DATA <= x"39";   -- 10
                  temp_LCD_RS <= '1';
      when 36  => temp_LCD_DATA <= x"41";   -- 11
                  temp_LCD_RS <= '1';
      when 37  => temp_LCD_DATA <= x"42";   -- 12
                  temp_LCD_RS <= '1';
      when 38  => temp_LCD_DATA <= x"43";   -- 13
                  temp_LCD_RS <= '1';
      when 39  => temp_LCD_DATA <= x"44";   -- 14
                  temp_LCD_RS <= '1';
      when 40  => temp_LCD_DATA <= x"45";   -- 15
                  temp_LCD_RS <= '1';
      when 41  => temp_LCD_DATA <= x"46";   -- 16
                  temp_LCD_RS <= '1';
      when others => temp_LCD_DATA <= X"38";
                  temp_LCD_RS <= '0';
   end case;
end process;
 
Inst_LCD_master: LCD_master
  GENERIC map(
    CntMax => 49999)
  port map(
    iReset_n  => iReset_n,  
    resetDelay  => pwrReset,  
    clock => clk,    
    iEna  => ena,    
    iLCD_RS => LCD_RS_wr,    
    iLCD_DATA => LCD_DATA_wr,
        oBusy   => busy,
        LCD_DATA => Sig_LCD_DATA,
        LCD_RS => Sig_LCD_RS,
        LCD_EN => Sig_LCD_EN    
    );
 
process(clk, iReset_n)
begin
if(clk'event and clk = '1') then
  case state is
  when start =>
      if count /= X"0000000" then                        
    count   <= count - 1;
    pwrReset <= '0';  
    state   <= start;
    ena   <= '0';  
  else
    pwrReset <= '1';
    state   <= ready;
    LCD_RS_wr <= temp_LCD_RS;
    LCD_DATA_wr <= temp_LCD_DATA;                  --data to be written
    end if;
 
  when ready =>  
        if busy = '0' then
          ena     <= '1';
          state   <= data_valid;
        end if;
 
  when data_valid =>                              --state for conducting this transaction
              if busy = '1' then  
          ena     <= '0';
          state   <= busy_high;
              end if;
  when busy_high =>
              if iReset_n = '0' then
              byteSel <= 0;
              end if;
              if(busy = '0') then                -- busy just went low
          state <= repeat;
          end if;    
       
  when repeat =>
            if byteSel < 29 then
               byteSel <= byteSel + 1;
          else  
               byteSel <= 22;          
          end if;      
              state <= start;
  when others => null;
 
  end case;  
end if;  
end process;        
end user_logic; 