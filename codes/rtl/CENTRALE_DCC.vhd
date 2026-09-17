library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CENTRALE_DCC is
    Port( Reset         : in  std_logic; 
          Clk_100       : in  std_logic;
          TRAME_DCC     : in  std_logic_vector(50 downto 0);
          SORTIE_DCC    : out std_logic
    );
end CENTRALE_DCC;

architecture Behavioral of CENTRALE_DCC is
    -- =========================================================================
    -- D??CLARATION DES "C??BLES" INTERNES (Signaux)
    -- =========================================================================
    signal Clk_1       : std_logic  := '0';
    signal com_reg     : std_logic_vector(1 downto 0) := "00";
    signal bit_out     : std_logic := '0';
    signal start_tempo : std_logic := '0';
    signal fin_tempo   : std_logic := '0';
    signal go_1        : std_logic := '0';
    signal fin_1       : std_logic := '0';
    signal go_0        : std_logic := '0';
    signal fin_0       : std_logic := '0';
    signal dcc_1       : std_logic := '0';
    signal dcc_0       : std_logic := '0';
begin


    -- =========================================================================
    -- 2. INSTANCIATION DES MODULES (On pose les composants et on branche)
    -- =========================================================================
    
    inst_DIV_CLK : entity work.CLK_DIV
        port map(Reset, Clk_100, Clk_1);   
        
    inst_TEMPO : entity work.COMPTEUR_TEMPO
        port map(Clk_100 ,Reset, Clk_1, start_tempo, fin_tempo);
        
    inst_MAE : entity work.mae
        port map(Reset, Clk_100, fin_tempo, fin_0, fin_1, bit_out, start_tempo, go_0, go_1, com_reg);
    
    inst_Registre_DCC : entity work.Registre_DCC
        port map(Clk_100, Reset, TRAME_DCC, com_reg, bit_out);
    
    inst_DCC_Bit_1 : entity work.DCC_Bit_1
        port map(Clk_100, Clk_1, Reset, go_1, fin_1, dcc_1);
    
    inst_DCC_Bit_0 : entity work.DCC_Bit_0
        port map(Clk_100, Clk_1, Reset, go_0, fin_0, dcc_0);
        
    
    -- =========================================================================
    -- 3. PORTE OU LOGIQUE DE SORTIE
    -- Selon le sch??ma, Sortie_DCC r??unit les signaux d'envoi 1 et 0
    -- =========================================================================
    Sortie_DCC <= dcc_1 or dcc_0;


end Behavioral;
