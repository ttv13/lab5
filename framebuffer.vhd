----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2025 10:00:53 PM
-- Design Name: 
-- Module Name: framebuffer - Behavioral
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

entity framebuffer is
  Port (clk1 , en1, en2 : in std_logic;
        addr1 , addr2 : in std_logic_vector (11 downto 0);
        wr_en1 : in std_logic;
        din1 : in std_logic_vector (15 downto 0);
        dout1 ,dout2 : out std_logic_vector (15 downto 0)
  );
end framebuffer;

architecture Behavioral of framebuffer is

type mem_type is array (0 to 4095) of std_logic_vector (15 downto 0);

signal mem : mem_type := (others => (others => '0'));

begin

process (clk1) begin 

-- port a 
if (rising_edge (clk1)) then 

    if (en1 = '1') then 
        dout1 <= mem (to_integer (unsigned (addr1)));
        
        if (wr_en1 = '1') then 
            mem (to_integer (unsigned (addr1))) <= din1;
        end if; -- wren 
        
    end if; -- en1  
            

end if; -- risgin
end process;



--port b 
process (clk1) begin 
if ( rising_edge (clk1)) then 

    if (en2 = '1') then 
        dout2 <= mem (to_integer (unsigned (addr2)));
    end if; 
end if;
end process;


end Behavioral;
