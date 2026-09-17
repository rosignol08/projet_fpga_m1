library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_DCC is
    Port( RESET         : in  std_logic; 
          CLK_100MHz    : in  std_logic;
          Interrupteurs : in  std_logic_vector(7 downto 0);
          SORTIE_DCC    : out std_logic
    );
end TOP_DCC;

architecture Behavioral of TOP_DCC is
    -- =========================================================================
    -- 1. DÉCLARATION DES "CÂBLES" INTERNES (Signaux)
    -- Ce sont les flèches noires sur votre schéma de la Figure 3.
    -- =========================================================================
    signal clk_1MHz    : std_logic;
    signal trame_dcc   : std_logic_vector(50 downto 0);
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
    inst_CEN_DCC   : entity work.CENTRALE_DCC
        port map(RESET,CLK_100MHz,trame_dcc, SORTIE_DCC);
    
    inst_GEN_TRAME : entity work.DCC_FRAME_GENERATOR
        port map( Interrupteurs, trame_dcc);
    
end Behavioral;
