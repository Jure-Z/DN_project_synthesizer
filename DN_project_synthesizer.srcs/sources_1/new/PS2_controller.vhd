----------------------------------------------------------------------------------
-- Krmilnik za PS/2 - glavni modul
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2_controller is
    port (
        CLK100MHZ  : in  std_logic;
        CPU_RESETN : in  std_logic;
        PS2_CLK    : in  std_logic;
        PS2_DATA   : in  std_logic;
        data       : out std_logic_vector (8 downto 0); -- vezano na LED (8 downto 0)
        eot        : out std_logic -- LED(15)
    );
end PS2_controller;

architecture Behavioral of PS2_controller is
    signal clock, reset, pulse, we : std_logic;
    signal PS2_CLK_S, PS2_DATA_S, PS2_CLK_q, PS2_DATA_q : std_logic;

begin
    clock <= CLK100MHZ;
    reset <= not CPU_RESETN;

    -- Sinhronizator za zunanja signala PS2_CLK in PS2_DATA
    ps2_synchronizer: process (clock)
    begin

        if rising_edge(clock) then
            if reset = '1' then
                PS2_CLK_q <= '1'; -- prva D celica
                PS2_CLK_S <= '1'; -- druga D celica
                PS2_DATA_q <= '1';
                PS2_DATA_S <= '1';
            else
                PS2_CLK_q <= PS2_CLK;
                PS2_CLK_S <= PS2_CLK_q;
                PS2_DATA_q <= PS2_DATA;
                PS2_DATA_S <= PS2_DATA_q;
            end if;
        end if;
    end process;

    pulse_gen: entity work.PS2_pulse_gen(Behavioral)
        port map(
            clock => clock,
            reset => reset,
            PS2_CLK_S => PS2_CLK_S,
            pulse => pulse
        );

    control_unit: entity work.PS2_control_unit(Behavioral)
        port map(
            clock => clock,
            reset => reset,
            pulse => pulse,
            PS2_DATA_S => PS2_DATA_S,
            we => we,
            eot => eot
        );

    SIPO: entity work.PS2_SIPO(Behavioral)
        port map(
            clock => clock,
            reset => reset,
            PS2_DATA_S => PS2_DATA_S,
            we => we,
            data => data
        );

end Behavioral;
