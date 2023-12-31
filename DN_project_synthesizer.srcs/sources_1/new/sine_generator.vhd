----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2023 20:10:16
-- Design Name: 
-- Module Name: sine_generator - Behavioral
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

entity sine_generator is
    generic (
        signal_width : integer;
        time_counter_width : integer
    );
    Port (
        freq_idx : in unsigned(5 downto 0);
        time_counter : in unsigned(time_counter_width-1 downto 0);
        sine_signal : out signed(signal_width downto 0)
    );
end sine_generator;

architecture Behavioral of sine_generator is

    constant max_freq_index : unsigned(5 downto 0) := TO_UNSIGNED(48, 6);

    signal sine_in : std_logic_vector(12 downto 0);
    signal sine_out : std_logic_vector(7 downto 0);
    signal sine_addr : std_logic_vector(45 downto 0);
    
    signal freq_in : std_logic_vector(5 downto 0);
    signal freq_out : std_logic_vector(20 downto 0);
    
    signal amp_out : std_logic_vector(7 downto 0);
    signal signal_val : signed(17 downto 0);

begin
    
    sine : entity work.sine_ROM(Behavioral)
    port map (
        address => sine_in,
        dout => sine_out
    );
    
    freq : entity work.freq_ROM(Behavioral)
    port map (
        address => freq_in,
        dout => freq_out
    );
    
    amp : entity work.amp_ROM(Behavioral)
    port map (
        address => freq_in,
        dout => amp_out
    );
    
    single_sine_generator : process(freq_idx)
    begin
        if freq_idx < max_freq_index then
            freq_in <= std_logic_vector(freq_idx);
            sine_addr <= std_logic_vector((((unsigned(freq_out) * time_counter) / 1024) mod 8192));
            sine_in <= sine_addr(12 downto 0);
            signal_val <= ((signed("0" & sine_out) - 128) * signed("0" & amp_out)) / 255;
            sine_signal <= signal_val(8 downto 0);
        end if;
    end process;

end Behavioral;
