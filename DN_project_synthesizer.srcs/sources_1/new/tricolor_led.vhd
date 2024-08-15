----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.08.2024 16:55:05
-- Design Name: 
-- Module Name: tricolor_led - Behavioral
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

entity tricolor_led is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        waveform : in unsigned(1 downto 0);
        led16 : out std_logic_vector(2 downto 0)
    );
end tricolor_led;

architecture Behavioral of tricolor_led is

    signal color : std_logic_vector(2 downto 0);
    signal counter : unsigned(2 downto 0) := (others => '0');

begin

    color <= "001" when waveform = "00" else
             "010" when waveform = "01" else
             "100" when waveform = "10" else
             "101";
    
    
    led16 <= color when counter = "000" else "000";
         
    process(clk)
    begin
        
        if rising_edge(clk) then
            if rst = '1' then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    
    end process;

end Behavioral;
