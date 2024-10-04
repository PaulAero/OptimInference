library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Layer is
    Generic (
        NUM_NEURONS : integer := 16  -- Nombre de neurones dans la couche
    );
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        inputs       : in  SIGNED(15 downto 0);
        weights      : in  array(0 to NUM_NEURONS-1) of SIGNED(15 downto 0);
        biases       : in  array(0 to NUM_NEURONS-1) of SIGNED(15 downto 0);
        outputs      : out array(0 to NUM_NEURONS-1) of SIGNED(15 downto 0)
    );
end Layer;

architecture Behavioral of Layer is
    component Neuron
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            inputs    : in  SIGNED(15 downto 0);
            weight    : in  SIGNED(15 downto 0);
            bias      : in  SIGNED(15 downto 0);
            output    : out SIGNED(15 downto 0)
        );
    end component;

begin
    gen_neurons: for i in 0 to NUM_NEURONS-1 generate
        neuron_inst: Neuron
            Port map (
                clk    => clk,
                reset  => reset,
                inputs => inputs,  -- À modifier si vous avez des entrées différentes pour chaque neurone
                weight => weights(i),
                bias   => biases(i),
                output => outputs(i)
            );
    end generate;
end Behavioral;
