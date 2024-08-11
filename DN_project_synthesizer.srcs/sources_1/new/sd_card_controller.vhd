----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.01.2024 14:05:39
-- Design Name: 
-- Module Name: cd_card_controller - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sd_card_controller is
  Port (
    CLK : in std_logic;
    RST : in std_logic;
    
    ready : out std_logic; --controller is ready
    busy : out std_logic; --controller is processing command
    
    addr : in std_logic_vector(31 downto 0); --address to read from / write to
    write_req : in std_logic; --initiate write request when controller is ready
    read_req : in std_logic; --initiate read request when controller is ready
    
    next_byte : out std_logic; --is one when controller is ready for next byte of data
    take_byte : out std_logic; --is one when new byte of data is ready to be taken
    
    data_in : in STD_LOGIC_VECTOR(7 downto 0);
    data_out : out STD_LOGIC_VECTOR(7 downto 0);
    state_out : out STD_LOGIC_VECTOR(7 downto 0); --state of controller (for debugging)
    
    --SD card PINS
    SD_CD : in STD_LOGIC;
    SD_CS : out STD_LOGIC;
    SD_SCLK : out STD_LOGIC;
    SD_DI : out STD_LOGIC;
    SD_DO : in STD_LOGIC
    
    );
    
end sd_card_controller;

architecture Behavioral of sd_card_controller is

    type state_type is (
        ST_RESET,
        ST_WAIT_SD,
        ST_START_INIT,
        ST_CMD0,
        ST_CMD0_RESPONSE,
        ST_CMD8,
        ST_CMD8_RESPONSE,
        ST_CMD55,
        ST_CMD55_RESPONSE,
        ST_CMD41,
        ST_CMD41_RESPONSE,
        ST_CMD58,
        ST_CMD58_RESPONSE,
        ST_CMD16,
        ST_CMD16_RESPONSE,
        ST_WAIT_RW_REQ,
        ST_READ_START,
        ST_READ_RESPONSE,
        ST_RECEIVE_PACKET,
        ST_WRITE_START,
        ST_WRITE_RESPONSE,
        ST_SEND_PACKET,
        ST_WAIT_DATA_RESPONSE,
        ST_SD_BUSY,
        ST_SEND_CMD,
        ST_WAIT_CMD_RESPONSE,
        ST_ERROR,
        ST_ERROR1,
        ST_ERROR2,
        ST_ERROR3,
        ST_ERROR4,
        ST_ERROR5
    );
    
    signal state : state_type := ST_RESET; --current state
    signal rtn_state : state_type := ST_RESET; --state to return to after command response
       
    constant SCLK_division_rate_SLOW : integer := 250; --100MHz / 250 = 400kHz (sclk during init)
    constant SCLK_division_rate_FAST : integer := 5; --100MHz / 5 = 25MHz (sclk during read / write)
    constant block_size : integer := 512;
    
    signal SCLK_division_rate : integer range 0 to SCLK_division_rate_SLOW := SCLK_division_rate_SLOW; --current SCLK
    
    signal SCLK : std_logic; -- serial clock
    signal SCLK_pos_edge : std_logic; --impulse when SCLK has positive edge
    signal SCLK_neg_edge : std_logic; --impulse when SCLK has negative edge
    signal enable_SCLK : std_logic := '0'; --is SCLK enabled (passed to SD card)
    
    constant sd_startup_time : integer := 100000; --wait for SD card to finish setup
    constant init_tick_count : integer := 80; --(min 74) num of SCLK ticks, so that card enters native state
    
    signal sd_startup_timer : integer range 0 to sd_startup_time := 0;
    signal tick_counter : integer range 0 to init_tick_count := 0;
    
    --commands
    constant command_len : integer := 48;
    constant cmd_0 : std_logic_vector(5 downto 0) := "000000";
    constant cmd_8 : std_logic_vector(5 downto 0) := "001000";
    constant cmd_55 : std_logic_vector(5 downto 0) := "110111";
    constant cmd_41 : std_logic_vector(5 downto 0) := "101001";
    constant cmd_58 : std_logic_vector(5 downto 0) := "111010";
    constant cmd_16 : std_logic_vector(5 downto 0) := "010000";
    constant cmd_READ : std_logic_vector(5 downto 0) := "010001"; --CMD17
    constant cmd_WRITE : std_logic_vector(5 downto 0) := "011000"; --CMD24
    
    constant cmd_response_len1 : integer := 8; --commad response of format R1
    constant cmd_response_len7 : integer := 40; --commad response of format R7 or R3
    constant data_response_len : integer := 8; --response message to data packet
    
    signal command : std_logic_vector(command_len - 1 downto 0); --full commad to send to SD card
    signal bits_to_send : integer range 0 to command_len := 0; --remaining bits to be sent
    signal expect_response : std_logic := '0'; --should the controller enter ST_WAIT_CMD_RESPONSE after sending command
    signal response_format : std_logic := '0'; --response format that ST_WAIT_CMD_RESPONSE should expect
    
    signal cmd_response1 : std_logic_vector(cmd_response_len1 - 1 downto 0); --response is stored here if R1
    signal cmd_response7 : std_logic_vector(cmd_response_len7 - 1 downto 0); --response is stored here if R7 or R3
    signal data_response : std_logic_vector(data_response_len - 1 downto 0) := "11111111";
    
    signal bits_to_receive : integer range 0 to cmd_response_len7 := 0; --remaining bits to be received
    signal waiting_for_response : std_logic := '0'; --ST_WAIT_CMD_RESPONSE waits until value on SD_DO is '0' (start of response message)
    
    signal wait_before_write_packet : integer range 0 to 32 := 0; --wait some ticks before sending the data packet for WRITE command
    
    signal bytes_to_send : integer range 0 to block_size := block_size;
    signal crc_bits_to_send : integer range 0 to 16 := 16;
    signal bytes_to_receive : integer range 0 to block_size := block_size;
    
    signal byte_register_out : std_logic_vector(7 downto 0);
    signal byte_register_in : std_logic_vector(7 downto 0);

begin

    state_out <= x"01" when state = ST_RESET else
                 x"02" when state = ST_WAIT_SD else
                 x"03" when state = ST_START_INIT else
                 x"04" when state = ST_CMD0 else
                 x"05" when state = ST_CMD0_RESPONSE else
                 x"06" when state = ST_CMD8 else
                 x"07" when state = ST_CMD8_RESPONSE else
                 x"08" when state = ST_CMD55 else
                 x"09" when state = ST_CMD41 else
                 x"0a" when state = ST_CMD41_RESPONSE else
                 x"0b" when state = ST_WAIT_RW_REQ else
                 x"0c" when state = ST_READ_START else
                 x"0d" when state = ST_READ_RESPONSE else
                 x"0e" when state = ST_RECEIVE_PACKET else
                 x"0f" when state = ST_WRITE_START else
                 x"10" when state = ST_WRITE_RESPONSE else
                 x"11" when state = ST_SEND_PACKET else
                 x"12" when state = ST_WAIT_DATA_RESPONSE else
                 x"13" when state = ST_SEND_CMD else
                 x"14" when state = ST_WAIT_CMD_RESPONSE else
                 x"15" when state = ST_CMD41 else
                 x"16" when state = ST_CMD41_RESPONSE else
                 x"17" when state = ST_ERROR else
                 x"18" when state = ST_ERROR1 else
                 x"19" when state = ST_ERROR2 else
                 x"1A" when state = ST_ERROR3 else
                 x"1B" when state = ST_ERROR4 else
                 x"1C" when state = ST_ERROR5 else
                 x"ff";
                 

    SCLK_clock_divider : entity work.clock_divider(Behavioral)
    generic map (
        division_rate_max => SCLK_division_rate_SLOW
    )
    port map (
        clk => CLK,
        reset => RST,
        division_rate => SCLK_division_rate,
        clock_out => SCLK,
        pos_edge => SCLK_pos_edge,
        neg_edge => SCLK_neg_edge
    );
    
    SD_SCLK <= SCLK when enable_SCLK = '1' else '0';
    

    process(CLK)
    begin
        
        if rising_edge(CLK) then
            
            if RST = '1' or SD_CD = '1' then
                state <= ST_RESET;
            else
            
                case state is
                
                    when ST_RESET => 
                        ready <= '0';
                        busy <= '0';
                        SD_DI <= '0';
                        SD_CS <= '1';
                        tick_counter <= 0;
                        sd_startup_timer <= 0;
                        SCLK_division_rate <= SCLK_division_rate_SLOW;
                        crc_bits_to_send <= 0;
                        state <= ST_WAIT_SD;
                        
                        take_byte <= '0';
                        next_byte <= '0';
                                                
                        data_out <= (others => '0');
                        cmd_response1 <= (others => '0');
                        cmd_response7 <= (others => '0');
                        
                    when ST_WAIT_SD => 
                        
                        if sd_startup_timer >= sd_startup_time then
                            enable_SCLK <= '1';
                            state <= ST_START_INIT;
                        else
                            sd_startup_timer <= sd_startup_timer + 1;
                        end if;
                        
                    when ST_START_INIT => 
                        
                        SD_CS <= '1';
                        SD_DI <= '1';
                        
                        if SCLK_neg_edge = '1' then
                            tick_counter <= tick_counter + 1;
                            
                            if tick_counter = init_tick_count then
                                state <= ST_CMD0;
                            end if;
                        end if;
                           
                    when ST_CMD0 =>
                    
                        SD_CS <= '0';
                        command <= "01" & cmd_0 & x"00000000" & x"95";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '0';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_CMD0_RESPONSE;
                        
                    when ST_CMD0_RESPONSE =>
                        
                        if cmd_response1 = x"01" then
                            state <= ST_CMD8;
                        else
                            state <= ST_CMD0;
                        end if;
                        
                    when ST_CMD8 =>
                    
                        command <= "01" & cmd_8 & x"000001aa" & x"87";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '1';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_CMD8_RESPONSE;
                        
                        
                    when ST_CMD8_RESPONSE => 
                    
                        if cmd_response7(11 downto 0) = x"1AA" then
                            state <= ST_CMD55;
                        else
                            state <= ST_ERROR;
                        end if;
                    
                    when ST_CMD55 =>
                    
                        command <= "01" & cmd_55 & x"00000000" & x"FF";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '0';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_CMD41;
                    
                    when ST_CMD41 => 
                    
                        command <= "01" & cmd_41 & x"40000000" & x"FF";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '0';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_CMD41_RESPONSE;
                        
                    when ST_CMD41_RESPONSE => 
                    
                        if cmd_response1 = x"00" then
                            SCLK_division_rate <= SCLK_division_rate_FAST;
                            state <= ST_CMD16;
                        elsif cmd_response1 = x"01" then
                            state <= ST_CMD55;
                        else
                            state <= ST_ERROR;
                        end if;
                        
                    when ST_CMD16 => 
                    
                        command <= "01" & cmd_16 & x"00000200" & x"FF";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '0';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_CMD16_RESPONSE;
                        
                    when ST_CMD16_RESPONSE => 
                        
                        if cmd_response1 = x"00" then
                            state <= ST_WAIT_RW_REQ;
                        else
                            state <= ST_ERROR4;
                        end if;
                            
                    when ST_WAIT_RW_REQ => 
                        
                        take_byte <= '0';
                        next_byte <= '0';
                        busy <= '0';
                        ready <= '1';
                        
                        if read_req = '1' then
                            ready <= '0';
                            state <= ST_READ_START;
                        elsif write_req = '1' then
                            ready <= '0';
                            state <= ST_WRITE_START;
                        end if;
                        
                    when ST_READ_START =>
                    
                        command <= "01" & cmd_READ & addr & x"FF";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '0';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_READ_RESPONSE;
                        
                    when ST_READ_RESPONSE => 
                    
                        if cmd_response1 = x"00" then
                            bytes_to_receive <= block_size;
                            bits_to_receive <= 8;
                            waiting_for_response <= '1';
                            state <= ST_RECEIVE_PACKET;
                        else
                            state <= ST_ERROR3;
                        end if;
                        
                    when ST_RECEIVE_PACKET =>
                    
                        take_byte <= '0';
                    
                        if SCLK_neg_edge = '1' then
                            if waiting_for_response = '1' then
                                if SD_DO = '0' then
                                    waiting_for_response <= '0';
                                end if;
                            else
                                bits_to_receive <= bits_to_receive - 1;
                                byte_register_in <= byte_register_in(6 downto 0) & SD_DO;
                            end if;
                        end if;
                        
                        if bits_to_receive = 0 then
                            data_out <= byte_register_in;
                            take_byte <= '1';
                            if bytes_to_receive > 0 then
                                bits_to_receive <= 8;
                                bytes_to_receive <= bytes_to_receive - 1;
                            else
                                state <= ST_WAIT_RW_REQ;
                            end if;
                        end if;
                    
                    when ST_WRITE_START =>
                    
                        command <= "01" & cmd_WRITE & addr & x"FF";
                        bits_to_send <= command_len;
                        expect_response <= '1';
                        response_format <= '0';
                        state <= ST_SEND_CMD;
                        rtn_state <= ST_WRITE_RESPONSE;
                        
                        wait_before_write_packet <= 31;
                        
                    when ST_WRITE_RESPONSE =>
                    
                        if cmd_response1 /= x"00" then
                            --data_out <= cmd_response1;
                            state <= ST_ERROR1;
                        end if;
                        
                        if SCLK_neg_edge = '1' then
                            if wait_before_write_packet > 0 then
                                wait_before_write_packet <= wait_before_write_packet - 1;
                            else
                                bits_to_send <= 0;
                                bytes_to_send <= block_size;
                                crc_bits_to_send <= 16;
                                SD_DI <= '0';
                                state <= ST_SEND_PACKET;
                            end if;
                        end if;
                        
                    when ST_SEND_PACKET =>
                    
--                        if bits_to_send = 0 then
--                            if bytes_to_send /= 0 then
--                                give_byte <= '1';
--                                if byte_ready = '1' then
--                                    byte_register_out <= data_in;
--                                    give_byte <= '0';
--                                    bits_to_send <= 8;
--                                    bytes_to_send <= bytes_to_send - 1;
--                                end if;
--                            end if;
--                        end if;

                        next_byte <= '0';

                        if bits_to_send = 0 then
                            if bytes_to_send /= 0 then
                                byte_register_out <= data_in;
                                bits_to_send <= 8;
                                bytes_to_send <= bytes_to_send - 1;
                                next_byte <= '1';
                            end if;
                        end if;
                        
                        if SCLK_neg_edge = '1' then
                            if bits_to_send = 0 then
                                if bytes_to_send = 0 then
                                    if crc_bits_to_send = 0 then
                                        bits_to_receive <= data_response_len;
                                        state <= ST_WAIT_DATA_RESPONSE;
                                    else
                                        SD_DI <= '1';
                                        crc_bits_to_send <= crc_bits_to_send - 1;
                                    end if;
                                else
                                    state <= ST_ERROR2;
                                end if;
                            else
                                SD_DI <= byte_register_out(7);
                                byte_register_out <= byte_register_out(6 downto 0) & '1';
                                bits_to_send <= bits_to_send - 1;
                            end if;         
                        end if;
                        
                    when ST_WAIT_DATA_RESPONSE =>
                    
                        if SCLK_neg_edge = '1' then
                            if bits_to_receive = 0 then
                                --data_out <= data_response;
                                if data_response(4 downto 0) = "00101" then
                                    state <= ST_SD_BUSY;
                                else
                                    --state <= ST_ERROR5;
                                end if;
                            else
                                bits_to_receive <= bits_to_receive - 1;
                                data_response <= data_response(data_response_len - 2 downto 0) & SD_DO;
                            end if;
                        end if;
                        
                    when ST_SD_BUSY =>
                    
                        if SD_DO = '1' then
                            ready <= '1';
                            busy <= '0';
                            state <= ST_WAIT_RW_REQ;
                        else
                            busy <= '1';
                        end if;
                    
                    when ST_SEND_CMD =>
                        
                        if SCLK_neg_edge = '1' then
                            if bits_to_send = 0 then
                                if expect_response = '1' then
                                    if response_format = '0' then
                                        bits_to_receive <= cmd_response_len1;
                                    else
                                        bits_to_receive <= cmd_response_len7;
                                    end if;
                                    waiting_for_response <= '1';
                                    state <= ST_WAIT_CMD_RESPONSE;
                                else
                                    state <= rtn_state;
                                end if;
                            else
                                SD_DI <= command(command_len-1);
                                command <= command(command_len-2 downto 0) & '1';
                                bits_to_send <= bits_to_send - 1;
                            end if;
                        end if;
                        
                    when ST_WAIT_CMD_RESPONSE =>
                    
                        if SCLK_neg_edge = '1' then
                            if waiting_for_response = '1' then
                                if SD_DO = '0' then
                                    waiting_for_response <= '0';
                                    bits_to_receive <= bits_to_receive - 1;
                                    if response_format = '0' then
                                        cmd_response1 <= cmd_response1(cmd_response_len1 - 2 downto 0) & SD_DO;
                                    else
                                        cmd_response7 <= cmd_response7(cmd_response_len7 - 2 downto 0) & SD_DO;
                                    end if;
                                end if;
                            elsif bits_to_receive = 0 then
                                state <= rtn_state;
                            else
                                bits_to_receive <= bits_to_receive - 1;
                                if response_format = '0' then
                                    cmd_response1 <= cmd_response1(cmd_response_len1 - 2 downto 0) & SD_DO;
                                else
                                    cmd_response7 <= cmd_response7(cmd_response_len7 - 2 downto 0) & SD_DO;
                                end if;
                            end if;
                        end if;
                    
                    when ST_ERROR =>
                    when ST_ERROR1 =>
                    when ST_ERROR2 =>
                    when ST_ERROR3 =>
                    when ST_ERROR4 =>
                    when ST_ERROR5 =>
                    
                    when others =>
                        state <= ST_RESET;
                end case;
                
            end if;
            
        end if;
        
    end process;

end Behavioral;
