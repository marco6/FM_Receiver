library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AsyncMul is
	generic (
		N : positive := 8
	);
port (
	A, B : in signed(N-1 downto 0);
	C : out signed(2*N -1 downto 0)
);
end AsyncMul;

architecture Behavioral of AsyncMul is
begin
	C <= A * B;
end Behavioral;
