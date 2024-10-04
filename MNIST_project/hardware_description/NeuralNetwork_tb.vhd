library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

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

    -- Fichier pour écrire les résultats
    file results_file : text open write_mode is "simulation_results.txt";
    variable results_line : line;

    -- Variables pour les données d'entrée
    file image_file : text open read_mode is "data/mnist_samples/image1.txt";
    variable image_line : line;
    variable pixel_value : integer;
    variable input_index : integer := 0;
    type input_array is array (0 to 783) of SIGNED(15 downto 0);
    variable input_data : input_array;

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

    -- Lecture des données d'entrée
    load_inputs: process
    begin
        while not endfile(image_file) loop
            readline(image_file, image_line);
            read(image_line, pixel_value);
            input_data(input_index) := to_signed(pixel_value, 16);
            input_index := input_index + 1;
        end loop;
        wait;
    end process;

    -- Application des stimuli et enregistrement des sorties
    stim_proc: process
        variable i : integer := 0;
    begin
        -- Attente de la fin de la lecture des entrées
        wait for 100 ns;
        reset <= '0';

        for i in 0 to 783 loop  -- Pour chaque pixel de l'image
            inputs <= input_data(i);
            wait for 20 ns;  -- Attente pour que la sortie soit stable

            -- Écriture de la sortie dans le fichier
            write(results_line, integer'image(i) & " " & integer'image(to_integer(outputs)));
            writeline(results_file, results_line);
        end loop;

        -- Fin de la simulation
        wait;
    end process;
end Behavioral;
