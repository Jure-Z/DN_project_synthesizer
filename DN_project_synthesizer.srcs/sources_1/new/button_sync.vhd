library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ButtonSync is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        BTNU    : in  std_logic;
        BTNR    : in  std_logic;
        BTNU_sync : out std_logic;
        BTNR_sync : out std_logic;
        BTNU_pressed : out std_logic;
        BTNR_pressed : out std_logic
    );
end ButtonSync;

architecture Behavioral of ButtonSync is
    signal BTNU_ff1, BTNU_ff2 : std_logic;
    signal BTNR_ff1, BTNR_ff2 : std_logic;
begin
    -- Two-stage synchronizer for BTNU
    process (clk, rst)
    begin
        if rst = '1' then
            BTNU_ff1 <= '0';
            BTNU_ff2 <= '0';
        elsif rising_edge(clk) then
            BTNU_ff1 <= BTNU;
            BTNU_ff2 <= BTNU_ff1;
        end if;
    end process;

    -- Two-stage synchronizer for BTNR
    process (clk, rst)
    begin
        if rst = '1' then
            BTNR_ff1 <= '0';
            BTNR_ff2 <= '0';
        elsif rising_edge(clk) then
            BTNR_ff1 <= BTNR;
            BTNR_ff2 <= BTNR_ff1;
        end if;
    end process;

    -- Assign synchronized outputs
    BTNU_sync <= BTNU_ff2;
    BTNR_sync <= BTNR_ff2;

    -- Edge detection for button press
    BTNU_pressed <= BTNU_ff2 and not BTNU_ff1;
    BTNR_pressed <= BTNR_ff2 and not BTNR_ff1;

end Behavioral;