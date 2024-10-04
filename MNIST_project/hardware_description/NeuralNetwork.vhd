library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NeuralNetwork is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        inputs  : in  SIGNED(15 downto 0);
        outputs : out SIGNED(15 downto 0)
    );
end NeuralNetwork;

architecture Behavioral of NeuralNetwork is
    component Layer
        Generic (
            NUM_NEURONS : integer
        );
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            inputs  : in  SIGNED(15 downto 0);
            weights : in  array(0 to NUM_NEURONS-1) of SIGNED(15 downto 0);
            biases  : in  array(0 to NUM_NEURONS-1) of SIGNED(15 downto 0);
            outputs : out array(0 to NUM_NEURONS-1) of SIGNED(15 downto 0)
        );
    end component;

    -- Signaux internes pour connecter les couches
    signal layer1_outputs : array(0 to NUM_NEURONS_LAYER1-1) of SIGNED(15 downto 0);
    signal layer2_outputs : array(0 to NUM_NEURONS_LAYER2-1) of SIGNED(15 downto 0);

    -- Constantes pour le nombre de neurones par couche
    constant NUM_NEURONS_LAYER1 : integer := 16;
    constant NUM_NEURONS_LAYER2 : integer := 10;

    -- Déclaration des poids et biais (à remplacer par des ROM initialisées avec les fichiers .coe)
    signal weights_layer1 : array(0 to NUM_NEURONS_LAYER1-1) of SIGNED(15 downto 0);
    signal biases_layer1  : array(0 to NUM_NEURONS_LAYER1-1) of SIGNED(15 downto 0);

    signal weights_layer2 : array(0 to NUM_NEURONS_LAYER2-1) of SIGNED(15 downto 0);
    signal biases_layer2  : array(0 to NUM_NEURONS_LAYER2-1) of SIGNED(15 downto 0);

begin
    -- Instanciation de la première couche
    layer1_inst: Layer
        generic map (
            NUM_NEURONS => NUM_NEURONS_LAYER1
        )
        port map (
            clk     => clk,
            reset   => reset,
            inputs  => inputs,
            weights => weights_layer1,
            biases  => biases_layer1,
            outputs => layer1_outputs
        );

    -- Instanciation de la deuxième couche
    layer2_inst: Layer
        generic map (
            NUM_NEURONS => NUM_NEURONS_LAYER2
        )
        port map (
            clk     => clk,
            reset   => reset,
            inputs  => layer1_outputs(0),  -- À adapter pour connecter correctement les sorties
            weights => weights_layer2,
            biases  => biases_layer2,
            outputs => layer2_outputs
        );

    -- Sortie du réseau
    outputs <= layer2_outputs(0);  -- À adapter selon vos besoins

end Behavioral;
