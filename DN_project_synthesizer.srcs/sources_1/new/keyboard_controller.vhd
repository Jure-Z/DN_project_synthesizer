
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keyboard_controller is
    Port ( PS2_DATA : in STD_LOGIC;
           PS2_CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           freqs : out STD_LOGIC_VECTOR (35 downto 0);
           data_out : out STD_LOGIC_VECTOR(7 downto 0));
           
end keyboard_controller;

architecture Behavioral of keyboard_controller is

signal data : std_logic_vector (8 downto 0);
signal eot : std_logic;
signal RSTN : std_logic;

signal dataInverted : std_logic_vector (7 downto 0); --obrnjen data vector zaradi primerjave kod tipkovnice in načina pošiljanja kod

begin

RSTN <= not RST;

--invert bits
dataInverted(0) <= data(0);
dataInverted(1) <= data(1);
dataInverted(2) <= data(2);
dataInverted(3) <= data(3);
dataInverted(4) <= data(4);
dataInverted(5) <= data(5);
dataInverted(6) <= data(6);
dataInverted(7) <= data(7);

data_out <= dataInverted;



PS2_controller : entity work.PS2_controller(Behavioral)
    port map (
        CLK100MHZ => CLK,
        CPU_RESETN => RSTN,
        PS2_CLK => PS2_CLK,
        PS2_DATA => PS2_DATA,
        data => data,
        eot => eot
    );

PS2_keyStateMapper: entity work.PS2_keyStateMapper(Behavioral)
    port map (
        data => dataInverted,
        eot => eot,
        RST => RST,
        CLK => CLK,
        freqs => freqs
    );

end Behavioral;
