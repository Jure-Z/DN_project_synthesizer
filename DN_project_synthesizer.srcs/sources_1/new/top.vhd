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
        led : out std_logic_vector(15 downto 0);
        BTNU : in std_logic;
        BTND : in std_logic;
        BTNR : in std_logic;
        BTNL : in std_logic;
        
        --audio output
        AUD_PWM : inout std_logic;
        AUD_SD : out std_logic;
        
        --sd card pins
        SD_RESET : out STD_LOGIC;
        SD_CD : in STD_LOGIC;
        SD_CS : out STD_LOGIC;
        SD_SCLK : out STD_LOGIC;
        SD_DI : out STD_LOGIC;
        SD_DO : in STD_LOGIC;
        
        --seven_seg_display
        CA : out std_logic_vector(7 downto 0);
        AN : out std_logic_vector(7 downto 0);
        
        --tri-color_LED
        LED16 : out std_logic_vector(2 downto 0);
        
        --PS2 signals
        PS2_DATA : in STD_LOGIC;
        PS2_CLK : in STD_LOGIC
    );
end top;

architecture Behavioral of top is

    constant signal_width : integer := 8;
    constant freq_num : integer := 48;

    signal rst : std_logic;
    
    signal audio_sig_generator : unsigned(signal_width-1 downto 0);
    signal audio_sig_playback : std_logic_vector(signal_width-1 downto 0);
    signal audio_sig_out : unsigned(signal_width-1 downto 0);
    
    signal freqs : std_logic_vector(47 downto 0);
    signal value_change : std_logic;
    
    signal recording : std_logic := '0';
    signal playback : std_logic := '0';
    
    signal recording_length : std_logic_vector(31 downto 0);
    signal playback_time : std_logic_vector(31 downto 0);
    
    signal BTNU_pressed : std_logic;
    signal BTNR_pressed : std_logic;
    signal BTNL_pressed : std_logic;
    signal BTND_pressed : std_logic;
    
    signal waveform : unsigned(1 downto 0);
    
begin

    AUD_SD <= '1';

    rst <= not CPU_RESETN;
    
    SD_RESET <= rst;
    
    --freqs <= "00000000000000000000" & SW & "000000000000";
    
    signal_generator : entity work.signal_generator(Behavioral)
    generic map (
        freq_num => freq_num
    )
    port map (
        clk => CLK,
        rst => rst,
        active_freqs => freqs,
        waveform => waveform,
        audio_sig => audio_sig_generator,
        value_change => value_change
    );
    
    PWM : entity work.PWM_generator(Behavioral)
    generic map (
        pwm_bits => signal_width,
        clk_cnt_len => 1
    )
    port map (
        clk => CLK,
        rst => rst,
        duty_cycle => audio_sig_out,
        pwm_out => AUD_PWM
    );
    
    
    recorder : entity work.recorder(Behavioral)
    port map (
        clk => CLK,
        rst => rst,
        signal_in => std_logic_vector(audio_sig_generator),
        signal_out => audio_sig_playback,
        value_change => value_change,
        recording_req => recording,
        playback_req => playback,
        
        SD_RESET => SD_RESET,
        SD_CD => SD_CD,
        SD_CS => SD_CS,
        SD_SCLK => SD_SCLK,
        SD_DI => SD_DI,
        SD_DO => SD_DO,
        
        --state_out => led(3 downto 0),
        controler_state_out => led(15 downto 8),
        recording_length_out => recording_length,
        playback_time_out => playback_time
        --controler_ready => led(4),
        --controler_busy => led(5)
    );
    
    --led(6) <= recording;
    --led(7) <= playback;
    
    button_sync : entity work.ButtonSync(Behavioral)
    port map(
        clk => clk,
        rst => rst,
        BTNU => BTNU,
        BTNR => BTNR,
        BTND => BTND,
        BTNL => BTNL,
        BTNU_pressed => BTNU_pressed,
        BTNR_pressed => BTNR_pressed,
        BTND_pressed => BTND_pressed,
        BTNL_pressed => BTNL_pressed
    );
    
    audio_sig_out <= audio_sig_generator when playback = '0' else unsigned(audio_sig_playback);
    
    process(clk, rst)
    begin
    
        if rising_edge(clk) then
        
            if rst = '1' then
                recording <= '0';
                playback <= '0';
                waveform <= "00";
            else
               if BTNL_pressed = '1' and playback = '0' then
                    recording <= not recording;
               elsif BTNR_pressed = '1' and recording = '0' then
                    playback <= not playback;
               elsif BTNU_pressed = '1' then
                    waveform <= waveform + 1;
               elsif BTND_pressed = '1' then
                    waveform <= waveform - 1;
               end if;
            end if;
        
        end if;
             
    end process;
    
    
    seven_seg_display : entity work.seven_seg_display(Behavioral)
    port map(
        clock => clk,
        reset => rst,
        value_recording_length => recording_length,
        value_playback_time => playback_time,
        recording => recording,
        playback => playback,
        cathode_out => CA,
        anode_out => AN
    );
    
    tricolor_led : entity work.tricolor_led(Behavioral)
    port map(
        clk => clk,
        rst => rst,
        waveform => waveform,
        led16 => LED16
    );
    
    keyboard_controller : entity work.keyboard_controller(Behavioral)
    port map(
        PS2_DATA => PS2_DATA,
        PS2_CLK => PS2_CLK,
        RST => rst,
        CLK => clk,
        data_out => led(7 downto 0),
        freqs => freqs (47 downto 12)
    );
    

end Behavioral;
