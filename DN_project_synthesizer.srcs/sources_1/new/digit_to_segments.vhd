----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2023 14:14:22
-- Design Name: 
-- Module Name: digit_to_segments - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity digit_to_segments is
    Port ( digit : in STD_LOGIC_VECTOR (3 downto 0);
           cathode : out STD_LOGIC_VECTOR (7 downto 0));
end digit_to_segments;

architecture Behavioral of digit_to_segments is

begin

    cathode <= "11000000" when digit = "0000" else
               "11111001" when digit = "0001" else
               "10100100" when digit = "0010" else
               "10110000" when digit = "0011" else
               "10011001" when digit = "0100" else
               "10010010" when digit = "0101" else
               "10000010" when digit = "0110" else
               "11111000" when digit = "0111" else
               "10000000" when digit = "1000" else
               "10010000" when digit = "1001" else
               "10001000" when digit = "1010" else
               "10000011" when digit = "1011" else
               "11000110" when digit = "1100" else
               "10100001" when digit = "1101" else
               "10000110" when digit = "1110" else
               "10001110" when digit = "1111" else
               "00000000";

end Behavioral;
