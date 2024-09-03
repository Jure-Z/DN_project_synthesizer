
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2_keyStateMapper is
    Port ( data : in STD_LOGIC_VECTOR (7 downto 0);
           eot : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           freqs : out STD_LOGIC_VECTOR (35 downto 0));
end PS2_keyStateMapper;

architecture Behavioral of PS2_keyStateMapper is

    signal freq_register : std_logic_vector (35 downto 0) := (others => '0');
    signal keyUp : std_logic := '0';

    type state_type is (Idle, Key_Up_Detected);
    signal state : state_type := Idle;
    signal oldEot : std_logic := '0';

begin

freqs <= freq_register;

KeyStateProcess : process(CLK, RST)
begin
    if RST = '1' then
        freq_register <= (others => '0');
        keyUp <= '0';
        state <= Idle;
        oldEot <= '0';
    elsif rising_edge(CLK) then
        if oldEot = '0' and eot = '1' then
            case state is
                when Idle =>
                    if data = x"F0" then
                        state <= Key_Up_Detected;
                    else
                        -- set key to active
                        keyUp <= '0'; -- clear keyUp if setting a key to active
                        case data is
                            when x"15" => freq_register(0) <= '1';
                            when x"1E" => freq_register(1) <= '1';
                            when x"1D" => freq_register(2) <= '1';
                            when x"26" => freq_register(3) <= '1';
                            when x"24" => freq_register(4) <= '1';
                            when x"2D" => freq_register(5) <= '1';
                            when x"2E" => freq_register(6) <= '1';
                            when x"2C" => freq_register(7) <= '1';
                            when x"36" => freq_register(8) <= '1';
                            when x"35" => freq_register(9) <= '1';
                            when x"3D" => freq_register(10) <= '1';
                            when x"3C" => freq_register(11) <= '1';
                            when x"43" => freq_register(12) <= '1';
                            when x"46" => freq_register(13) <= '1';
                            when x"44" => freq_register(14) <= '1';
                            when x"45" => freq_register(15) <= '1';
                            when x"4D" => freq_register(16) <= '1';
                            when x"1A" => freq_register(17) <= '1';
                            when x"1B" => freq_register(18) <= '1';
                            when x"22" => freq_register(19) <= '1';
                            when x"23" => freq_register(20) <= '1';
                            when x"21" => freq_register(21) <= '1';
                            when x"2B" => freq_register(22) <= '1';
                            when x"2A" => freq_register(23) <= '1';
                            when x"32" => freq_register(24) <= '1';
                            when x"33" => freq_register(25) <= '1';
                            when x"31" => freq_register(26) <= '1';
                            when x"3B" => freq_register(27) <= '1';
                            when x"3A" => freq_register(28) <= '1';
                            when x"41" => freq_register(29) <= '1';
                            when x"4B" => freq_register(30) <= '1';
                            when x"49" => freq_register(31) <= '1';
                            when x"4C" => freq_register(32) <= '1';
                            when x"4A" => freq_register(33) <= '1';
                            when x"52" => freq_register(34) <= '1';
                            when x"59" => freq_register(35) <= '1';
                            when others => null;
                        end case;
                    end if;
                    
                when Key_Up_Detected =>
                    -- reset the unpressed key
                    keyUp <= '1'; -- set keyUp when F0 is detected
                    case data is
                        when x"15" => freq_register(0) <= '0';
                        when x"1E" => freq_register(1) <= '0';
                        when x"1D" => freq_register(2) <= '0';
                        when x"26" => freq_register(3) <= '0';
                        when x"24" => freq_register(4) <= '0';
                        when x"2D" => freq_register(5) <= '0';
                        when x"2E" => freq_register(6) <= '0';
                        when x"2C" => freq_register(7) <= '0';
                        when x"36" => freq_register(8) <= '0';
                        when x"35" => freq_register(9) <= '0';
                        when x"3D" => freq_register(10) <= '0';
                        when x"3C" => freq_register(11) <= '0';
                        when x"43" => freq_register(12) <= '0';
                        when x"46" => freq_register(13) <= '0';
                        when x"44" => freq_register(14) <= '0';
                        when x"45" => freq_register(15) <= '0';
                        when x"4D" => freq_register(16) <= '0';
                        when x"1A" => freq_register(17) <= '0';
                        when x"1B" => freq_register(18) <= '0';
                        when x"22" => freq_register(19) <= '0';
                        when x"23" => freq_register(20) <= '0';
                        when x"21" => freq_register(21) <= '0';
                        when x"2B" => freq_register(22) <= '0';
                        when x"2A" => freq_register(23) <= '0';
                        when x"32" => freq_register(24) <= '0';
                        when x"33" => freq_register(25) <= '0';
                        when x"31" => freq_register(26) <= '0';
                        when x"3B" => freq_register(27) <= '0';
                        when x"3A" => freq_register(28) <= '0';
                        when x"41" => freq_register(29) <= '0';
                        when x"4B" => freq_register(30) <= '0';
                        when x"49" => freq_register(31) <= '0';
                        when x"4C" => freq_register(32) <= '0';
                        when x"4A" => freq_register(33) <= '0';
                        when x"52" => freq_register(34) <= '0';
                        when x"59" => freq_register(35) <= '0';
                        when others => null;
                    end case;
                    keyUp <= '0'; -- clear keyUp and return to idle state
                    state <= Idle;
                    
            end case;
        end if;
    oldEot <= eot;
    end if;
    
end process;

end Behavioral;