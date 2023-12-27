----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2023 17:58:50
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
    constant clk_period : time := 10 ns;    
    signal CLK100MHZ, CPU_RESETN, AUD_PWM : std_logic;
    signal SW : std_logic_vector(15 downto 0);
    signal AUD_SD : std_logic;
    
begin
    
    uut: entity work.top(Behavioral)
    port map(
        CLK => CLK100MHZ,
        CPU_RESETN => CPU_RESETN,
        SW => SW,
        AUD_PWM => AUD_PWM,
        AUD_SD => AUD_SD
    ); 
    
    stimulus_clk: process
    begin 
        CLK100MHZ <= '0';
        wait for clk_period/2;
        CLK100MHZ <= '1';
        wait for clk_period/2;    
    end process;
    
    process
    begin
        
        SW <= (others => '0');
        CPU_RESETN <= '1';
    
        wait for clk_period*20;
        SW <= "1000010001000000";
        wait for clk_period*2000000;
        CPU_RESETN <= '0';
        wait;
    
    end process;

end Behavioral;
