library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity simple_adder is
    Port (
        A     : in  STD_LOGIC_VECTOR(3 downto 0);
        B     : in  STD_LOGIC_VECTOR(3 downto 0);
        C_IN  : in  STD_LOGIC;               -- Ajout de l'entrée de retenue
        S   : out STD_LOGIC_VECTOR(3 downto 0);
        C_OUT : out STD_LOGIC
    );
end simple_adder;

architecture Behavioral of simple_adder is
    signal carry : STD_LOGIC_VECTOR(4 downto 0); -- Fil de retenue interne
begin
    -- Retenue d'entrée initialisée
    carry(0) <= C_IN;

    -- Addition bit à bit avec gestion de la retenue
    S(0) <= A(0) xor B(0) xor carry(0);
    carry(1) <= (A(0) and B(0)) or (A(0) and carry(0)) or (B(0) and carry(0));

    S(1) <= A(1) xor B(1) xor carry(1);
    carry(2) <= (A(1) and B(1)) or (A(1) and carry(1)) or (B(1) and carry(1));

    S(2) <= A(2) xor B(2) xor carry(2);
    carry(3) <= (A(2) and B(2)) or (A(2) and carry(2)) or (B(2) and carry(2));

    S(3) <= A(3) xor B(3) xor carry(3);
    carry(4) <= (A(3) and B(3)) or (A(3) and carry(3)) or (B(3) and carry(3));

    -- Retenue de sortie
    C_OUT <= carry(4);
end Behavioral;