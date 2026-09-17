library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity DCC_Bit_0 is
    Port ( Clk_100    : in STD_LOGIC; 
           Clk_1      : in STD_LOGIC;
           Reset      : in STD_LOGIC;     
           GO_0       : in STD_LOGIC;
           FIN_0      : out STD_LOGIC;
           DCC_0      : out STD_LOGIC);
end DCC_Bit_0;

architecture Behavioral of DCC_Bit_0 is

    type state_type is (IDLE, SEND_0, SEND_1, DONE);
    signal current_state : state_type := IDLE;

    signal cpt : integer range 0 to 127 := 0;
    signal clk_1_reg : std_logic := '0';
    signal tick_1us  : std_logic := '0';

begin
    
    -- =========================================================
    -- D??tecteur de front de CLK_1MHz (dans le domaine 100MHz)
    -- =========================================================
    process(Clk_100)
    begin
        if rising_edge(Clk_100) then
            clk_1_reg <= Clk_1;
            -- On g??n??re une impulsion de 10ns ?? chaque microseconde
            if (Clk_1 = '1' and clk_1_reg = '0') then
                tick_1us <= '1';
            else
                tick_1us <= '0';
            end if;
        end if;
    end process;

    -- =========================================================
    -- MAE Unique ?? 100MHz
    -- =========================================================
    process(Clk_100, Reset)
    begin 
        if Reset = '1' then 
            current_state <= IDLE;
            cpt   <= 0;
            DCC_0 <= '0';
            FIN_0 <= '0';
        elsif rising_edge(Clk_100) then 
            
            case current_state is 
                
                when IDLE => 
                    cpt   <= 0;
                    DCC_0 <= '0';
                    FIN_0 <= '0';
                    if GO_0 = '1' then 
                        current_state <= SEND_0;
                    end if; 

                when SEND_0 =>
                    DCC_0 <= '0'; 
                    
                    if tick_1us = '1' then
                        if cpt >= 99 then -- 58 ticks (0 ?? 57)
                            cpt <= 0;
                            current_state <= SEND_1;
                        else
                            cpt <= cpt + 1;
                        end if;
                    end if;

                when SEND_1 => 
                    DCC_0 <= '1'; 
                    
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

