----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.08.2024 08:27:47
-- Design Name: 
-- Module Name: buffer - Behavioral
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

entity data_buffer is
    generic(
        data_width : integer := 8;
        buffer_size : integer := 256;
        size_register_width : integer := 8); --log_2(buffer_size)
    Port (
        clk : in std_logic;
        rst : in std_logic;
        data_in : in STD_LOGIC_VECTOR (data_width-1 downto 0);
        data_out : out STD_LOGIC_VECTOR (data_width-1 downto 0);
        write : in STD_LOGIC;
        shift : in STD_LOGIC;
        data_size : out STD_LOGIC_VECTOR (size_register_width-1 downto 0));
end data_buffer;

architecture Behavioral of data_buffer is

    type array_type is array(0 to buffer_size-1) of std_logic_vector(data_width-1 downto 0);
    signal buffer_array : array_type;
    
    signal current_size : unsigned(size_register_width-1 downto 0) := (others => '0');
    
    signal write_old : std_logic := '0';
    signal shift_old : std_logic := '0';

begin

    data_out <= buffer_array(0);
    data_size <= std_logic_vector(current_size);
    
    process(clk, rst)
    begin
    
        if(rst = '1') then  
            write_old <= '0';
            shift_old <= '0';
            current_size <= (others => '0');
            buffer_array <= (others => (others => '0'));   
        end if;
    
        if(rising_edge(clk)) then
        
            if(write_old = '0' and write = '1') then
                if current_size < buffer_size then
                    buffer_array(to_integer(current_size)) <= data_in;
                    current_size <= current_size + 1;
                end if;
            end if;
            
            if(shift_old = '0' and shift = '1') then
                if(current_size > 0) then
                    for i in 0 to buffer_size-2 loop
                        buffer_array(i) <= buffer_array(i+1);
                    end loop;
                    current_size <= current_size - 1;
                end if;
            end if;
            
            write_old <= write;
            shift_old <= shift;
            
        end if; 
        
    end process;


end Behavioral;
