library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SyncMul is
	generic (
		N : positive := 8
	);
	port (
		CLK : in std_logic;
		A, B : in signed(N-1 downto 0);
		C : out signed(2*N -1 downto 0)
	);
end SyncMul;


architecture Behavioral of SyncMul is
begin
	C <= A * B when (CLK='1' and CLK'event);
end architecture;
