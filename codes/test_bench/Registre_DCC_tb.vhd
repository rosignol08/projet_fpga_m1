library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registre_DCC_tb is 
end Registre_DCC_tb;

architecture Behavioral of Registre_DCC_tb is 
    signal clk_100    : std_logic := '0';
    signal reset      : std_logic := '1';
    signal trame_in   : std_logic_vector(50 downto 0) := (others => '0');
    signal com_reg    : std_logic_vector(1 downto 0)  := "00";
    signal bit_out    : std_logic;

    constant T_100MHz : time := 10 ns;

begin 
    
    -- Votre instanciation explicite (C'est parfait !)
    L0: entity work.Registre_DCC
    port map(
        Clk_100    => clk_100, 
        Reset      => reset, 
        TRAME_IN   => trame_in, 
        COM_REG    => com_reg,
        BIT_OUT    => bit_out
    );
    
    -- G??n??ration de l'horloge
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
        
        -- On pr??pare une trame de test facile ?? rep??rer ?? l'??il :
        -- Elle commence par 101 et finit par 011
        trame_in <= "101" & '0' & x"00000000000" & "011";
        wait for 30 ns;
        assert(bit_out = '0')
            report "ERROR : Le signal bit_out est lev?? alors qu'il ne devrait pas " severity error; 
        
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
        -- 3. Test du d??calage (SHIFT = "10")
        -- =========================================================
        com_reg <= "10";
        
        -- On laisse tourner pendant 55 cycles pour voir toute la trame sortir
        -- et v??rifier que le registre se remplit bien de z??ros ?? la fin.
        wait for 55 * T_100MHz; 
        
        com_reg <= "00"; -- On arr??te tout
        
        report "SIMULATION TERMINEE" severity note;
        wait; -- Fin d??finitive
    end process;

end Behavioral;