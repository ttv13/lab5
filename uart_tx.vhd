----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2025 01:05:07 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

entity uart_tx is
  Port (clk : in std_logic;
        en : in std_logic;
        send : in std_logic;
        rst : in std_logic;
        char : in std_logic_vector (7 downto 0);
        ready : out std_logic;
        tx : out std_logic
  );
end uart_tx;

architecture fsm of uart_tx is


type state is (idle, start, data);
signal curr : state := idle;

signal data_bits : std_logic_vector (7 downto 0) := (others => '0');
signal data_count : std_logic_vector (2 downto 0) := (others => '0');

begin

process (clk) 
begin 
if(rising_edge (clk)) then 

    if(rst = '1') then
        curr <= idle;
        data_bits <= (others => '0');
        data_count <= (others => '0');
        ready <= '1';
        tx <= '1';
    elsif (en = '1') then
        
        case curr is 
            when idle  =>
            
                ready <= '1';
                tx <= '1';
                
                if (send = '1') then 
                    data_bits <= char;
                    curr <= start;
                    tx <= '0'; -- low start
                    ready <= '0';
                end if;
                
            when start =>
                curr <= data;
                tx <= data_bits(0);
                data_count <= (others => '0');
                
            when data =>
                if (unsigned(data_count) < 7) then
                    tx <= data_bits(to_integer (unsigned (data_count) + 1));
                    data_count <= std_logic_vector (unsigned (data_count) + 1);

                else -- finished sending data 
                    curr <= idle;
                    tx <= '1'; -- stop bit
                end if;
                
            when others =>
                curr <= idle;
                
        end case;
    end if; --rst
end if; --rising edge
end process;
end fsm;
