
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity recorder is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        signal_in : in STD_LOGIC_VECTOR (7 downto 0);
        signal_out : out STD_LOGIC_VECTOR (7 downto 0);
        value_change : in std_logic;
        recording_req : in std_logic;
        playback_req : in std_logic;
        
        
        --debug signals--------------------------------------------
        state_out : out STD_LOGIC_VECTOR (3 downto 0);
        controler_state_out : out STD_LOGIC_VECTOR (7 downto 0);
        
        controler_ready : out std_logic;
        controler_busy : out std_logic;
        recording_length : out STD_LOGIC_VECTOR(7 downto 0);
        playback_length : out STD_LOGIC_VECTOR(7 downto 0);
        -----------------------------------------------------------
        
        --sd card pins---------------------------------------------
        SD_RESET : out STD_LOGIC;
        SD_CD : in STD_LOGIC;
        SD_CS : out STD_LOGIC;
        SD_SCLK : out STD_LOGIC;
        SD_DI : out STD_LOGIC;
        SD_DO : in STD_LOGIC
        -----------------------------------------------------------
    );
end recorder;

architecture Behavioral of recorder is

    ---------------------------------------------
    type state_type is (
        ST_RESET,
        ST_IDLE,
        ST_RECORDING,
        ST_FINISH_RECORDING,
        ST_STORE_LENGTH,
        ST_READ_LENGTH,
        ST_PLAYBACK,
        ST_ERROR1,
        ST_ERROR2,
        ST_ERROR3
    );
    
    signal state : state_type := ST_RESET;
    ---------------------------------------------
    
    --sd card controller communication signals--------------
    signal sd_ready : std_logic;
    signal sd_busy : std_logic;
    signal sd_addr : std_logic_vector(31 downto 0);
    signal sd_write_req : std_logic := '0';
    signal sd_read_req : std_logic := '0';
    
    signal sd_next_byte : std_logic;
    signal sd_take_byte : std_logic;
    
    signal sd_out : std_logic_vector(7 downto 0);
    signal sd_in : std_logic_vector(7 downto 0);
    signal sd_state_out : std_logic_vector(7 downto 0);
    ---------------------------------------------------------
    
    --buffer_in signals--------------------------------------
    signal b_in_data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal b_in_data_out : std_logic_vector(7 downto 0);
    signal b_in_write : std_logic := '0';
    signal b_in_shift : std_logic := '0';
    signal b_in_data_size : std_logic_vector(11 downto 0);
    signal b_in_rst : std_logic := '0';
    signal b_in_rst1 : std_logic := '0';
    ---------------------------------------------------------
    
    --buffer_out signals--------------------------------------
    signal b_out_data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal b_out_data_out : std_logic_vector(7 downto 0);
    signal b_out_write : std_logic := '0';
    signal b_out_shift : std_logic := '0';
    signal b_out_data_size : std_logic_vector(11 downto 0);
    signal b_out_rst : std_logic := '0';
    signal b_out_rst1 : std_logic := '0';
    ---------------------------------------------------------
    
    constant rec_length_addr : unsigned(31 downto 0) := x"00000FFF";
    constant start_addr : unsigned(31 downto 0) := x"00001000";
    
    signal recording_len : unsigned(31 downto 0) := (others => '0');
    signal playback_time : unsigned(31 downto 0) := (others => '0');
    
    signal sending_block : std_logic := '0';
    signal reading_block : std_logic := '0';
    
    signal playback_ready : std_logic := '0';
    signal stay_in_read : std_logic := '0';
    
    signal stored_length_byte_num : unsigned(9 downto 0) := (others => '0');
    
begin

    controler_state_out <= sd_state_out;
    recording_length <= std_logic_vector(recording_len(7 downto 0));
    playback_length <= std_logic_vector(playback_time(7 downto 0));
    
    b_in_rst1 <= b_in_rst or rst;
    b_out_rst1 <= b_out_rst or rst;
    
    state_out <= x"1" when state = ST_RESET else
                 x"2" when state = ST_IDLE else
                 x"3" when state = ST_RECORDING else
                 x"4" when state = ST_FINISH_RECORDING else
                 x"5" when state = ST_STORE_LENGTH else
                 x"6" when state = ST_PLAYBACK else
                 x"7" when state = ST_READ_LENGTH else
                 x"8" when state = ST_ERROR1 else
                 x"9" when state = ST_ERROR2 else
                 x"A" when state = ST_ERROR3 else
                 x"f";
                 
    controler_ready <= sd_ready;
    controler_busy <= sd_busy;

    sd_card_controller : entity work.sd_card_controller(Behavioral)
    port map (
        CLK => clk,
        RST => rst,
        ready => sd_ready,
        busy => sd_busy,
        
        addr => sd_addr,
        write_req => sd_write_req,
        read_req => sd_read_req,
        
        next_byte => sd_next_byte,
        take_byte => sd_take_byte,
        
        data_in => sd_in,
        data_out => sd_out,
        state_out => sd_state_out,
        
        SD_CD => SD_CD,
        SD_CS => SD_CS,
        SD_SCLK => SD_SCLK,
        SD_DI => SD_DI,
        SD_DO => SD_DO
    );
    
    signal_buffer_out : entity work.data_buffer(Behavioral)
    generic map (
        buffer_size => 1024,
        size_register_width => 12
    )
    port map (
        clk => clk,
        rst => b_out_rst1,
        data_in => b_out_data_in,
        data_out => b_out_data_out,
        write => b_out_write,
        shift => b_out_shift,
        data_size => b_out_data_size
    );
    
    signal_buffer_in : entity work.data_buffer(Behavioral)
    generic map (
        buffer_size => 1024,
        size_register_width => 12
    )
    port map (
        clk => clk,
        rst => b_in_rst1,
        data_in => b_in_data_in,
        data_out => b_in_data_out,
        write => b_in_write,
        shift => b_in_shift,
        data_size => b_in_data_size
    );
    
    
    process(clk, rst)
    begin
    
        if rising_edge(clk) then
        
            if rst = '1' then
                state <= ST_RESET;
            else
                
                case state is
                    when ST_RESET =>
                    
                        sd_write_req <= '0';
                        sd_read_req <= '0';
                        sd_addr <= (others => '0');
                        
                        b_in_data_in <= (others => '0');
                        b_in_write <= '0';
                        b_in_shift <= '0';
                        
                        b_out_write <= '0';
                        b_out_shift <= '0';
                        
                        recording_len <= (others => '0');
                        playback_time <= (others => '0');
                        sending_block <= '0';
                        
                        playback_ready <= '0';
                        
                        stored_length_byte_num <= (others => '0');
                        
                        state <= ST_IDLE;
                        
                    when ST_IDLE =>
                    
                        b_out_rst <= '0';
                        sd_write_req <= '0';
                        sd_read_req <= '0';
                    
                        if sd_ready = '1' and sd_busy = '0' then
                            
                            if recording_req = '1' then
                                sending_block <= '0';
                                recording_len <= (others => '0');
                                sd_in <= b_in_data_out;
                                state <= ST_RECORDING;
                            elsif playback_req = '1' then
                                reading_block <= '0';
                                stored_length_byte_num <= (others => '0');
                                state <= ST_READ_LENGTH;
                            end if;
                        
                        end if;
                    
                    when ST_RECORDING =>
                    
                        b_in_shift <= '0';
                        b_in_write <= '0';  
                    
                        if value_change = '1' then                    
                            b_in_data_in <= signal_in;
                            b_in_write <= '1';    
                        end if;
                        
                        if unsigned(b_in_data_size) >= 1000 then
                            state <= ST_ERROR2;
                        end if;
                        
                        if unsigned(b_in_data_size) >= 600 and sending_block = '0' then
                            if sd_ready = '1' then
                                sd_addr <= std_logic_vector(start_addr + recording_len);
                                recording_len <= recording_len + 1;
                                sd_write_req <= '1';
                                sending_block <= '1';
                            else
                                --state <= ST_ERROR1;
                            end if;
                        end if;
                        
                        
                        if sending_block = '1' then
                        
                            if sd_next_byte = '1' then
                                sd_write_req <= '0';
                                b_in_shift <= '1';
                                sd_in <= b_in_data_out;
                            end if;
                            
                            if sd_busy = '1' then
                                sending_block <= '0';
                                --b_in_shift <= '1';
                            end if;
                        
                        end if;
                        
                        
                        if recording_req = '0' and sending_block = '0' then
                            state <= ST_FINISH_RECORDING;
                        end if;
                        
                        
                    when ST_FINISH_RECORDING =>
                    
                        b_in_shift <= '0';
                        b_in_write <= '0';
                    
                        if sending_block = '0' then
                        
                            if unsigned(b_in_data_size) > 0 then
                                if sd_ready = '1' then
                                    sd_addr <= std_logic_vector(start_addr + recording_len);
                                    sd_write_req <= '1';
                                    sending_block <= '1';
                                end if;
                            else
                                stored_length_byte_num <= (others => '0');
                                state <= ST_STORE_LENGTH;
                            end if;
                        
                        else
                        
                            if sd_next_byte = '1' then
                                sd_write_req <= '0';
                                b_in_shift <= '1';
                                sd_in <= b_in_data_out;
                            end if;
                            
                            if sd_busy = '1' then
                                sending_block <= '0';
                                --b_in_shift <= '1';
                                recording_len <= recording_len + 1;
                            end if;
                        
                        end if;
                        
                        
                    when ST_STORE_LENGTH => 
                        
                        
                        if sending_block = '0' then
                        
                            if sd_ready = '1' then
                                sd_addr <= std_logic_vector(rec_length_addr);
                                sd_write_req <= '1';
                                sending_block <= '1';
                                sd_in <= std_logic_vector(recording_len(31 downto 24));
                                stored_length_byte_num <=  stored_length_byte_num + 1;
                            end if;
                            
                        else
                        
                            if sd_next_byte = '1' then
                                sd_write_req <= '0';
                                if stored_length_byte_num = 1 then
                                    sd_in <= std_logic_vector(recording_len(23 downto 16));
                                elsif stored_length_byte_num = 2 then
                                    sd_in <= std_logic_vector(recording_len(15 downto 8));
                                elsif stored_length_byte_num = 3 then
                                    sd_in <= std_logic_vector(recording_len(7 downto 0));
                                else
                                    sd_in <= "00000000";
                                end if;
                                stored_length_byte_num <= stored_length_byte_num + 1;
                            end if;
                            
                            if sd_busy = '1' then
                                sending_block <= '0';
                                state <= ST_IDLE;
                            end if;
                            
                        end if;
                        
                    
                    when ST_READ_LENGTH =>
                    
                        
                        if reading_block = '0' then
                        
                            if sd_ready = '1' then
                                sd_addr <= std_logic_vector(rec_length_addr);
                                sd_read_req <= '1';
                                reading_block <= '1';
                                stay_in_read <= '1';
                            end if;
                        
                        else
                        
                            if sd_take_byte = '1' then
                                sd_read_req <= '0';
                                if stored_length_byte_num = 0 then
                                    recording_len(31 downto 24) <= unsigned(sd_out);
                                elsif stored_length_byte_num = 1 then
                                    recording_len(23 downto 16) <= unsigned(sd_out);
                                elsif stored_length_byte_num = 2 then
                                    recording_len(15 downto 8) <= unsigned(sd_out);
                                elsif stored_length_byte_num = 3 then
                                    recording_len(7 downto 0) <= unsigned(sd_out);
                                end if;
                                stored_length_byte_num <= stored_length_byte_num + 1;
                                stay_in_read <= '0';
                            end if;
                            
                            if sd_ready = '1' and stay_in_read = '0' then
                                reading_block <= '0';
                                playback_time <= (others => '0');
                                playback_ready <= '0';
                                state <= ST_PLAYBACK;
                            end if;
                            
                        end if;
                        
                        
                    when ST_PLAYBACK =>
                    
                        b_out_shift <= '0';
                        b_out_write <= '0';
                        
                        if playback_ready = '1' then
                            if value_change = '1' then
                                if unsigned(b_out_data_size) > 0 then
                                    signal_out <= b_out_data_out;
                                    b_out_shift <= '1';
                                elsif playback_time > recording_len then
                                    state <= ST_IDLE;
                                else
                                    state <= ST_ERROR3;
                                end if; 
                            end if;
                        end if;
                        
                        if reading_block = '0' then
                        
                            if playback_req = '0' then
                                b_out_rst <= '1';
                                state <= ST_IDLE;
                            end if;
                        
                            if unsigned(b_out_data_size) <= 128 then
                                if playback_time <= recording_len then
                                    if sd_ready = '1' then
                                        sd_addr <= std_logic_vector(start_addr + playback_time);
                                        sd_read_req <= '1';
                                        reading_block <= '1';
                                        stay_in_read <= '1';
                                    end if;
                                end if;
                            end if;
                            
                        else
                        
                            if sd_take_byte = '1' then
                                sd_read_req <= '0';
                                b_out_data_in <= sd_out;
                                b_out_write <= '1';
                                stay_in_read <= '0';     
                            end if;
                            
                            if sd_ready = '1' and stay_in_read = '0' then
                                reading_block <= '0';
                                playback_ready <= '1';
                                playback_time <= playback_time + 1;
                            end if;
                        
                        end if;
                                         
                    
                    when ST_ERROR1 =>
                    when ST_ERROR2 =>
                    when ST_ERROR3 =>
                    
                    when others =>
                    
                        state <= ST_RESET;
                        
                end case;
            
            end if;
        
        end if;
             
    end process;


end Behavioral;
