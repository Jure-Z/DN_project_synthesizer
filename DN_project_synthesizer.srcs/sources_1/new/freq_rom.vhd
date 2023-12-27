----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2023 16:24:42
-- Design Name: 
-- Module Name: freq_rom - Behavioral
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

entity freq_rom is
    port(
        address : in  std_logic_vector(5 downto 0);
        dout    : out std_logic_vector(20 downto 0)
    );
end freq_rom;

architecture Behavioral of freq_rom is

    type MEMORY is array (0 to 47) of std_logic_vector(20 downto 0);
    constant ROM : MEMORY := (
        --binarne vrednosti frekvenc pomnoženih z 1024 za natanènost
        "000100000101101000000","000100010101001011110","000100100101101010100","000100110111001000001","000101001001101000001","000101011101001110101","000101110001111111101","000110000111111111110","000110011111010011100","000110111000000000000","000111010010001010100","000111101101111000100","001000001011010000001","001000101010010111011","001001001011010101001","001001101110010000010","001010010011010000011","001010111010011101010","001011100011111111010","001100001111111111011","001100111110100111000","001101110000000000000","001110100100010101000","001111011011110001001","010000010110100000001","010001010100101110110","010010010110101010001","010011011100100000100","010100100110100000101","010101110100111010011","010111000111111110101","011000011111111110111","011001111101001110000","011011100000000000000","011101001000101001111","011110110111100010001","100000101101000000010","100010101001011101100","100100101101010100011","100110111001000001000","101001001101000001010","101011101001110100111","101110001111111101001","110000111111111101101","110011111010011100000","110111000000000000000","111010010001010011111","111101101111000100010"
    );

begin

    process(address)
    begin
        dout <= ROM(to_integer(unsigned(address)));
    end process;

end Behavioral;
