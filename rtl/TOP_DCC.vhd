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
    signal trame_dcc   : std_logic_vector(50 downto 0) := (others => '0');
begin
    inst_CEN_DCC   : entity work.CENTRALE_DCC
        port map(RESET,CLK_100MHz,trame_dcc, SORTIE_DCC);
    
    inst_GEN_TRAME : entity work.DCC_FRAME_GENERATOR
        port map( Interrupteurs, trame_dcc);
    
end Behavioral;
