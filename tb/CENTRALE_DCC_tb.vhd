library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CENTRALE_DCC_tb is
--  Port ( );
end CENTRALE_DCC_tb;

architecture Behavioral of CENTRALE_DCC_tb is
    signal RESET      : std_logic := '1';
    signal CLK_100MHz : std_logic := '0';
    signal TRAME_DCC  : std_logic_vector(50 downto 0) := (others => '0');
    signal SORTIE_DCC : std_logic;
    
    constant T_100MHz : time := 10 ns;  -- Période pour 100 MHz
begin

    -- Instanciation du module CENTRALE_DCC
    UUT: entity work.CENTRALE_DCC
    port map(RESET, CLK_100MHz, TRAME_DCC, SORTIE_DCC);
    
    -- Génération de l'horloge système (100 MHz) 
    process 
    begin 
        CLK_100MHz <= not CLK_100MHz;
        wait for T_100MHz / 2;
    end process;
    
    process 
    begin 
        -- ==============================================================
        -- PHASE 1 : Initialisation et Reset
        -- ==============================================================
        
        -- (223 bits à '1') & '0' & x"03" & '0' & x"3F" & '0' & "3C" & '1'
        TRAME_DCC <= "11111111111111111111111" & '0' & "00000011" & '0' & "00111111" & '0' & "00111100" & '1';
        
        wait for 1 us;
        
        -- On lève le RESET pour dédmarrer la machine
        RESET <= '0';
        
        -- ==============================================================
        -- PHASE 2 : Observation (Attente passive)
        -- ==============================================================
        -- protocol : 
        -- Attendre 6 ms (Tempo)
        -- Charger la trame dans le registre
        -- Envoyer les 51 bits un par un via DCC_Bit_0 / DCC_Bit_1
        -- Recommencer 
        
        -- On laisse tourner la simulation pendant 30 millisecondes 
        -- pour avoir le temps de voir l'envoi complet d'au moins 2 trames.
        wait for 30 ms; 
        
        report "SIMULATION DE LA CENTRALE TERMINEE." severity note;
        wait; -- Arrêt définitif de la simulation
    end process;
        
        
end Behavioral;
