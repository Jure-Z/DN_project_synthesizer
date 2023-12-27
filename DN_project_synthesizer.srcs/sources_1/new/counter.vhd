--------------------------------------------------------------------------
-- LAB 03: example - generic counter 
-- Counter
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    generic (width: integer := 4);
    port (
        clock:        in  std_logic;
        reset :       in  std_logic;
        clock_enable: in  std_logic;
        count_up:     in  std_logic;
        count_down:   in  std_logic;
        value:        out unsigned (width-1 downto 0));
end entity;

architecture Behavioral of counter is
    signal cnt: unsigned (width-1 downto 0) := (others => '0');
begin
    
    -- If value is of std_logic_vector type, we need casting
    -- value <= std_logic_vector(cnt);
    -- Instead, we can use (un)signed as output to physical pins
    value <= cnt;
    
    process(clock)
    begin
        if rising_edge(clock) then
            if reset='1' then
                cnt <= (others => '0');
            else
                if clock_enable='1' then
                    if count_up='1' and count_down='0' then
                        cnt <= cnt + 1;
                    end if;
                    if count_down='1' and count_up='0' then
                        cnt <= cnt - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
