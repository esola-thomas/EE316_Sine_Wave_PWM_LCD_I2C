LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity i2c_controller is
port(   
            clk         : in std_logic;
            reset       : in std_logic;
            i_data      : in std_logic_vector(15 downto 0);
            address     : in std_logic_vector(6 downto 0);
            sda         : inout std_logic;
            scl         : inout std_logic
);
end i2c_controller;

architecture Behavior of i2c_controller is

component i2c_master is
 GENERIC(
    input_clk : INTEGER := 50_000_000;  
    bus_clk   : INTEGER := 400_000);  
 PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(15 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus                 
END component;


type state_type is(start, ready, data_valid, busy_high, repeat);
signal state        : state_type;
signal busy         : std_logic;
signal reset_n      : std_logic;
signal ena          : std_logic;
signal addr         : std_logic_vector(6 downto 0);
signal rw           : std_logic;
signal data_wr      : std_logic_vector(7 downto 0);
signal byteSel      : integer range 0 to 12:= 0;
--signal Cont 		  : unsigned (19 downto 0):=X"03FFF";
signal iData 		  : std_logic_vector(15 downto 0);
signal Sub_Addr     : std_logic_vector(6 downto 0);  

begin

Inst_i2c_master: i2c_master
 GENERIC MAP(
    input_clk => 50_000_000,  
    bus_clk   => 50_000) 
 PORT MAP(
    clk       => clk,                  
    reset_n   => reset_n,                   
    ena       => ena,                    
    addr      => addr, 
    rw        => rw,                 
    data_wr   => data_wr,
    busy      => busy,                  
    data_rd   => open,
    ack_error => open,                  
    sda       => sda,                  
    scl       => scl                  
);

process(byteSel, clk, i_data )
begin   
    if rising_edge(clk) then
        case byteSel is
            when 0  => data_wr <= X"76";
            when 1  => data_wr <= X"76";
            when 2  => data_wr <= X"76";
            when 3  => data_wr <= X"7A";
            when 4  => data_wr <= X"FF";
            when 5  => data_wr <= X"77";
            when 6  => data_wr <= X"00";
            when 7  => data_wr <= X"79";
            when 8  => data_wr <= X"00";
            when 9  => data_wr <= X"0"&iData(15 downto 12);
            when 10 => data_wr <= X"0"&iData(11 downto 8);
            when 11 => data_wr <= X"0"&iData(7 downto 4);
            when 12 => data_wr <= X"0"&iData(3 downto 0);
            when others => data_wr <= X"76";
        end case;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
    
        iData <= i_data;
        Sub_Addr <= address;
    
    end if;
end process;

process(clk, reset)
begin
    if reset = '1' then
        state <= start;
        ena <= '0';
        byteSel <= 0;
    elsif rising_edge(clk) then
        case state is
				--Start state
            when start =>
--					IF Cont /= X"00000" THEN
--						Cont <= Cont -1;
--						reset_n <= '0';
--						state <= start;
--						ena <='0';
--						else
                    ena <= '1';                 --initiate the transaction
                    addr <= Sub_Addr;           --set the address of the subordinate
                    rw <= '0';                  --command 0 allows it a write     
                    state <= ready;
--					end if;

				--Ready State
            when ready => 
                if busy = '0' then
                    ena <= '1';
                    state <= data_valid;
                end if;
            when data_valid =>
            if busy = '1' then
                ena <= '0';
                state <= busy_high;
                end if;
     
				--Busy High State
            when busy_high =>
            
                if busy = '0' then
                    state <= repeat;
                end if;
            
				--Repeat state
            when repeat =>
            
                if byteSel < 12 then
                    byteSel <= byteSel + 1;
                else
                    byteSel <= 9;
                end if;
                    state <= start;
            when others => null;    
        end case;
    end if;
end process;
end Behavior;

