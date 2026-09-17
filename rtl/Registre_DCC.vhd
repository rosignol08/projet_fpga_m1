library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registre_DCC is
    Port(
        CLK_100MHz : in STD_LOGIC;
        RESET      : in STD_LOGIC;
        TRAME_IN   : in STD_LOGIC_VECTOR(50 downto 0);
        COM_REG    : in STD_LOGIC_VECTOR(1 downto 0); -- 00=Hold, 01=Load
        BIT_OUT    : out STD_LOGIC
    );        
end Registre_DCC;

architecture Behavioral of Registre_DCC is
    signal registre : std_logic_vector(50 downto 0) := (others => '0');
begin

    process(CLK_100MHz, RESET)
    begin 
        if RESET = '1' then 
            registre <= (others => '0');
        elsif rising_edge(CLK_100MHz) then 
            case COM_REG is 
                when "01" => 
                    -- Chargement parallèle de la nouvelle trame
                    registre <= TRAME_IN;
                when "10" =>
                    -- Décalage vers la gauche (poids fort vers poids faible)
                    registre(50 downto 1) <= registre(49 downto 0);
                    registre(0) <= '0'; -- Remplissage par des 0
                when others => 
                    -- Maintien de la valeur (Hold)
                    registre <= registre;
                end case;
         end if;
    end process;
    
    -- Le bit de sortie est toujours le bit de poids fort (MSB)
    BIT_OUT <= registre(50);
end Behavioral;
