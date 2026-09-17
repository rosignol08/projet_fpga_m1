library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Diviseur_Horloge_tb is
--  Port ( );
end Diviseur_Horloge_tb;

architecture tb_hor of Diviseur_Horloge_tb is
    signal reset      : STD_LOGIC := '1';
    signal clk_in     : STD_LOGIC := '0';
    signal clk_out    : STD_LOGIC;
    
    -- Constante de temps 
    constant CLK_PER : time := 10 ns; 
    
begin
    
    -- Instantiation du module Diviseur Horloge
    UUT : entity work.CLK_DIV 
        port map (
            Reset => reset,
            Clk_In => clk_in, 
            Clk_Out => clk_out
       );
              
    -- Génération de l'horloge système (100 MHz)   
    process
    begin
        clk_in <= not clk_in;
        wait for CLK_PER/2;
    end process;
    
    -- Vérification du fonctionnement du module 
    process
        variable t_front_montant_1 : time;
        variable t_front_montant_2 : time;
        variable periode_mesuree   : time;
    begin
        -- ==============================================================
        -- PHASE 1 : Initialisation et Reset
        -- ==============================================================
        wait for 50 ns; -- On maintient le reset un peu plus de 2 cycles
        assert(clk_out = '0')
            report "ERREUR : Le signal Clk_Out ne reste pas a 0 pendant le Reset." severity error;
            
        wait until falling_edge(clk_in);       
        reset <= '0';
        
        -- ==============================================================
        -- PHASE 2 : Mesure de la période de la nouvelle horloge (1 MHz)
        -- ==============================================================
        -- Le premier front montant de la nouvelle horloge 
        wait until rising_edge(clk_out);
        t_front_montant_1 := now; 
        
        -- Le deuxième front montant de la nouvelle horloge 
        wait until rising_edge(clk_out);
        t_front_montant_2 := now;
        
        -- Vérification stricte : La période doit 
        periode_mesuree := t_front_montant_2 - t_front_montant_1;
        
        -- Vérification stricte : La période doit être exactement de 1 µs
        assert (periode_mesuree = 1 us)
            report "ERROR : La periode n'est pas de 1 us ! Elle est de : " & time'image(periode_mesuree)
            severity error;
            
        -- ------------------------------------------------------------------
        -- FIN DE SIMULATION 
        -- ------------------------------------------------------------------
        -- On laisse tourner l'horloge pendant quelques cycles supplémentaires 
        wait for 4 us;
        
        report "SIMULATION DU DIVISEUR D'HORLOGE TERMINEE AVEC SUCCES." severity note;
        wait; -- Stoppe le processus de vérification
    end process;
              
end architecture tb_hor;