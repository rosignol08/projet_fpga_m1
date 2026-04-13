
--tb generateur de trammes (avec l'aide d'un llm)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_DCC_FRAME_GENERATOR is
end tb_DCC_FRAME_GENERATOR;

architecture behavior of tb_DCC_FRAME_GENERATOR is

    --composant a tester
    component DCC_FRAME_GENERATOR
    Port ( 
        Interrupteur : in STD_LOGIC_VECTOR(7 downto 0);
        Trame_DCC    : out STD_LOGIC_VECTOR(50 downto 0)
    );
    end component;

    --decl des signaux internes
    signal Interrupteur : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal Trame_DCC    : STD_LOGIC_VECTOR(50 downto 0);

begin

    --instansiation du module
    uut: DCC_FRAME_GENERATOR PORT MAP (
        Interrupteur => Interrupteur,
        Trame_DCC    => Trame_DCC
    );

    --simu (les sw)
    stim_proc: process
    begin
        --test init : pas de sw (Arrêt)
        Interrupteur <= "00000000";
        wait for 20 ns;

        --test 1 : sw 7 (Marche Avant)
        Interrupteur <= "10000000";
        wait for 20 ns;

        --test 2 : sw 6 (Marche Arrière)
        Interrupteur <= "01000000";
        wait for 20 ns;

        --test 3 : sw 5 (Phares ON)
        Interrupteur <= "00100000";
        wait for 20 ns;

        --test 4 : sw 4 (Phares OFF)
        Interrupteur <= "00010000";
        wait for 20 ns;

        --test 5 : sw 1 (Annonce SNCF)
        Interrupteur <= "00000010";
        wait for 20 ns;

        --test combi : sw 7 et 5 en même temps
        --(TODO : check bit de poids fort est prioritaire selon if/elsif)
        Interrupteur <= "10100000";
        wait for 20 ns;

        --fin simu
        wait;
    end process;

end behavior;