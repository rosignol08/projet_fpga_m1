--les test bench de la MAE
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_MAE is
end tb_MAE;

architecture behavior of tb_MAE is
    component MAE
    Port (
        Reset       : in STD_LOGIC;
        Clk_In      : in STD_LOGIC;
        FIN_TEMPO   : in STD_LOGIC;
        FIN_0       : in STD_LOGIC;
        FIN_1       : in STD_LOGIC;
        BIT_LU      : in STD_LOGIC;
        START_TEMPO : out STD_LOGIC;
        GO_0        : out STD_LOGIC;
        GO_1        : out STD_LOGIC;
        COM_REG     : out STD_LOGIC_VECTOR(1 downto 0)
    );
    end component;

    --les signaux internes pour connecter la MAE
    --entrees (initialisées à '0')
    signal Reset       : std_logic := '0';
    signal Clk_In      : std_logic := '0';
    signal FIN_TEMPO   : std_logic := '0';
    signal FIN_0       : std_logic := '0';
    signal FIN_1       : std_logic := '0';
    signal BIT_LU      : std_logic := '0';

    --sorties
    signal START_TEMPO : std_logic;
    signal GO_0        : std_logic;
    signal GO_1        : std_logic;
    signal COM_REG     : std_logic_vector(1 downto 0);

    --l'horloge (100 MHz = 10 ns)
    constant clk_period : time := 10 ns;

begin

    --inst de la mae
    uut: MAE PORT MAP (
        Reset => Reset,
        Clk_In => Clk_In,
        FIN_TEMPO => FIN_TEMPO,
        FIN_0 => FIN_0,
        FIN_1 => FIN_1,
        BIT_LU => BIT_LU,
        START_TEMPO => START_TEMPO,
        GO_0 => GO_0,
        GO_1 => GO_1,
        COM_REG => COM_REG
    );

    --gen de l'horloge (tourne en boucle)
    clk_process :process
    begin
        Clk_In <= '0';
        wait for clk_period/2;  --att 5 ns
        Clk_In <= '1';
        wait for clk_period/2;  --att 5 ns
    end process;

    --test
    stim_proc: process
    begin
        --init et Reset
        Reset <= '1';
        wait for 20 ns;
        Reset <= '0';
        wait for clk_period * 2;

        --test tempo
        --la MAE doit etre dans l'état ATTENTE_TEMPO et START_TEMPO doit etre = '1'
        wait for 50 ns; 
        FIN_TEMPO <= '1';  --on simule que le module Tempo a fini ses 6 ms
        wait for clk_period;
        FIN_TEMPO <= '0';  --ça remet le signal

        --la MAE doit passer dans LOAD_REG (COM_REG = "01") puis CHECK_BIT
        wait for clk_period * 2;

        --test d'envoi d'un bit a '1'
        BIT_LU <= '1';              --registre fournit un '1'
        wait until GO_1 = '1';      --attend que la MAE donne l'ordre GO_1
        wait for clk_period * 3;    --simule un temps de traitement par le module DCC_BIT_1
        FIN_1 <= '1';               --module DCC_BIT_1 a fini
        wait for clk_period;
        FIN_1 <= '0';
        
        --la MAE doit faire SHIFT_REG (COM_REG = "10") et revenir a CHECK_BIT

        --test d'envoi d'un bit a '0'
        wait for clk_period * 2;
        BIT_LU <= '0';              --registre a shift et fournit maintenant un '0'
        wait until GO_0 = '1';      --attend l'ordre GO_0
        wait for clk_period * 3;
        FIN_0 <= '1';
        wait for clk_period;
        FIN_0 <= '0';

        --fin du test (stop la simulation)
        wait;
    end process;

end behavior;