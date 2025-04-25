----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2025 07:36:34 PM
-- Design Name: 
-- Module Name: clock_div_50 - Behavioral
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

entity clock_div_50 is
  Port (clk : in std_logic;     -- 125 MHz clock 125,000,000
        div : out std_logic
        );
end clock_div_50;

architecture Behavioral of clock_div_50 is
    signal count : std_logic_vector(26 downto 0) := (others => '0');
    signal div_out : std_logic;
begin

process (clk)
    begin
    if (rising_edge (clk)) then 
        if (unsigned(count) < 4) then        -- count = 5 => 25 mhz clk
            count <= std_logic_vector(unsigned(count) + 1);
            div_out <= '0';
        else 
            count <= (others => '0');
            div_out <= '1';
        end if;
    end if;
    div <= div_out;
    end process;

end Behavioral;
