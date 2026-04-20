library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity tb_COMPTEUR_TEMPO is
end entity tb_COMPTEUR_TEMPO; 

architecture testbench_cpt of tb_COMPTEUR_TEMPO is
--constant TEMPS_MIN : time := 0.0 ms;
constant TEMPS_MAX : time := 6 ms;

--Clk
--Reset
--Clk1M
--Start_Tempo
--Fin_Tempo

signal Clk: std_logic := '0';
signal Reset: std_logic := '0';
signal Clk1M: std_logic := '0';
signal Start_Tempo: std_logic := '0';
signal Fin_Tempo: std_logic := '0';

begin
 test_cpt : process is
  begin
   if Start_Tempo == '0' then
    Fin_tempo <= '0';
    return Fin_tempo;
    --sinon on commence a attendre 6 ms pour mettre Fin_Tempo a 1
   elsif Start_Tempo == '1' then
    wait for TEMPS_MAX;
    Fin_tempo <= '1';
    return Fin_tempo;

   elsif Fin_Tempo == '1' then
    if Start_Tempo == '0' then
        Start_Tempo <= '0';
        Fin_tempo <= '0';
   	    return Fin_tempo;
    else
        return Fin_tempo;
    end if;
   else
    return 0.0;
   end if;
 end process test_cpt;
end architecture testbench_cpt;