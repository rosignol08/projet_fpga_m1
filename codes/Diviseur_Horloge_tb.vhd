----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2026 11:34:25 AM
-- Design Name: 
-- Module Name: Diviseur_Horloge_tb - Behavioral
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

entity Diviseur_Horloge_tb is
--  Port ( );
end Diviseur_Horloge_tb;

architecture tb_hor of Diviseur_Horloge_tb is
    constant CLK_PER : time := 10 ns; 
    signal s_reset      : STD_LOGIC := '0';
    signal s_clk_in     : STD_LOGIC := '0';
    signal s_clk_out    : STD_LOGIC;
    
begin

    UUT : entity work.CLK_DIV -- quel utilite
        port map (
            Reset => s_reset,
            Clk_In => s_clk_in, 
            Clk_Out => s_clk_out
       );
                 
    process
    begin
        s_clk_in <= not s_clk_in;
        wait for CLK_PER/2;
    end process;
    
    process
    begin
        s_reset <= '1';
        wait for 100 ns; -- On maintient le reset un peu plus de 2 cycles
        s_reset <= '0';
        
        -- Phase 2 : Observation
        -- Le compteur Div doit compter de 0 ? 49 (soit 50 cycles) 
        -- pour inverser Clk_Temp. Une p?riode compl?te de Clk_Out 
        -- prendra donc 100 cycles de Clk_In (100 * 10ns = 1us = 1MHz).
        
        wait for 12 us; -- On laisse simuler pour voir plusieurs cycles 1MHz
        
        -- Fin de la simulation (optionnel)
        assert false report "Simulation termin?e avec succ?s" severity note;
        wait;
    end process;
    
end architecture tb_hor;
