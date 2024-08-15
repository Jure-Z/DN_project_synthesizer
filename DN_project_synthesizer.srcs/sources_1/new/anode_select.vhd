----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2023 13:50:24
-- Design Name: 
-- Module Name: anode_select - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity anode_select is
    Port ( clock : in STD_LOGIC;
           clock_enable : in STD_LOGIC;
           reset : in STD_LOGIC;
           anode : out STD_LOGIC_VECTOR (7 downto 0));
end anode_select;

architecture Behavioral of anode_select is

    signal anode_reg : unsigned(7 downto 0) := "11111110";

begin
    
    anode <= std_logic_vector(anode_reg);
    
    process(clock)
    begin
        if reset = '1' then
            anode_reg <= "11111110";
        elsif rising_edge(clock) then
            if clock_enable = '1' then
                anode_reg <= rotate_right(anode_reg, 1);
            end if;
        end if;
    end process;


end Behavioral;
