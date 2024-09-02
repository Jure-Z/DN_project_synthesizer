----------------------------------------------------------------------------------
-- Krmilna enota za PS/2 sprejemnik
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2_control_unit is
    port (
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        pulse : in STD_LOGIC;
        PS2_DATA_S : in STD_LOGIC;
        we : out STD_LOGIC;
        eot : out STD_LOGIC);
end entity;

architecture Behavioral of PS2_control_unit is

   type state_type is (
    st_idle, st_start, st_b0, st_b1, st_b2, st_b3, 
    st_b4, st_b5, st_b6, st_b7, st_par
   );
   signal state, next_state : state_type;
   
   -- Interni signali za pomnenje izhoda avtomata
   signal we_i, eot_i : std_logic;
   
begin

    SYNC_PROC: process (clock)
   begin
      if rising_edge(clock) then
         if (reset = '1') then
            state <= st_idle;
            we <= '0';
            eot <= '0';
         else
            state <= next_state;
            we <= we_i;
            eot <= eot_i;         
         end if;
      end if;
   end process;

   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, pulse, PS2_DATA_S)
   begin
      -- default
      we_i <= '0';
      eot_i <= '0';
      
      case (state) is
         when st_idle =>
            if pulse ='1' and PS2_DATA_S = '0' then 
                we_i <= '0';
                eot_i <= '0';
            end if;
         
         when st_start | st_b0 | st_b1 | st_b2 | st_b3 | st_b4 | st_b5 | st_b6 | st_b7 =>
            if pulse ='1' then 
                we_i <= '1';
                eot_i <= '0';
            end if;
            
         when st_par =>
            if pulse ='1' and PS2_DATA_S = '1' then 
                we_i <= '0';
                eot_i <= '1';
            end if; 
           
         when others => 
            we_i <= '0';
            eot_i <= '0';         
      end case;      
   end process;

   NEXT_STATE_DECODE: process (state, pulse, PS2_DATA_S)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      
      case (state) is
         when st_idle =>
            if pulse = '1' and PS2_DATA_S = '0' then
               next_state <= st_start;
            end if;
         when st_start =>
            if pulse = '1' then next_state <= st_b0; end if;
         when st_b0 =>
            if pulse = '1' then next_state <= st_b1; end if;
         when st_b1 =>
            if pulse = '1' then next_state <= st_b2; end if;
         when st_b2 =>
            if pulse = '1' then next_state <= st_b3; end if;
         when st_b3 =>
            if pulse = '1' then next_state <= st_b4; end if;
         when st_b4 =>
            if pulse = '1' then next_state <= st_b5; end if;
         when st_b5 =>
            if pulse = '1' then next_state <= st_b6; end if;   
         when st_b6 =>
            if pulse = '1' then next_state <= st_b7; end if;   
         when st_b7 =>
            if pulse = '1' then next_state <= st_par; end if;
         when st_par =>
            if pulse = '1' and PS2_DATA_S = '1' then next_state <= st_idle; end if;
         when others =>
            next_state <= st_idle;
      end case;
   end process;
end Behavioral;
