library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
  
entity Clock_Divider is
    generic (
        division_rate_max : integer := 100
    );
    port (
        clk, reset: in std_logic;
        division_rate : in integer range 0 to division_rate_max;
        clock_out: out std_logic;
        neg_edge : out std_logic;
        pos_edge : out std_logic
    );
end Clock_Divider;
  
architecture Behavioral of Clock_Divider is
    
    constant count_max : integer := division_rate_max/2;
    
    signal count_limit : integer range 0 to count_max;
    signal count: integer range 0 to count_max := 1;
    signal tmp : std_logic := '0';
  
begin

    count_limit <= division_rate/2;
  
    process(clk,reset)
    begin
        if(reset='1') then
            count<=1;
            tmp<='0';
            neg_edge <= '0';
            neg_edge <= '0';
        elsif(clk'event and clk='1') then
            count <=count+1;
            
            if (count >= count_limit) then
                if (tmp = '0') then
                    tmp <= '1';
                    pos_edge <= '1';
                    neg_edge <= '0';
                else
                    tmp <= '0';
                    pos_edge <= '0';
                    neg_edge <= '1';
                end if;
                
                count <= 1;
            else
                pos_edge <= '0';
                neg_edge <= '0';
            end if;
        end if;
        
        clock_out <= tmp;
        
    end process;
  
end Behavioral;
