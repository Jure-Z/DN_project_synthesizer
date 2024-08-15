----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2023 14:28:46
-- Design Name: 
-- Module Name: seven_seg_display - Behavioral
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

entity seven_seg_display is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           value_recording_length : in STD_LOGIC_VECTOR (31 downto 0);
           value_playback_time : in STD_LOGIC_VECTOR (31 downto 0);
           recording : in std_logic;
           playback : in std_logic;
           cathode_out : out STD_LOGIC_VECTOR (7 downto 0);
           anode_out : out STD_LOGIC_VECTOR (7 downto 0));
end seven_seg_display;

architecture Behavioral of seven_seg_display is

    constant prescaler_max: integer := 2e5;
    
    signal CE : STD_LOGIC;
    signal anode : STD_LOGIC_VECTOR(7 downto 0);
    signal digit : STD_LOGIC_VECTOR(3 downto 0);
    
    signal value_recording_length_sec : unsigned(31 downto 0);
    signal value_playback_time_sec : unsigned(31 downto 0);

begin

    anode_out <= "11111111" when recording = '0' and playback = '0' else
                 anode or "11110000" when recording = '1' else
                 anode when playback = '1' else
                 "11111111";
                 
    value_recording_length_sec <= unsigned(value_recording_length) / 16;
    value_playback_time_sec <= unsigned(value_playback_time) / 16;


    prescaler : entity work.prescaler(Behavioral)
    generic map(max_count => prescaler_max)
    port map(
        clock => clock,
        reset => reset,
        clock_enable => CE,
        limit => prescaler_max
    );
    
    anode_select : entity work.anode_select(Behavioral)
    port map(
        clock => clock,
        reset => reset,
        clock_enable => CE,
        anode => anode
    );
    
    value_to_digit : entity work.value_to_digit(Behavioral)
    port map(
        value_recording_length => std_logic_vector(value_recording_length_sec),
        value_playback_time => std_logic_vector(value_playback_time_sec),
        digit => digit,
        anode => anode
    );
    
    digit_to_segments : entity work.digit_to_segments(Behavioral)
    port map(
        digit => digit,
        cathode => cathode_out
    );

end Behavioral;
