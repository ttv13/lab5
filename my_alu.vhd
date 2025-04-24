----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/05/2025 02:21:18 PM
-- Design Name: 
-- Module Name: my_alu - Behavioral
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

--2 16 bit input, 1 16 bit output , and 16 operations
 
entity my_alu is
  Port (clk : in std_logic;
        en : in std_logic;
        a : in std_logic_vector (15 downto 0);
        b : in std_logic_vector (15 downto 0);
        op : in std_logic_vector (3 downto 0);
        output : out std_logic_vector (15 downto 0)
  );
end my_alu;

architecture Behavioral of my_alu is

begin

process (clk)
begin 


if (rising_edge (clk)) then 
    if (en = '1') then  
           
        case op is 
    
        when "0000" => -- add a + b  
            output <= std_logic_vector (unsigned (a) + unsigned (b));
            
        when "0001" => -- minus a + b
            output <= std_logic_vector (unsigned (a) - unsigned (b));
            
        when "0010" => -- add a + 1
            output <= std_logic_vector (unsigned (a) + 1);
            
        when "0011" => -- minus a - 1
            output <= std_logic_vector (unsigned (a) - 1);
            
        when "0100" => -- minus 0 - a
            output <= std_logic_vector (0 - unsigned (a));
            
        when "0101" => -- shift left logical A << 1 
             output <= std_logic_vector (shift_left(unsigned (a) , 1));
         
        when "0110" => -- shift right logical a >> 1
            output <= std_logic_vector (shift_right (unsigned (a) , 1));
         
        when "0111" => -- shift right arithmetic A >>> 1
            output <= std_logic_vector (shift_right (signed (a) , 1));
         
        when "1000" => -- a and b
            output <= a and b;
            
        when "1001" => -- a or b
            output <= a or b;
            
        when "1010" => -- a xor b
            output <= a xor b;
            
        when "1011" => -- Signed A < B = out[0]
            if ( signed (a) < signed (b) ) then 
                output (0) <= '1';
            else 
                output (0) <= '0';
            end if;
            
        when "1100" => -- signed A > B = out [0]
            if ( signed (a) > signed (b) ) then 
                output (0) <= '1';
            else 
                output (0) <= '0';
            end if;
        
        when "1101" => -- a = b
            if ( a = b) then 
                output (0) <= '1';
            else 
                output (0) <= '0';
            end if;
            
        when "1110" => -- a < b 
            if (a < b) then 
                output (0) <= '1';
            else 
                output (0) <= '0';
            end if;
            
        when "1111" => -- a > b 
            if (a > b) then 
                output (0) <= '1';
            else 
                output (0) <= '0';
            end if;
            
        end case;
        
    end if; -- en    
end if; --rising edge
end process;
end Behavioral;