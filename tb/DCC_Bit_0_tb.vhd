library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DCC_Bit_0_tb is
--  Port ( );
end DCC_Bit_0_tb;

architecture Behavioral of DCC_Bit_0_tb is
    signal clk_100  : std_logic := '0'; 
    signal clk_1    : std_logic := '0';
    signal reset       : std_logic := '1';
    signal go_0        : std_logic := '0';
    signal fin_0       : std_logic;
    signal dcc_0       : std_logic;
    
    -- 3. Définition des périodes d'horloge
    constant T_100MHz : time := 10 ns;  -- Période pour 100 MHz
    constant T_1MHz   : time := 1  us;  -- Période pour 1MHz

begin
    
    -- 4.Instanciation du composant 
    inst_DCC_bit_0 : entity work.DCC_Bit_0
    port map (clk_100, clk_1, reset, go_0, fin_0, dcc_0);
    
    
    -- 5. Génération de l'horloge 100 MHz
    process_clk_100: process 
    begin 
        clk_100 <= '0';
        wait for T_100MHz / 2;
        clk_100 <= '1';
        wait for T_100MHz / 2;
    end process;
    
    -- 6. Génération de l'horloge 1 Mhz
    process_clk_1 : process 
    begin 
        clk_1 <= '0';
        wait for T_1MHz / 2;
        clk_1 <= '1';
        wait for T_1MHz / 2;
    end process;
    
    -- 7. Processus principale de stimulus 
    process_stimulus: process
        variable t_start : time;
        variable t_mid   : time;
    begin
        -- Initialisation et Reset
        reset <= '1';
        go_0    <= '0';
        wait for 5 us; 
        
        -- Fin du Reset
        reset <= '0';
        wait for 5 us;
        
        -- Alignement sur un front montant de l'horloge lente pour être propre
        wait until rising_edge(clk_1);

        -- ==============================================================
        -- TEST 1 : Envoi d'un Bit 1
        -- ==============================================================
        -- La MAE globale donne l'ordre d'envoyer un bit '1'
        go_0 <= '1';
        
        -- On note le temps de départ
        t_start := now; -- POURQUOI ??
        
        -- On attend que le signal bascule à 1 (fin de la première phase à 0)
        wait until dcc_0 = '1';
        t_mid := now;
        
        -- On laisse une petite marge de tolérance liée à la synchronisation des horloges
        assert (t_mid - t_start >= 99 us and t_mid - t_start <= 101 us)
            report "ERREUR : La phase a 0 ne dure pas 100 us !" severity error;
            
        -- On attend la fin de l'émission signalée par le module
        wait until fin_0 = '1';
        
        -- Vérification de la deuxième phase (Impulsion à 1) : Doit durer environ 58 us
        assert (now - t_mid >= 99 us and now - t_mid <= 101 us)
            report "ERREUR : La phase a 1 ne dure pas 100 us !" severity error;

        -- La MAE globale acquitte et baisse la commande GO
        wait until rising_edge(clk_100);
        go_0 <= '0';

        -- ==============================================================
        -- TEST 2 : Retour à l'état de repos
        -- ==============================================================
        wait for 20 us;
        
        -- La MAE globale donne l'ordre d'envoyer un bit '1'
        go_0 <= '1';
        
        
        
        -- La MAE globale acquitte et baisse la commande GO
        wait until rising_edge(clk_1);
        go_0 <= '0';
        
        
        
        
        
        
        
        assert (dcc_0 = '0')
            report "ERREUR : Le signal DCC ne retombe pas a 0 apres l'envoi." severity error;
            
        assert (fin_0 = '0')
            report "ERREUR : Le signal FIN ne retombe pas a 0 apres l'acquittement." severity error;

        -- Fin de la simulation
        report "SIMULATION TERMINEE AVEC SUCCES." severity note;
        wait; -- Stoppe le processus
    end process;
           
end Behavioral;
