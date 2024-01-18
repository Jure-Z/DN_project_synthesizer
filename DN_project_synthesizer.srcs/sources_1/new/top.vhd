----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2023 12:18:33
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port (
        CLK : in std_logic;
        CPU_RESETN : in std_logic;
        SW : in std_logic_vector(15 downto 0);
        AUD_PWM : inout std_logic;
        AUD_SD : out std_logic
    );
end top;

architecture Behavioral of top is

    constant signal_width : integer := 8;
    constant freq_num : integer := 48;

    signal rst : std_logic;
    signal audio_sig : unsigned(signal_width-1 downto 0);
    signal freqs : std_logic_vector(47 downto 0);

begin

    AUD_SD <= '1';

    rst <= not CPU_RESETN;
    freqs <= "00000000000000000000" & SW & "000000000000";
    
    signal_generator : entity work.signal_generator(Behavioral)
    generic map (
        freq_num => freq_num
    )
    port map (
        clk => CLK,
        rst => rst,
        active_freqs => freqs,
        audio_sig => audio_sig
    );
    
    PWM : entity work.PWM_generator(Behavioral)
    generic map (
        pwm_bits => signal_width,
        clk_cnt_len => 1
    )
    port map (
        clk => CLK,
        rst => rst,
        duty_cycle => audio_sig,
        pwm_out => AUD_PWM
    );


end Behavioral;
