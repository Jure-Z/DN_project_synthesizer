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

entity triangle_ROM is
    port(
        address : in  std_logic_vector(12 downto 0);
        dout    : out std_logic_vector(7 downto 0)
    );
end triangle_ROM;

architecture Behavioral of triangle_ROM is

    signal val : std_logic_vector(25 downto 0);

begin

    val <= std_logic_vector((unsigned(address) * 255) / 4095) when unsigned(address) < 4096
           else std_logic_vector(255 - (((unsigned(address) - 4096) * 255) / 4095));
    dout <= val(7 downto 0);
    
end Behavioral;
