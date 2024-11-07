-- NeuralNetwork_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity NeuralNetwork_tb is
end NeuralNetwork_tb;

architecture Behavioral of NeuralNetwork_tb is
    -- Composant à tester
    component NeuralNetwork
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            inputs  : in  SIGNED(15 downto 0);
            outputs : out SIGNED(15 downto 0)
        );
    end component;

    -- Signaux pour la simulation
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '1';
    signal inputs   : SIGNED(15 downto 0) := (others => '0');
    signal outputs  : SIGNED(15 downto 0);

    file image_file : text open read_mode is "data/mnist_samples/image1.txt";
    file results_file : text open write_mode is "simulation_results.txt";

    -- Type pour les données d'entrée
    type input_array is array (0 to 783) of SIGNED(15 downto 0);

    -- Signaux d'entrée
    signal input_data : input_array;

begin
    -- Génération de l'horloge
    clk_process : process
    begin
        clk <= not clk after 10 ns;
        wait for 10 ns;
    end process;

    -- Instanciation du réseau de neurones
    UUT: NeuralNetwork
        Port map (
            clk     => clk,
            reset   => reset,
            inputs  => inputs,
            outputs => outputs
        );

    -- Processus principal
    stim_proc: process
        variable image_line   : line;
        variable pixel_value  : integer;
        variable input_index  : integer := 0;
        variable results_line : line;
        variable i            : integer;
    begin
        -- Attente initiale
        wait for 100 ns;
        reset <= '0';
        report "Simulation démarrée, fichier image en cours de traitement" severity note;

        -- Lecture des données d'entrée avec rapports de débogage
        while not endfile(image_file) loop
            readline(image_file, image_line);
            read(image_line, pixel_value);
            report "Lecture d'une ligne de l'image, pixel_value = " & integer'image(pixel_value) severity note;
            input_data(input_index) <= to_signed(pixel_value, 16);
            input_index := input_index + 1;
        end loop;

        report "Fin de la lecture du fichier image" severity note;

        -- Application des stimuli et enregistrement des sorties
        for i in 0 to input_index - 1 loop
            inputs <= input_data(i);
            wait for 20 ns;

            -- Écriture de la sortie dans le fichier
            results_line := null;

            write(results_line, string'("Index: "));
            write(results_line, i, right, 0);
            write(results_line, string'(", Output: "));
            write(results_line, to_integer(outputs), right, 0);

            writeline(results_file, results_line);

            --report "Écriture des résultats, Index = " & integer'image(i) & ", Output = " & integer'image(to_integer(outputs)) severity note;
        end loop;

        report "Fin de la simulation" severity note;

        -- Fin de la simulation
        wait;
    end process;

end Behavioral;