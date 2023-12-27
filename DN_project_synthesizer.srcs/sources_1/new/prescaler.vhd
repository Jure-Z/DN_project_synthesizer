--------------------------------------------------------------------------
-- LAB 03: example - generic counter 
-- Prescaler
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prescaler is
    generic (max_count : integer ); -- the maximum of a prescaler counter
    port (
        clock:         in  std_logic;
        reset:         in  std_logic;
        limit:         in  integer;
        clock_enable : out std_logic);
end entity;

architecture Behavioral of prescaler is
    signal value: integer range 0 to max_count := 0;
begin
    process (clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                value <= 0;
                clock_enable <= '0';
            else
                if value >= limit then
                    value <= 0;
                    clock_enable <= '1';
                else
                    value <= value + 1;
                    clock_enable <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
