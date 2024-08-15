----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2023 14:02:14
-- Design Name: 
-- Module Name: value_to_digit - Behavioral
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

entity value_to_digit is
    Port ( value_recording_length : in STD_LOGIC_VECTOR (31 downto 0);
           value_playback_time : in STD_LOGIC_VECTOR (31 downto 0);
           anode : in STD_LOGIC_VECTOR (7 downto 0);
           digit : out STD_LOGIC_VECTOR (3 downto 0));
end value_to_digit;

architecture Behavioral of value_to_digit is

signal recording_length : unsigned(31 downto 0);
signal playback_time : unsigned(31 downto 0);
signal digit_unsigned : unsigned(31 downto 0);

begin

    recording_length <= unsigned(value_recording_length);
    playback_time <= unsigned(value_playback_time);
    digit <= std_logic_vector(digit_unsigned(3 downto 0));

    
    process(recording_length, playback_time, anode)
    begin
    
        if( anode(0) = '0' or anode(1) = '0' or anode(2) = '0' or anode(3) = '0' ) then
        
            if( recording_length > 9999 ) then
                digit_unsigned <= (others => '0');
            elsif( anode(0) = '0' ) then
                digit_unsigned <= (recording_length mod 10);
            elsif( anode(1) = '0' ) then
                digit_unsigned <= ((recording_length / 10) mod 10);
            elsif( anode(2) = '0' ) then
                digit_unsigned <= ((recording_length / 100) mod 10);
            elsif( anode(3) = '0' ) then
                digit_unsigned <= ((recording_length / 1000) mod 10);
            else
                digit_unsigned <= (others => '0');
            end if;
            
        elsif( anode(4) = '0' or anode(5) = '0' or anode(6) = '0' or anode(7) = '0' ) then
        
            if( playback_time > 9999 ) then
                digit_unsigned <= (others => '0');
            elsif( anode(4) = '0' ) then
                digit_unsigned <= (playback_time mod 10);
            elsif( anode(5) = '0' ) then
                digit_unsigned <= ((playback_time / 10) mod 10);
            elsif( anode(6) = '0' ) then
                digit_unsigned <= ((playback_time / 100) mod 10);
            elsif( anode(7) = '0' ) then
                digit_unsigned <= ((playback_time / 1000) mod 10);
            else
                digit_unsigned <= (others => '0');
            end if;
            
        else
            digit_unsigned <= (others => '0');
        end if;
    
    end process;

end Behavioral;
