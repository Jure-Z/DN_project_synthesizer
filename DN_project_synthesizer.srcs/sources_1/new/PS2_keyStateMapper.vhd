
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
    --signal dataInverted : std_logic_vector (7 downto 0); --obrnjen data vector zaradi primerjave kod tipkovnice in načina pošiljanja kod
    
    signal oldEot : std_logic := '0';
begin

freqs <= freq_register;
--dataInverted <= data(0 to 7);

KeyStateProcess : process(CLK, RST)
    begin
      if RST='1' then
        freq_register <= (others => '0');
        keyUp <= '0';
        oldEot <= '0';
      else
        if rising_edge(CLK) then
            if oldEot = '0' and eot = '1' then   
        
     
            case (data) is 
                when x"F0" =>
                    keyUp <= '1';
                    
                when x"15" =>
                    if keyUp='1' then
                        freq_register(0) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(0) <= '1';
                    end if;
       
                when x"1E" =>
                    if keyUp='1' then
                        freq_register(1) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(1) <= '1';
                    end if;
                    
                when x"1D" =>
                    if keyUp='1' then
                        freq_register(2) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(2) <= '1';
                    end if;
                    
                when x"26" =>
                    if keyUp='1' then
                        freq_register(3) <= '0';  
                        keyUp <= '0';

                    else
                        freq_register(3) <= '1';
                    end if;
                    
                when x"24" =>
                    if keyUp='1' then
                        freq_register(4) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(4) <= '1';
                    end if;
                
                when x"2D" =>
                    if keyUp='1' then
                        freq_register(5) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(5) <= '1';
                    end if;
                
                when x"2E" =>
                    if keyUp='1' then
                        freq_register(6) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(6) <= '1';
                    end if;
                    
                when x"2C" =>
                    if keyUp='1' then
                        freq_register(7) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(7) <= '1';
                    end if;
                    
                when x"36" =>
                    if keyUp='1' then
                        freq_register(8) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(8) <= '1';
                    end if;
                    
                when x"35" =>
                    if keyUp='1' then
                        freq_register(9) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(9) <= '1';
                    end if;
                    
                when x"3D" =>
                    if keyUp='1' then
                        freq_register(10) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(10) <= '1';
                    end if;
                    
                when x"3C" =>
                    if keyUp='1' then
                        freq_register(11) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(11) <= '1';
                    end if;
                    
                when x"43" =>
                    if keyUp='1' then
                        freq_register(12) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(12) <= '1';
                    end if;
                    
                when x"46" =>
                    if keyUp='1' then
                        freq_register(13) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(13) <= '1';
                    end if;
                    
                when x"44" =>
                    if keyUp='1' then
                        freq_register(14) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(14) <= '1';
                    end if;
                    
                when x"45" =>
                    if keyUp='1' then
                        freq_register(15) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(15) <= '1';
                    end if;
                    
                when x"4D" =>
                    if keyUp='1' then
                        freq_register(16) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(16) <= '1';
                    end if;
                    
                when x"1A" =>
                    if keyUp='1' then
                        freq_register(17) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(17) <= '1';
                    end if;
                    
                when x"1B" =>
                    if keyUp='1' then
                        freq_register(18) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(18) <= '1';
                    end if;
                    
                when x"22" =>
                    if keyUp='1' then
                        freq_register(19) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(19) <= '1';
                    end if;
                    
                when x"23" =>
                    if keyUp='1' then
                        freq_register(20) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(20) <= '1';
                    end if;            
                
                when x"21" =>
                    if keyUp='1' then
                        freq_register(21) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(21) <= '1';
                    end if;
                
                when x"2B" =>
                    if keyUp='1' then
                        freq_register(22) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(22) <= '1';
                    end if;        
                
                when x"2A" =>
                    if keyUp='1' then
                        freq_register(23) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(23) <= '1';
                    end if;    
                    
                when x"32" =>
                    if keyUp='1' then
                        freq_register(24) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(24) <= '1';
                    end if;    
                
                when x"33" =>
                    if keyUp='1' then
                        freq_register(25) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(25) <= '1';
                    end if;    
                
                when x"31" =>
                    if keyUp='1' then
                        freq_register(26) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(26) <= '1';
                    end if;
                        
                when x"3B" =>
                    if keyUp='1' then
                        freq_register(27) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(27) <= '1';
                    end if;    
                
                when x"3A" =>
                    if keyUp='1' then
                        freq_register(28) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(28) <= '1';
                    end if;    
                    
                when x"41" =>
                    if keyUp='1' then
                        freq_register(29) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(29) <= '1';
                    end if;    
                
                when x"4B" =>
                    if keyUp='1' then
                        freq_register(30) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(30) <= '1';
                    end if;
                        
                when x"49" =>
                    if keyUp='1' then
                        freq_register(31) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(31) <= '1';
                    end if;
                    
                when x"4C" =>
                    if keyUp='1' then
                        freq_register(32) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(32) <= '1';
                    end if;    
                    
                when x"4A" =>
                    if keyUp='1' then
                        freq_register(33) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(33) <= '1';
                    end if;    
                    
                when x"52" =>
                    if keyUp='1' then
                        freq_register(34) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(34) <= '1';
                    end if;    
                    
                when x"59" =>
                    if keyUp='1' then
                        freq_register(35) <= '0';
                        keyUp <= '0';
                    else
                        freq_register(35) <= '1';
                    end if;    
                    
                when others =>
                    keyUp <= '0';
            end case;
        end if;
      end if;
      
      oldEot <= eot;
      end if;
    end process;



end Behavioral;
