----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.12.2023 13:57:16
-- Design Name: 
-- Module Name: signal_generator - Behavioral
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

entity signal_generator is
    generic (
        freq_num : integer := 48;
        signal_width : integer := 8
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        active_freqs : in std_logic_vector(freq_num -1 downto 0);
        waveform : in unsigned(1 downto 0);
        audio_sig : out unsigned(signal_width-1 downto 0);
        value_change : out std_logic
    );
end signal_generator;

architecture Behavioral of signal_generator is

    constant prescaler_max : integer := 12207; --24414
    constant prescaler_limit : integer := 12207; --24414
    
    constant counter_width : integer := 25; --12
    
    constant wait_time_freq  : integer := 4;
    constant wait_time_final  : integer := 16;
    

    signal CE_time : std_logic;
    signal cnt_time : unsigned(counter_width-1 downto 0);
    
    signal active_freq : unsigned(5 downto 0) := (others => '0');
    
    signal sine_signal : signed(signal_width downto 0);
    
    signal combined_signal : signed(6 + signal_width downto 0) := (others => '0');
    signal combined_signal_unsigned : unsigned(6 + signal_width downto 0) := (others => '0');
    signal count_freqs : integer range 0 to freq_num := 0;
    
    signal wait_count_freq : integer range 0 to wait_time_freq := 0;
    signal wait_count_final : integer range 0 to wait_time_final := 0;
    
    ------------------------------------------------------------------------------------
    
    type state_type is ( ST_RESET, ST_IDLE, ST_ITERATE_FREQS, ST_WAIT_FREQ , ST_WAIT_FINAL, ST_OUTPUT );

    signal state : state_type := ST_RESET;

begin

    prescaler : entity work.prescaler(Behavioral)
    generic map (
        max_count => prescaler_max
    )
    port map (
        clock => CLK,
        reset => rst,
        limit => prescaler_limit,
        clock_enable => CE_time
    );
    
    counter : entity work.counter(Behavioral)
    generic map(width => counter_width)
    port map(
        clock => CLK,
        reset => rst,
        clock_enable => CE_time,
        count_up => '1',
        count_down => '0',
        value => cnt_time
    );
   
    
    single_signal_generator : entity work.single_signal_generator(Behavioral)
    generic map (
        signal_width => signal_width,
        time_counter_width => counter_width
    )
    port map(
        freq_idx => active_freq,
        time_counter => cnt_time,
        waveform => waveform,
        sine_signal => sine_signal
    );
    
        
    signal_generator : process(clk, rst)
    begin
        if rst = '1' then
            audio_sig <= (others => '0');
            state <= ST_RESET;
        elsif rising_edge(clk) then
        
            value_change <= '0';
        
            case state is
                when ST_RESET =>
                
                    combined_signal <= (others => '0');
                    value_change <= '0';    
                    
                    state <= ST_IDLE;
                    
                when ST_IDLE =>
                
                    if CE_time = '1' then
                        active_freq <= (others => '0');
                        count_freqs <= 0;
                        wait_count_freq <= 0;
                        
                        state <= ST_WAIT_FREQ;
                    end if;
                
                when ST_WAIT_FREQ =>
                
                    if wait_count_freq >= wait_time_freq then
                        state <= ST_ITERATE_FREQS;
                    else
                        wait_count_freq <= wait_count_freq + 1;
                    end if;
                
                when ST_ITERATE_FREQS =>
                
                    if active_freq = to_unsigned(freq_num, 6) then
                        wait_count_final <= 0;
                        state <= ST_WAIT_FINAL;
                        
                        if count_freqs = 0 then
                            combined_signal_unsigned <= (others => '0');
                        elsif count_freqs < 5 then
                            combined_signal_unsigned <= unsigned((combined_signal / 4) + 128);
                        else
                            combined_signal_unsigned <= unsigned((combined_signal / count_freqs) + 128);
                        end if;       
                    else                   
                        if active_freqs(to_integer(active_freq)) = '1' then
                            combined_signal <= combined_signal + sine_signal;
                            count_freqs <= count_freqs + 1;
                        end if;
                        
                        active_freq <= active_freq + 1;
                        wait_count_freq <= 0;
                        
                        state <= ST_WAIT_FREQ;
                    end if;
                
                when ST_WAIT_FINAL =>
                
                    if wait_count_final >= wait_time_final then
                        state <= ST_OUTPUT;
                    else
                        wait_count_final <= wait_count_final + 1;
                    end if;
                
                
                when ST_OUTPUT =>
                    audio_sig <= combined_signal_unsigned(signal_width-1 downto 0);
                    value_change <= '1';   
                    state <= ST_RESET;
                    
                             
                when others =>
                    state <= ST_RESET;
            end case;
        end if;
    end process;
    
    
    
--    signal_generator : process(clk, rst)
--    begin
--        if rst = '1' then
--            combined_signal <= (others => '0');
--            active_freq <= (others => '0');
--            audio_sig <= (others => '0');
--        elsif rising_edge(clk) then
--            if CE_time = '1' then
--                iterate_freqs <= '1';
--                count_freqs <= 0;
--                active_freq <= (others => '0');
--                combined_signal <= (others => '0');        
--            elsif iterate_freqs = '1' and CE2 = '1' then
--                if active_freqs(to_integer(active_freq)) = '1' then
--                    combined_signal <= combined_signal + sine_signal;
--                    count_freqs <= count_freqs + 1;
--                end if;
                      
--                if active_freq = to_unsigned(freq_num-1, 6) then
--                    combined_signal <= combined_signal / count_freqs;
--                    audio_sig <= combined_signal(signal_width-1 downto 0);
--                    iterate_freqs <= '0';
--                    enable_sine <= '0';
--                else
--                    active_freq <= active_freq + 1;
--                end if;
--            end if;
--        end if;
--    end process;
    


end Behavioral;
