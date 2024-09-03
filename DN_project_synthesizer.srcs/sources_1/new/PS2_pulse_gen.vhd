----------------------------------------------------------------------------------
-- Generator pulza ob detekciji negativne fronte na signalu ure naprave PS2 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2_pulse_gen is
    port (
        clock : in std_logic;
        reset : in std_logic;
        PS2_CLK_S : in STD_LOGIC;
        pulse : out STD_LOGIC);
end PS2_pulse_gen;

architecture Behavioral of PS2_pulse_gen is
    -- STANJA 
	-- Definiramo nov "steven" podatkovni tip (enumerated type).
	-- Orodje za sintezo izbere najboljsi nacin kodiranja stanj
    type state_type is (st1_idle, st2_active, st3_wait);

    -- Singali za trenutno (s(t)) in naslednje stanje (s(t+1))
    signal state, next_state : state_type;

    -- Notranji signal za pomnenje izhoda pulse
    signal pulse_i : std_logic;

begin

    -- REGISTER STANJA
	-- Pomnilno vezje, ki vsako urino fronto osvezuje 
	-- stanje avtomata, s(t) <= s(t+1), in skrbi tudi za pomnjenje izhoda,
	-- da se prepreci pojav napetostnih konic (trava, ang. glitches).
    SYNC_PROC: process (clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                state <= st1_idle;
                pulse <= '0';
            else
                state <= next_state;
                pulse <= pulse_i;
            end if;
        end if;
    end process;

    -- MOORE State-Machine - Outputs based on state only
    -- Izhodna logika (odlocitveno vezje)
    OUTPUT_DECODE: process (state)
    begin
        case (state) is
            when st1_idle =>
                pulse_i <= '0';
            when st2_active =>
                pulse_i <= '1';
            when st3_wait =>
                pulse_i <= '0';
            when others =>
                pulse_i <= '0';
        end case;
    end process;

    -- Logika prehajanja stanj
    -- Naslednje stanje je odvisno od trenutnega stanja in vhoda
    NEXT_STATE_DECODE: process (state, PS2_CLK_S)
    begin
        -- Privzeto ostanemo v istem stanju.
		-- S tem stavkom se elegantno resimo "else" dela stavkov if spodaj.
        next_state <= state;  --default is to stay in current state
        -- Sedaj pokrijemo samo tiste primere, ko stanje spremenimo.     
        case (state) is
            when st1_idle =>
                if PS2_CLK_S = '0' then
                    next_state <= st2_active;
                end if;

            when st2_active =>
                -- Vedno gremo v naslednje stanje
                next_state <= st3_wait;

            when st3_wait =>
                if PS2_CLK_S = '1' then
                    next_state <= st1_idle;
                end if;

            when others =>
                next_state <= st1_idle;
        end case;
    end process;
end Behavioral;
