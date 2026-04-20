library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CENTRALE_DCC is
    Port( RESET         : in  std_logic; 
          CLK_100MHz    : in  std_logic;
          TRAME_DCC     : in  std_logic_vector(50 downto 0);
          SORTIE_DCC    : out std_logic
    );
end CENTRALE_DCC;

architecture Behavioral of CENTRALE_DCC is
  -- =========================================================================
    -- 1. DÉCLARATION DES "CÂBLES" INTERNES (Signaux)
    -- Ce sont les flèches noires sur votre schéma de la Figure 3.
    -- =========================================================================
    signal clk_1MHz    : std_logic;
    signal com_reg     : std_logic_vector(1 downto 0);
    signal bit_out     : std_logic;
    signal start_tempo : std_logic;
    signal fin_tempo   : std_logic;
    signal go_1        : std_logic;
    signal fin_1       : std_logic;
    signal go_0        : std_logic;
    signal fin_0       : std_logic;
    signal dcc_1       : std_logic;
    signal dcc_0       : std_logic;
begin


    -- =========================================================================
    -- 2. INSTANCIATION DES MODULES (On pose les composants et on branche)
    -- =========================================================================
    
    inst_DIV_CLK : entity work.CLK_DIV
        port map(
            Reset => reset,
            Clk_In  => CLK_100MHz, 
            Clk_Out => CLK_1MHz 
        );
        
    inst_TEMPO : entity work.COMPTEUR_TEMPO
        port map(clk_100mhz,reset,clk_1mhz,start_tempo,fin_tempo);
        
        
    inst_Registre_DCC : entity work.Registre_DCC
        port map(CLK_100MHz, RESET, TRAME_DCC, com_reg, bit_out);
    
    inst_DCC_Bit_1 : entity work.DCC_Bit_1
        port map(CLK_100MHz, CLK_1MHz, RESET, go_1, fin_1, dcc_1);
    
    inst_DCC_Bit_0 : entity work.DCC_Bit_0
        port map(CLK_100MHz, CLK_1MHz, RESET, go_0, fin_0, dcc_0);
        
    inst_MAE : entity work.mae
        port map(RESET, CLK_100MHz, fin_tempo, fin_0, fin_1, bit_out, start_tempo, go_0, go_1, com_reg);
    
    -- =========================================================================
    -- 3. PORTE OU LOGIQUE DE SORTIE
    -- Selon le schéma, Sortie_DCC réunit les signaux d'envoi 1 et 0
    -- =========================================================================
    Sortie_DCC <= dcc_1 or dcc_0;


end Behavioral;
