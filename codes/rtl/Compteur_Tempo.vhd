----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: J.DENOULET, Winter 2021
--
-- Module Name: COMPTEUR_TEMPO - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: NEXYS 4 DDR
-- 
--	Compteur de Temporisation de la Centrale DCC
--
--		Apres detection du passage a 1 de la commande Start_Tempo,
--		le module compte 6 ms et positionne a 1 la sortie Fin_Tempo
--
--		Pour etre detectee, la commande Start_Tempo doit etre mise a 1
--		pendant au moins 1 periode de l'horloge 100 MHz
--
--		Quand Fin_Tempo pase a 1, la sortie reste dans cet etat tant que 
--		Start_Tempo est a 1. 
--		Des la detection du retour a 0 de Start_Tempo,
--		Fin_Tempo repasse a 0.
--		
--		De cette maniere, la duree de minimale l'impulsion a 1 de 
--		Fin_Tempo sera d'un cycle de l'horloge 100 MHz.
--		Cela est a priori suffisant pour sa bonne detection
--		par la MAE de la Centrale DCC.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COMPTEUR_TEMPO is
    Port ( Clk 			: in STD_LOGIC;		-- Horloge 100 MHz
           Reset 		: in STD_LOGIC;		-- Reset Asynchrone
           Clk1M 		: in STD_LOGIC;		-- Horloge 1 MHz
           Start_Tempo	: in STD_LOGIC;		-- Commande de Demarrage de la Temporisation
           Fin_Tempo	: out STD_LOGIC		-- Drapeau de Fin de la Temporisation
		);
end COMPTEUR_TEMPO;

architecture Behavioral of COMPTEUR_TEMPO is

signal Q: std_logic_vector(1 downto 0); -- Etat Sequenceur
signal Raz_CPt,Inc_Cpt: std_logic; -- Commandes Compteur
signal Fin_Cpt: std_logic; -- Drapeau de Fin de Comptage

-- Compteur de Temporisation
signal Cpt	    : INTEGER range 0 to 10000; -- Compteur (6000 = 6 ms)
signal En_Tempo	: STD_LOGIC;				-- Commande d'Incrementation

begin

    -- Sequenceur
    process(Clk,Reset)
    begin
        if Reset='1' then Q <= "00";
        elsif rising_edge(Clk) then
            Q(1) <= ((not Q(1)) and Q(0) and Fin_Cpt) or (Q(1) and Start_Tempo);
            Q(0) <= Start_Tempo or ((not Q(1)) and Q(0));
        end if;
    end process;

    -- Sorties Sequenceur
    Raz_Cpt <= Q(1) xnor Q(0);
    Inc_Cpt <= (not Q(1)) and Q(0);
    Fin_Tempo <= Q(1) and Q(0);  


    -- Compteur de Temporisation
	process (Clk1M, Reset)
    begin
        -- Reset Asynchrone
        if (Reset) = '1' then
            Cpt <= 0;
        elsif rising_edge (Clk1M) then
            if Raz_Cpt = '1' then Cpt <= 0;
            elsif Inc_Cpt = '1' then Cpt <= Cpt  + 1;
            end if;
        end if;
    end process;

    Fin_Cpt <= '1' when (Cpt = 5999) else '0';

end Behavioral;
