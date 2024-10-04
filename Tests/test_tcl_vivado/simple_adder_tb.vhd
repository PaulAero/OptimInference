library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_adder_tb is
end simple_adder_tb;

architecture Behavioral of simple_adder_tb is
    -- Composant à tester
    component simple_adder
        Port (
            A     : in  STD_LOGIC_VECTOR(3 downto 0);
            B     : in  STD_LOGIC_VECTOR(3 downto 0);
            C_IN  : in  STD_LOGIC;
            S     : out STD_LOGIC_VECTOR(3 downto 0);
            C_OUT : out STD_LOGIC
        );
    end component;

    -- Signaux pour les stimuli de test
    signal A_tb     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal B_tb     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal C_IN_tb  : STD_LOGIC := '0';
    signal S_tb     : STD_LOGIC_VECTOR(3 downto 0):= "0000";
    signal C_OUT_tb : STD_LOGIC;

begin
    -- Instanciation du composant à tester
    UUT: simple_adder
        port map (
            A     => A_tb,
            B     => B_tb,
            C_IN  => C_IN_tb,
            S     => S_tb,
            C_OUT => C_OUT_tb
        );

    -- Processus de génération des stimuli
    stim_proc: process
    begin
        -- Cas de test 1: A = 0000, B = 0000, C_IN = 0
        A_tb <= "0000"; B_tb <= "0000"; C_IN_tb <= '0';
        wait for 100 ns;

        -- Cas de test 2: A = 0001, B = 0001, C_IN = 0
        A_tb <= "0001"; B_tb <= "0001"; C_IN_tb <= '0';
        wait for 100 ns;

        -- Cas de test 3: A = 0101, B = 0011, C_IN = 1
        A_tb <= "0101"; B_tb <= "0011"; C_IN_tb <= '1';
        wait for 100 ns;

        -- Cas de test 4: A = 1111, B = 0001, C_IN = 1
        A_tb <= "1111"; B_tb <= "0001"; C_IN_tb <= '1';
        wait for 100 ns;
    end process;

end Behavioral;