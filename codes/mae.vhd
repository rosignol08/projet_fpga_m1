-- code de la machine à états


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- la tramme fait 51 bits : 
--14 bits de préambule, 
--1 bit de start, 
--8 bits d'adresse, 
--1 bit de start, 
--16 bits de commande, 
--1 bit de start, 
--8 bits de contrôle, 
--1 bit de stop

entity MAE is
    Port ( 
            Reset 	    :   in STD_LOGIC;		-- Reset Asynchrone
            Clk_In 	    :   in STD_LOGIC;		-- Horloge 100 MHz de la carte Nexys
            FIN_TEMPO 	:   in STD_LOGIC;
            FIN_0       :   in STD_LOGIC;
            FIN_1       :   in STD_LOGIC; 
            BIT_LU      :   in STD_LOGIC;  --la fleche du registre dcc vers mae


            START_TEMPO :   out STD_LOGIC;
            GO_0        :   out STD_LOGIC;
            GO_1        :   out STD_LOGIC;
            COM_REG     :   out STD_LOGIC_VECTOR(1 downto 0) --le singal pour dire à registre dcc ce qu'on fait (nouvelle trame, decallage 1 bit, ou rien faire pour les 6ms d'attenes)
           );

end MAE;

--COM_REG : 10 = shift 
architecture Comportement of MAE is

    --les etats de la machine à etats:
    type type_etat is (ATTENTE_TEMPO, LOAD_REG, CHECK_BIT, ENVOI_1, ENVOI_0, SHIFT_REG);
    signal etat_courant, etat_suivant : type_etat;

    signal compteur_nb_bits    	: INTEGER range 0 to 51;	--compteur du nombre de bits transmis
    --signal Clk_Temp : STD_LOGIC;			 	-- Signal temporaire

begin
    process (Clk_In, Reset)
    begin 
        if Reset = '1' then  --faut checker si le reset s'active à 1 ou 0 
            etat_courant <= ATTENTE_TEMPO;
            compteur_nb_bits <= 0;
            
        elsif rising_edge(Clk_In) then
            --etat suivant 
            etat_courant <= etat_suivant;
            
            --le cpt de bits
            if etat_courant = LOAD_REG then
                compteur_nb_bits <= 0; --remet à 0 quand on charge une trame
            elsif etat_courant = SHIFT_REG then
                compteur_nb_bits <= compteur_nb_bits + 1; -- ++ a chaque lecture d'un bit
            end if;
            
        end if;
    end process;

    process(etat_courant, FIN_TEMPO, FIN_1, FIN_0, BIT_LU, compteur_nb_bits)
    begin
        --init des sorties par défaut
        START_TEMPO <= '0';
        GO_1        <= '0';
        GO_0        <= '0';
        COM_REG     <= "00"; -- "00" = fait rien

        etat_suivant <= etat_courant; --de base la MAE change pas d'etat 

        -- b)les etats
        case etat_courant is
        
            when ATTENTE_TEMPO =>
                START_TEMPO <= '1'; --le chrono de 6ms
                if FIN_TEMPO = '1' then
                    etat_suivant <= LOAD_REG; --les 6ms sont ecoulees =>faut load la trame
                end if;
                
            when LOAD_REG =>
                COM_REG <= "01"; -- "01" = commande Load pour le registre
                etat_suivant <= CHECK_BIT; -- analyse du premier bit
                
            when CHECK_BIT =>
                -- faut checker le bit qu'on vient de lire "BIT_LU" on peut faire le truc des 14 bits de preambule ici mais pas sur
                if BIT_LU = '1' then
                    etat_suivant <= ENVOI_1;
                    else
                        etat_suivant <= ENVOI_0;
                end if;

                
            when ENVOI_1 =>
                --top depart a dcc 1
                GO_1 <= 1;
                if FIN_1 = '1' then
                    etat_suivant <= SHIFT_REG;
                else
                    etat_suivant <= ENVOI_1; --tant qu'on a pas recu le signal fin_1 on reste dans cet etat
                end if;
                -- si on est ici ca veut dire qu'on a recu le signal fin_1 donc c'est bon
                

            when ENVOI_0 =>
                --top depart a dcc 0
                GO_0 <= 1;
                if FIN_0 = '0' then
                    etat_suivant <= SHIFT_REG;
                else
                    etat_suivant <= ENVOI_0; --tant qu'on a pas recu le signal fin_0 on reste dans cet etat
                end if;
                
                -- si on est ici ca veut dire qu'on a recu le signal fin_0 donc c'est bon
                

            when SHIFT_REG =>
                COM_REG <= "10";
                if compteur_nb_bits = 51 then
                    etat_suivant <= ATTENTE_TEMPO;
                    else 
                        etat_suivant <= CHECK_BIT; --on lit le bit suivant psk on a pas tout lu
                end if;


            when others =>
                etat_suivant <= ATTENTE_TEMPO;
                
        end case;
    end process;

end Comportement;