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

    -- 1. signaux de connection 
    signal clk_100mhz: std_logic := '0';
    signal reset: std_logic := '0';
    signal clk_1mhz: std_logic := '0';
    signal start_tempo : std_logic := '0';
    signal fin_tempo : std_logic;
    
    -- 2. constantes de temps
    constant T_100MHz : time := 10 ns;
    constant T_1MHz   : time := 1 us;
    
begin

    -- Instanciation du module 
    tempo : entity work.COMPTEUR_TEMPO
    port map(clk_100mhz,reset,clk_1mhz,start_tempo,fin_tempo);
    
    -- Génération de l'horloge système (100 MHz)
    process
    begin 
        clk_100mhz <= not clk_100mhz;
        wait for T_100MHz / 2;
    end process;
    
    
    -- Génératiuon de l'horloge lente (1 MHz)
    process
    begin
        clk_1mhz <= not clk_1mhz;
        wait for T_1MHz / 2;
    end process;
    
    
    -- Processus de stimulus et de vérification 
    process_stimulus : process
        variable t_start : time;
    begin 
        -- ==============================================================
        -- PHASE 1 : Initialisation et Reset
        -- ==============================================================    
        reset       <= '1';
        start_tempo <= '0';
        wait for 15 us;
        
        reset <= '0';
        wait until falling_edge(clk_100mhz);
        
        -- ==============================================================
        -- PHASE 2 : Démarrage et mesure des 6 ms
        -- ==============================================================
        -- On s'aligne proprement sur l'horloge lente 
        wait until rising_edge(clk_1mhz);
        
        start_tempo <= '1', '0' after 1 ms ,'1' after 3 ms ;
        t_start := now; -- On déclenche le chronomètre du simulateur 
        
        -- On attend que le module lève son drapeau 
        wait until fin_tempo = '1'; 
        
        -- Vérification stricte : Le temps écoulé doit être 6000 us
        -- On laisse une microseconde de marge liée à la synchronisation des deux horloges
        assert (now - t_start >= 5999 us and now - t_start <= 6001 us)
            report "ERREUR : La temporisation ne dure pas exactement 6 ms !" severity error;
            
        -- ==============================================================
        -- PHASE 3 : Test du maintien (Hold)
        -- ==============================================================
        -- On attend un peu pour vérifier que le signal reste bien à '1'
        wait for 50 us;
        
        assert (fin_tempo = '1')
            report "ERREUR : Le signal Fin_Tempo est retombe à 0 trop tot !" severity error;
    
        -- ==============================================================
        -- PHASE 4 : Relâchement de la commande
        -- ==============================================================
        start_tempo <= '0';
        
        -- On attend 2 coups d'horloge 100MHz pour laisser le temps 
        -- au séquenceur interne de réagir et de changer d'état 
        wait for 20 ns;
        assert (fin_tempo = '0')
            report "ERREUR : FIN_Teompo ne retombe pas a 0 après l'arret de la commande " severity error;
            
        -- ==============================================================
        -- FIN DE SIMULATION
        -- ==============================================================       
    
        report "SIMULATION DU COMPTEUR de 6 ms terminee avec succes." severity note;
        wait;
    end process;  

end Behavioral;