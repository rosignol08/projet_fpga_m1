library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_DCC_tb is
--  Port ( );
end TOP_DCC_tb;

architecture Behavioral of TOP_DCC_tb is
    signal reset         : std_logic := '1';
    signal clk_100       : std_logic := '0';
    signal interrupteurs : std_logic_vector(7 downto 0) := (others => '0'); 
    signal sortie_dcc    : std_logic;
    
    constant T_100MHz : time := 10 ns; 
begin

    -- Instanciation du module TOP_DCC
    UUT: entity work.TOP_DCC
    port map(reset, clk_100, interrupteurs, sortie_dcc);
    
    -- Génération de l'horloge système (100 MHz)
    process 
    begin 
        clk_100 <= not clk_100;
        wait for T_100MHz;
    end process;
    
    process
    begin 
        -- ==============================================================
        -- PHASE 1 : Initialisation
        -- ==============================================================
        wait for 2 us;
        
        -- Démarrage du module
        reset <= '0';
        
        -- ==============================================================
        -- PHASE 2 : Test de la première consigne
        -- ==============================================================
        
        -- On lève le premier interrupteur (pour allumer les phares)
        interrupteurs <= "00000001";
        
        -- Le système va faire sa pause de 6 ms       
        wait for 20 ms; 
             
        -- ==============================================================
        -- PHASE 3 : Changement de consigne en direct
        -- ==============================================================
        
        -- L'utilisateur lève un autre interrupteur (ex: changer la vitesse)        
        interrupteurs <= "10000000";
        
        -- On observe le système prendre en compte la nouvelle trame
        -- après sa nouvelle pause de 6 ms.
        wait for 20 ms;
        
        -- Fin de la simulation 
        report "SIMULATION DU SYSTEME COMPLET TERMINEE" severity note;
        wait;
    end process;
end Behavioral;