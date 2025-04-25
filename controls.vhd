----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2025 02:43:40 PM
-- Design Name: 
-- Module Name: controls - Behavioral
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

entity controls is
  Port (
        -- Timing Signals
        clk , en , rst : in std_logic;
        
        -- Register File IO
        rID1 ,rID2  : out std_logic_vector(4 downto 0);
        wr_enR1 , wr_enR2 : out std_logic;
        regrD1, regrD2 : in std_logic_vector(15 downto 0);
        regwD1 , regwD2 : out std_logic_vector (15 downto 0);
        
        -- Framebuffer IO
        fbRST : out std_logic;
        fbAddr1 : out std_logic_vector (11 downto 0);
        fbDin1 : in std_logic_vector (15 downto 0);
        fbDout1 : out std_logic_vector (15 downto 0);
        wr_en : out std_logic;
        
        -- Instruction Memory IO
        irAddr : out std_logic_vector (13 downto 0);
        irWord : in std_logic_vector (31 downto 0);
        
        -- Data Memory IO
        dAddr : out std_logic_vector (14 downto 0);
        d_wr_en : out std_logic;
        dOut : out std_logic_vector (15 downto 0);
        dIn : in std_logic_vector (15 downto 0);
        
        -- ALU IO
        aluA , aluB : out std_logic_vector (15 downto 0);
        aluOp : out std_logic_vector (3 downto 0);
        aluResult : in std_logic_vector (15 downto 0);
        
        -- UART IO
        ready , newChar : in std_logic;
        sendUART : out std_logic;
        charRec : in std_logic_vector (7 downto 0);
        charSend : out std_logic_vector (7 downto 0)
  );
end controls;

architecture Behavioral of controls is

type state is (fetch, decode, decodewait, rops, lops, jops, ropswait, jr , recv, rpix, wpix, send, calc, lopswait, equals,
               nequal, ori, lw, sw, jmp, jal, clrscr, calcwait, store,storewait, finish, rpixwait, wpixwait , lwwait, swwait);

signal curr : state := fetch;


signal pc_sig : std_logic_vector (15 downto 0);

signal instruct_sig : std_logic_vector (31 downto 0);
signal op_sig : std_logic_vector (4 downto 0);
signal reg1_addr_sig : std_logic_vector (4 downto 0);
signal reg2_addr_sig : std_logic_vector (4 downto 0);
signal reg3_addr_sig : std_logic_vector (4 downto 0);

signal immediate_sig : std_logic_vector (15 downto 0);

signal reg1_d_sig : std_logic_vector (15 downto 0);
signal reg2_d_sig : std_logic_vector (15 downto 0);
signal reg3_d_sig : std_logic_vector (15 downto 0);

signal alu_result_sig : std_logic_vector (15 downto 0);

signal lw_sig : std_logic_vector (15 downto 0);
signal sw_sig : std_logic_vector (15 downto 0);
begin


process(clk) begin 

if rising_edge (clk) and en = '1' then 
    
    case curr is 
    
    when fetch =>
        pc_sig <= regrD1;
        curr <= decode;
    
    when decode =>
    
        irAddr <= pc_sig (13 downto 0); --Going to instruction address 
        wr_enR1 <= '1'; -- write en to register 1
        rID1 <= "00001";
        curr <= decodewait; 
    
    when decodewait =>
        
        instruct_sig <= irWord;
        regwD1 <= (std_logic_vector (unsigned (pc_sig )+ 1));
        wr_enR1 <= '0';
    
        if instruct_sig (31 downto 30) = "00" then 
            curr <= rops;
            
        elsif instruct_sig (31 downto 30) = "01" then 
            curr <= lops;
            
        elsif instruct_sig (31 downto 30) = "10" then
            curr <= jops;     
        end if;

    when rops =>
    
        op_sig <= instruct_sig (31 downto 27);
        
        reg1_addr_sig <= instruct_sig (26 downto 22);
        reg2_addr_sig <= instruct_sig (21 downto 17);
        reg3_addr_sig <= instruct_sig (16 downto 12);
        
        rID1 <= reg2_addr_sig;
        rID2 <= reg3_addr_sig;
        
        curr <= ropswait;
    
    when ropswait => 
        
        reg2_d_sig <= regrD1;
        reg3_d_sig <= regrD2;
        
        if op_sig = "01101" then
            rID1 <= reg1_addr_sig;
            curr <= jr; 
        elsif op_sig = "01100" then
            curr <= recv;      
        elsif op_sig = "01111" then
            curr <= rpix;
        elsif op_sig = "01110" then
            rID1 <= reg1_addr_sig;
            curr <= wpix;
        elsif op_sig = "01011" then
            rID1 <= reg1_addr_sig;
            curr <= send;
        else
            curr <= calc;
        end if;
        
    when lops =>
    
        op_sig <= instruct_sig (31 downto 27);
        reg1_addr_sig <= instruct_sig (26 downto 22);
        reg2_addr_sig <= instruct_sig (21 downto 17);
        
        immediate_sig <= instruct_sig (16 downto 1);
        rID1 <= reg2_addr_sig;
        curr <= lopswait;
        
    when lopswait =>
    
        reg2_d_sig <= regrD1;
        
        if op_sig (2 downto 0) = "000" then             
            curr <= equals; 
            rID2 <= reg1_addr_sig;
        elsif op_sig (2 downto 0) = "001" then
            curr <= nequal; 
            rID2 <= reg1_addr_sig;     
        elsif op_sig (2 downto 0) = "010" then
            curr <= ori;
        elsif op_sig (2 downto 0) = "011" then
            lw_sig <= std_logic_vector (unsigned (immediate_sig) + unsigned (reg2_d_sig));
            curr <= lw;
        else
            rID2 <= reg1_addr_sig;
            sw_sig <= std_logic_vector (unsigned (immediate_sig) + unsigned (reg2_d_sig));
            curr <= sw;
        end if;
        
    when jops => 
        op_sig <= instruct_sig (31 downto 27);
        immediate_sig <= instruct_sig (26 downto 11);
        
        if op_sig = "11000" then 
        
            --pc counter
            rID1 <= "00001";
            wr_enR1 <= '1';
            curr <= jmp;
        elsif op_sig = "11001" then 
            
            --pc counter
            rID1 <= "00001";
            wr_enR1 <= '1';
            
            -- ra register 
            rID2 <= "11111";
            wr_enR2 <= '1';
            curr <= jal;
        else 
            curr <= clrscr;
        end if;
        
    when calc =>
        
        aluA <= reg2_d_sig;
        aluB <= reg3_d_sig;
        aluOp <= op_sig (3 downto 0);
        curr <= calcwait;
        
    when calcwait =>
        
        alu_result_sig <= aluResult;
        curr <= store;
        
    when store =>
    
        rID1 <= reg1_addr_sig;
        wr_enR1 <= '1';
        curr <= storewait;

    when storewait =>
    
        regwD1 <= alu_result_sig;
        wr_enR1 <= '0';
        curr <= finish;
        
    when jr =>
        -- saving register 1 
        alu_result_sig <= regrD1;
        
        -- jump in program counter  
        reg1_addr_sig <= "00001";
        curr <= store;
        
    when recv =>
        
        alu_result_sig <= "00000000" & charRec;
        
        if newChar = '0' then 
            curr <= recv;
            
        else 
            curr <= store;
        end if;
        
    when rpix => 
        
        fbAddr1 <= reg2_d_sig (11 downto 0);
        curr <= rpixwait;
        
    when rpixwait => 
    
        alu_result_sig <= fbDin1;
        curr <= store;
        
    when wpix => 
        
        fbAddr1 <= regrD1 (11 downto 0);
        wr_en <= '1';
        curr <= wpixwait;
        
    when wpixwait => 
        fbDout1 <= reg2_d_sig; 
        curr <= finish;
        
    when send =>
        
        sendUART <= '1';
        charSend <= regrD1 (7 downto 0);
        
        if ready = '1' then 
            curr <= finish;
        else 
            curr <= send;
        end if;
        
    when equals => 
    
        if regrD2 = reg2_d_sig then 
            alu_result_sig <= immediate_sig;
            reg1_addr_sig <= "00001";
            curr <= store;
        end if;
        
    when nequal =>
        if regrD2 /= reg2_d_sig then 
            alu_result_sig <= immediate_sig;
            reg1_addr_sig <= "00001";
            curr <= store;
        end if;
        
    when ori => 
        
        alu_result_sig <= immediate_sig or reg2_d_sig; 
        curr <= store;

    when lw => 
        
        dAddr <= lw_sig (14 downto 0);
        curr <= lwwait;
         
    when lwwait => 
        
        alu_result_sig <= dIn;
        curr <= store;
        
    when sw => 
        
        dAddr <= sw_sig (14 downto 0);
        d_wr_en <= '1';
        
        curr <= swwait;
        
    when swwait => 
        
        dOut <= regrD2;
        d_wr_en <= '0';
        curr  <= finish;
        
    when jmp => 
        regwD1 <= immediate_sig;
        wr_enR1 <= '0';
        curr <= finish;
        
    when jal => 
        
        regwD2 <= regrD1;
        wr_enR2 <= '0';
        
        regwD1 <= immediate_sig;
        wr_enR1 <= '0';
        curr <= finish;
        
    when clrscr => 
        
        fbRST <= '1';
        curr <=finish;
        
    when finish => 
        rID1 <= "00001";
        fbRST <= '0';
        curr <= fetch;
    end case; 
end if;--rising edg
end process;
end Behavioral;
