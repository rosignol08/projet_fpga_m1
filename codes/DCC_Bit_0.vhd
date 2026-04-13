library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity DCC_Bit_0 is
    Port ( CLK_100MHz : in STD_LOGIC; 
           CLK_1MHz   : in STD_LOGIC;
           RESET      : in STD_LOGIC;     
           GO_0       : in STD_LOGIC;
           FIN_0      : out STD_LOGIC;
           DCC_0      : out STD_LOGIC);
end DCC_Bit_0;

architecture Behavioral of DCC_Bit_0 is

    type state_type is (IDLE, SEND_0, SEND_1, DONE);
    signal current_state : state_type := IDLE;

    signal cpt : integer range 0 to 63 := 0;
    
    -- Signaux pour détecter le front de l'horloge 1MHz
    signal clk_1_reg : std_logic := '0';
    signal tick_1us  : std_logic := '0';

begin
    
    -- =========================================================
    -- Détecteur de front de CLK_1MHz (dans le domaine 100MHz)
    -- =========================================================
    process(CLK_100MHz)
    begin
        if rising_edge(CLK_100MHz) then
            clk_1_reg <= CLK_1MHz;
            -- On génère une impulsion de 10ns à chaque microseconde
            if (CLK_1MHz = '1' and clk_1_reg = '0') then
                tick_1us <= '1';
            else
                tick_1us <= '0';
            end if;
        end if;
    end process;

    -- =========================================================
    -- MAE Unique à 100MHz
    -- =========================================================
    process(CLK_100MHz, RESET)
    begin 
        if RESET = '1' then 
            current_state <= IDLE;
            cpt   <= 0;
            DCC_0 <= '0';
            FIN_0 <= '0';
        elsif rising_edge(CLK_100MHz) then 
            
            case current_state is 
                
                when IDLE => 
                    cpt   <= 0;
                    DCC_0 <= '0';
                    FIN_0 <= '0';
                    if GO_0 = '1' then 
                        current_state <= SEND_0;
                    end if; 

                when SEND_0 =>
                    DCC_0 <= '0'; -- Bit 1 : impulsion à 0 [cite: 31]
                    
                    if tick_1us = '1' then
                        if cpt >= 99 then -- 58 ticks (0 à 57)
                            cpt <= 0;
                            current_state <= SEND_1;
                        else
                            cpt <= cpt + 1;
                        end if;
                    end if;

                when SEND_1 => 
                    DCC_0 <= '1'; -- Bit 1 : impulsion à 1 
                    
                    if tick_1us = '1' then
                        if cpt >= 99 then
                            cpt <= 0;
                            current_state <= DONE;
                        else
                            cpt <= cpt + 1;
                        end if;
                    end if;
                
                when DONE => 
                    FIN_0 <= '1';
                    DCC_0 <= '0';
                    if GO_0 = '0' then 
                        current_state <= IDLE;
                    end if;

                when others => current_state <= IDLE;
            end case;
        end if; 
    end process;

end Behavioral;

