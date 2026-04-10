----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2026 10:46:27
-- Design Name: 
-- Module Name: tempo_sim - Behavioral
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

entity tempo_sim is
--  Port ( );
end tempo_sim;

architecture Behavioral of tempo_sim is

    signal clk_100mhz: std_logic := '0';
    signal reset: std_logic := '0';
    signal clk_1mhz: std_logic := '0';
    signal start_tempo,fin_tempo : std_logic;
    
begin
    
    clk_100mhz <= not clk_100mhz after 5 ns;
    clk_1mhz <= not clk_1mhz after 0.5 us;
    reset <='1' ,'0' after 2 us;
    
    start_tempo <= '0', '1' after 1 us ,'0' after 3 us ;
    
    tempo : entity work.COMPTEUR_TEMPO
    port map(clk_100mhz,reset,clk_1mhz,start_tempo,fin_tempo);
    

end Behavioral;