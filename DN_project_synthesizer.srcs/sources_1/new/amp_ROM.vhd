----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2023 14:35:00
-- Design Name: 
-- Module Name: amp_ROM - Behavioral
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

entity amp_ROM is
    port(
        address : in  std_logic_vector(5 downto 0);
        dout    : out std_logic_vector(7 downto 0)
    );
end amp_ROM;

architecture Behavioral of amp_ROM is

    type MEMORY is array (0 to 47) of std_logic_vector(7 downto 0);
    constant ROM : MEMORY := (
        "11111111",
        "11101011",
        "11011001",
        "11001001",
        "10111011",
        "10101101",
        "10100010",
        "10010111",
        "10001101",
        "10000100",
        "01111100",
        "01110100",
        "01101101",
        "01100111",
        "01100001",
        "01011100",
        "01010111",
        "01010010",
        "01001110",
        "01001010",
        "01000111",
        "01000100",
        "01000001",
        "00111110",
        "00111011",
        "00111001",
        "00110111",
        "00110101",
        "00110011",
        "00110010",
        "00110000",
        "00101111",
        "00101101",
        "00101100",
        "00101011",
        "00101010",
        "00101010",
        "00101001",
        "00101000",
        "00101000",
        "00100111",
        "00100111",
        "00100110",
        "00100110",
        "00100101",
        "00100101",
        "00100101",
        "00100101"
    );

begin

    process(address)
    begin
        dout <= ROM(to_integer(unsigned(address)));
    end process;


end Behavioral;
