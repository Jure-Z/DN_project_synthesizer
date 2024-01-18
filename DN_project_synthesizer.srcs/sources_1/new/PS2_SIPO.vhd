----------------------------------------------------------------------------------
-- Pomikalni register SIPO (Serial In Parallel Out)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2_SIPO is
    port (
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        we : in STD_LOGIC;
        PS2_DATA_S : in STD_LOGIC;
        data : out STD_LOGIC_VECTOR (8 downto 0));
end PS2_SIPO;

architecture Behavioral of PS2_SIPO is
    signal data_i : std_logic_vector (8 downto 0) := (others => '1');
    
begin
    data <= data_i;
    
    process (clock) 
    begin 
        if rising_edge(clock) then
            if reset = '1' then 
                data_i <= (others => '1');
            elsif we = '1' then
                data_i <= PS2_DATA_S & data_i(8 downto 1);
                -- Alternativa
                --data_i(7 downto 0) <= data_i(8 downto 1);
                --data_i(8) <= PS2_DATA_S;
            end if;
        end if; 
    end process;
end Behavioral;
