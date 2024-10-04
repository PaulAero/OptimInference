library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Neuron is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        inputs    : in  SIGNED(15 downto 0);
        weight    : in  SIGNED(15 downto 0);
        bias      : in  SIGNED(15 downto 0);
        output    : out SIGNED(15 downto 0)
    );
end Neuron;

architecture Behavioral of Neuron is
    signal sum : SIGNED(31 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                output <= (others => '0');
            else
                sum <= inputs * weight + bias;
                -- Fonction d'activation ReLU
                if sum(31) = '1' then  -- Si le bit de signe est 1 (négatif)
                    output <= (others => '0');
                else
                    output <= sum(15 downto 0);  -- Troncature aux 16 bits inférieurs
                end if;
            end if;
        end if;
    end process;
end Behavioral;
