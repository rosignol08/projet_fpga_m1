library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DCC_Bit_1_tb is
end DCC_Bit_1_tb;

architecture Behavioral of DCC_Bit_1_tb is
    signal clk_100  : std_logic := '0'; 
    signal clk_1    : std_logic := '0';
    signal reset    : std_logic := '1';
    signal go_1     : std_logic := '0';
    signal fin_1    : std_logic;
    signal dcc_1    : std_logic;
    
    -- 3. D??finition des p??riodes d'horloge
    constant T_100MHz : time := 10 ns;  -- P??riode pour 100 MHz
    constant T_1MHz   : time := 1  us;  -- P??riode pour 1MHz

begin
    
    
    inst_DCC_bit_1 : entity work.DCC_Bit_1
    port map (clk_100, clk_1, reset, go_1, fin_1, dcc_1);
    
    process 
    begin 
        clk_100 <= not clk_100;
        wait for T_100MHz / 2;
    end process;
    
    process 
    begin 
        clk_1 <= not clk_1;
        wait for T_1MHz / 2;
    end process;
    
    -- 7. Processus principale de stimulus 
    process_stimulus: process
        variable t_start : time;
        variable t_mid   : time;
    begin
        -- Initialisation et Reset
        reset <= '1';
        go_1    <= '0';
        wait for 5 us; 
        
        -- Fin du Reset
        reset <= '0';
        wait for 5 us;
        
        -- Alignement sur un front montant de l'horloge lente pour ??tre propre
        wait until rising_edge(clk_1);

        -- ==============================================================
        -- TEST 1 : Envoi d'un Bit 1
        -- ==============================================================
        -- La MAE globale donne l'ordre d'envoyer un bit '1'
        go_1 <= '1';
        
        -- On note le temps de d??part
        t_start := now; -- POURQUOI ??
        
        -- On attend que le signal bascule ?? 1 (fin de la premi??re phase ?? 0)
        wait until dcc_1 = '1';
        t_mid := now;
        
        -- On laisse une petite marge de tol??rance li??e ?? la synchronisation des horloges
        assert (t_mid - t_start >= 57 us and t_mid - t_start <= 59 us)
            report "ERREUR : La phase a 0 ne dure pas 58 us !" severity error;
            
        -- On attend la fin de l'??mission signal??e par le module
        wait until fin_1 = '1';
        
        -- V??rification de la deuxi??me phase (Impulsion ?? 1) : Doit durer environ 58 us
        assert (now - t_mid >= 57 us and now - t_mid <= 59 us)
            report "ERREUR : La phase a 1 ne dure pas 58 us !" severity error;

        -- La MAE globale acquitte et baisse la commande GO
        wait until rising_edge(clk_100);
        go_1 <= '0';

        -- ==============================================================
        -- TEST 2 : Retour ?? l'??tat de repos
        -- ==============================================================
        wait for 20 us;
        
        -- La MAE globale donne l'ordre d'envoyer un bit '1'
        go_1 <= '1';
        
        -- La MAE globale acquitte et baisse la commande GO
        wait until rising_edge(clk_100);
        go_1 <= '0';
        
        assert (dcc_1 = '0')
            report "ERREUR : Le signal DCC ne retombe pas a 0 apres l'envoi." severity error;
            
        assert (fin_1 = '0')
            report "ERREUR : Le signal FIN ne retombe pas a 0 apres l'acquittement." severity error;

        -- Fin de la simulation
        report "SIMULATION TERMINEE AVEC SUCCES." severity note;
        wait; -- Stoppe le processus
    end process;
           
end Behavioral;
