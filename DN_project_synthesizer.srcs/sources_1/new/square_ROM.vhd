----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2023 15:35:32
-- Design Name: 
-- Module Name: sine_ROM - Behavioral
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

entity square_ROM is
    port(
        address : in  std_logic_vector(12 downto 0);
        dout    : out std_logic_vector(7 downto 0)
    );
end square_ROM;

architecture Behavioral of square_ROM is

begin

    dout <= x"00" when unsigned(address) < 4096 else x"ff";

end Behavioral;
