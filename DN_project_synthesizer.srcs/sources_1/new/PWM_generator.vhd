----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2023 12:35:47
-- Design Name: 
-- Module Name: PWM_generator - Behavioral
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

entity PWM_generator is
  generic (
    pwm_bits : integer;
    clk_cnt_len : positive := 1
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    duty_cycle : in unsigned(pwm_bits - 1 downto 0);
    pwm_out : inout std_logic
  );
end PWM_generator;

architecture Behavioral of PWM_generator is

    signal pwm_cnt : unsigned(pwm_bits - 1 downto 0) := (others => '0');
    signal clk_cnt : integer range 0 to clk_cnt_len - 1;

begin

    CLK_CNT_PROC : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          clk_cnt <= 0;    
        else
          if clk_cnt < clk_cnt_len - 1 then
            clk_cnt <= clk_cnt + 1;
          else
            clk_cnt <= 0;
          end if;
           
        end if;
      end if;
    end process;
    
    
    PWM_PROC : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          pwm_cnt <= (others => '0');
          pwm_out <= '0';
     
        else
          if clk_cnt_len = 1 or clk_cnt = 0 then
     
            pwm_cnt <= pwm_cnt + 1;
            pwm_out <= '0';
     
            if pwm_cnt = unsigned(to_signed(-2, pwm_cnt'length)) then
              pwm_cnt <= (others => '0');
            end if;
     
            if pwm_cnt < duty_cycle then
              pwm_out <= 'Z';
            end if;
     
          end if;
        end if;
      end if;
    end process;


end Behavioral;
