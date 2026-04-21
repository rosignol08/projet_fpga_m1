library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registre_DCC_tb is 
-- Pas de ports pour un testbench
end Registre_DCC_tb;

architecture Behavioral of Registre_DCC_tb is 

    -- Signaux internes
    signal clk_100    : std_logic := '0';
    signal reset      : std_logic := '1';
    signal trame_in   : std_logic_vector(50 downto 0) := (others => '0');
    signal com_reg    : std_logic_vector(1 downto 0)  := "00";
    signal bit_out    : std_logic;

    -- DÉCLARATION MANQUANTE : La constante de temps pour l'horloge
    constant T_100MHz : time := 10 ns;

begin 
    
    -- Votre instanciation explicite (C'est parfait !)
    L0: entity work.Registre_DCC
    port map(
        CLK_100MHz => clk_100, 
        RESET      => reset, 
        TRAME_IN   => trame_in, 
        COM_REG    => com_reg,
        BIT_OUT    => bit_out
    );
    
    -- Génération de l'horloge
    process 
    begin 
        clk_100 <= not clk_100;
        wait for T_100MHz / 2;
    end process;
    
    process
    begin
        -- =========================================================
        -- 1. Phase de Reset
        -- =========================================================
        com_reg <= "00"; -- On maintient la valeur (Hold)
        
        -- On prépare une trame de test facile à repérer à l'œil :
        -- Elle commence par 101 et finit par 011
        trame_in <= "101" & '0' & x"00000000000" & "011";
        wait for 30 ns;
        assert(bit_out = '0')
            report "ERROR : Le signal bit_out est levé alors qu'il ne devrait pas " severity error; 
        
        -- Fin du reset
        reset <= '0';
        wait until falling_edge(clk_100);

        -- =========================================================
        -- 2. Test du chargement (LOAD = "01")
        -- =========================================================
        com_reg <= "01";
        wait for T_100MHz;
        
        com_reg <= "00"; -- On repasse en Hold pour observer
        wait for T_100MHz;

        -- =========================================================
        -- 3. Test du décalage (SHIFT = "10")
        -- =========================================================
        com_reg <= "10";
        
        -- On laisse tourner pendant 55 cycles pour voir toute la trame sortir
        -- et vérifier que le registre se remplit bien de zéros à la fin.
        wait for 55 * T_100MHz; 
        
        com_reg <= "00"; -- On arrête tout
        
        report "SIMULATION TERMINEE" severity note;
        wait; -- Fin définitive
    end process;

end Behavioral;